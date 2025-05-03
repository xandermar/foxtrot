#!/bin/bash

# Load .env if it exists
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check for required environment variables
if [[ -z "$OPENAI_API_KEY" || -z "$PIXABAY_API_KEY" ]]; then
  echo "Missing OPENAI_API_KEY or PIXABAY_API_KEY."
  exit 1
fi

# Get topic of the day from ChatGPT
TOPIC_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "system", "content": "You are an expert content strategist."},
                 {"role": "user", "content": "What is today'\''s most popular or trending topic in Drupal, AI, or Web Technology? Provide just the topic title."}],
    "max_tokens": 50
  }')

TOPIC=$(echo "$TOPIC_RESPONSE" | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//' | tr -d '\n')

echo "📌 Topic: $TOPIC"

# Generate categories
CATEGORY_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are a taxonomy expert for technical blog posts.\"},
      {\"role\": \"user\", \"content\": \"Based on the topic '$TOPIC', suggest 1 to 3 Jekyll-style lowercase slug categories (e.g. [ai, drupal, web-tech]). Return as a JSON array.\"}
    ],
    \"max_tokens\": 50
  }")

CATEGORIES=$(echo "$CATEGORY_RESPONSE" | jq -r '.choices[0].message.content' | sed 's/[][[:space:]]//g' | sed 's/,/, /g')


# Generate blog content
POST_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are a technical blogger writing for a Jekyll-based site.\"},
      {\"role\": \"user\", \"content\": \"Write a detailed, markdown-formatted blog post for Jekyll titled '$TOPIC' covering key aspects, use cases, and recent developments. Add section headings.\"}
    ],
    \"max_tokens\": 1200
  }")

POST_BODY=$(echo "$POST_RESPONSE" | jq -r '.choices[0].message.content' | sed '/^---/,/^---/d')

# Get image from Pixabay
QUERY=$(echo "$TOPIC" | sed 's/ /%20/g')
IMAGE_RESPONSE=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=$QUERY&image_type=photo&per_page=3&safesearch=true")

RAW_IMAGE_URL=$(echo "$IMAGE_RESPONSE" | jq -r '.hits[0].largeImageURL')

if [[ "$RAW_IMAGE_URL" == null || -z "$RAW_IMAGE_URL" ]]; then
  IMAGE_LINE=""
else
  # Replace the pixabay.com domain with cdn.pixabay.com
  IMAGE_URL=$(echo "$RAW_IMAGE_URL" | sed 's|https://pixabay.com/get/|https://cdn.pixabay.com/|')
  IMAGE_LINE="![Image]($IMAGE_URL){: .img-fluid }"
fi

# Create filename
DATE=$(date +%Y-%m-%d)
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/-$//')
FILENAME="_posts/$DATE-$SLUG.md"

# Create post directory if it doesn't exist
mkdir -p _posts

# Assemble full post
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

echo "✅ Post generated at: $FILENAME"
