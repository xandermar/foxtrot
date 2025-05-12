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

# Create _posts directory if it doesn't exist
mkdir -p _posts

# Function to slugify a string
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Loop to get a unique topic
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

# Get relevant categories
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

# Generate the blog post body
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

# Clean up markdown: remove --- and ``` wrappers
POST_BODY=$(echo "$POST_RESPONSE" | jq -r '.choices[0].message.content' \
  | sed '/^---/,/^---/d' \
  | sed '1{/^```.*$/d;}' \
  | sed '${/^```$/d;}')

# ---------- IMAGE HANDLING (DOWNLOAD to /assets) ----------

ASSETS_DIR="assets"
mkdir -p "$ASSETS_DIR"

# Helper: Get the first available image
get_first_image() {
  local response="$1"
  echo "$response" | jq -r '.hits[0].largeImageURL'
}

# Try topic-specific image
QUERY=$(echo "$TOPIC" | sed 's/ /%20/g')
IMAGE_RESPONSE=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=$QUERY&image_type=photo&per_page=10&safesearch=true")
RAW_IMAGE_URL=$(get_first_image "$IMAGE_RESPONSE")

# Fallback to "technology" image
if [[ -z "$RAW_IMAGE_URL" || "$RAW_IMAGE_URL" == "null" ]]; then
  echo "⚠️ No image found for topic. Using fallback: 'technology'"
  FALLBACK_RESPONSE=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=technology&image_type=photo&per_page=10&safesearch=true")
  RAW_IMAGE_URL=$(get_first_image "$FALLBACK_RESPONSE")
fi

# Download image and use local asset reference
if [[ -n "$RAW_IMAGE_URL" && "$RAW_IMAGE_URL" != "null" ]]; then
  # Extract filename from URL
  FILENAME_IMG=$(basename "$RAW_IMAGE_URL" | cut -d'?' -f1)
  LOCAL_PATH="$ASSETS_DIR/$FILENAME_IMG"
  curl -s -o "$LOCAL_PATH" "$RAW_IMAGE_URL"

  # Use local reference
  IMAGE_LINE="![Image](/$LOCAL_PATH){: .img-fluid style=\"max-height:720px; height:auto;\" }"
else
  IMAGE_LINE=""
fi


# ---------- WRITE MARKDOWN FILE ----------

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
