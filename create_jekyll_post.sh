#!/bin/bash

# Load .env if present
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check for required API keys
if [[ -z "$OPENAI_API_KEY" || -z "$PIXABAY_API_KEY" ]]; then
  echo "❌ Missing OPENAI_API_KEY or PIXABAY_API_KEY."
  exit 1
fi

# Create _posts directory if not exists
mkdir -p _posts

# Function to convert topic into a slug
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Loop until a unique topic is found
attempt=1
while true; do
  echo "🌀 Attempt $attempt to get a unique topic..."
  TOPIC_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "gpt-4",
      "messages": [
        {"role": "system", "content": "You are an expert content strategist."},
        {"role": "user", "content": "Suggest a trending blog topic related to Drupal, AI, or Web Technology. Only respond with the title."}
      ],
      "max_tokens": 50
    }')

  TOPIC=$(echo "$TOPIC_RESPONSE" | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//' | tr -d '\n')
  SLUG=$(slugify "$TOPIC")
  DATE=$(date +%Y-%m-%d)
  FILENAME="_posts/$DATE-$SLUG.md"

  if [ ! -f "$FILENAME" ]; then
    echo "✅ Unique topic: $TOPIC"
    break
  fi

  echo "⚠️ Topic already exists: $FILENAME"
  attempt=$((attempt + 1))
  sleep 2
done

# Generate categories
CATEGORY_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are a taxonomy expert for technical blog posts.\"},
      {\"role\": \"user\", \"content\": \"Based on the topic '$TOPIC', suggest 1 to 3 lowercase Jekyll-style categories (e.g. [ai, drupal, web-tech]). Return as a JSON array.\"}
    ],
    \"max_tokens\": 50
  }")

CATEGORIES=$(echo "$CATEGORY_RESPONSE" | jq -r '.choices[0].message.content' | tr -d '[]" \n' | sed 's/,/, /g')

# Generate blog content
POST_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are a technical blogger writing for a Jekyll-based site.\"},
      {\"role\": \"user\", \"content\": \"Write a markdown-formatted blog post titled '$TOPIC' with an introduction, section headings, use cases, and a conclusion.\"}
    ],
    \"max_tokens\": 1200
  }")

# Strip any YAML front matter and wrapping triple backticks
POST_BODY=$(echo "$POST_RESPONSE" | jq -r '.choices[0].message.content' \
  | sed '/^---/,/^---/d' \
  | sed '1s/^```$//' \
  | sed '$s/^```$//')

# Get a Pixabay image

# Step 1: Try image for topic
QUERY=$(echo "$TOPIC" | sed 's/ /%20/g')
IMAGE_RESPONSE=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=$QUERY&image_type=photo&per_page=3&safesearch=true")
RAW_IMAGE_URL=$(echo "$IMAGE_RESPONSE" | jq -r '.hits[0].largeImageURL')

# Step 2: Fallback to random "technology" image
if [[ -z "$RAW_IMAGE_URL" || "$RAW_IMAGE_URL" == "null" ]]; then
  echo "⚠️ No image found for topic '$TOPIC'. Using random fallback image from 'technology'..."

  # Choose a random number between 0 and 4 (get more than 1 image to randomize)
  RANDOM_INDEX=$(( RANDOM % 5 ))
  IMAGE_RESPONSE=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=technology&image_type=photo&per_page=5&safesearch=true")
  RAW_IMAGE_URL=$(echo "$IMAGE_RESPONSE" | jq -r ".hits[$RANDOM_INDEX].largeImageURL")
fi

# Final image line
if [[ -n "$RAW_IMAGE_URL" && "$RAW_IMAGE_URL" != "null" ]]; then
  IMAGE_LINE="![Image]($RAW_IMAGE_URL){: .img-fluid }"
else
  echo "❌ No image available even after fallback."
  IMAGE_LINE=""
fi


# Write the final Markdown post
cat <<EOF > "$FILENAME"
---
layout: post
title: "$TOPIC"
date: $DATE
categories: [${CATEGORIES}]
---

$IMAGE_LINE

$POST_BODY
EOF

echo "✅ Blog post created: $FILENAME"
