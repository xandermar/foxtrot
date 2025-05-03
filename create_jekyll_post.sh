#!/bin/bash

# Load environment variables from .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ensure API key is set
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ Error: OPENAI_API_KEY not set."
  exit 1
fi

# ChatGPT query wrapper
chatgpt() {
  local prompt="$1"
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "gpt-4",
      "messages": [{"role": "user", "content": "'"${prompt//\"/\\\"}"'"}],
      "temperature": 0.7
    }' | jq -r '.choices[0].message.content'
}

# Step 1: Get trending topic
echo "🔍 Getting topic..."
topic_prompt="What is the most popular or trending topic today in Drupal, AI, or Web Technology? Respond with a concise topic title."
TOPIC=$(chatgpt "$topic_prompt")
echo "📝 Topic: $TOPIC"

# Step 2: Normalize slug
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/^-//;s/-$//')
DATE=$(date '+%Y-%m-%d')
FILENAME="_posts/${DATE}-${SLUG}.md"

# Step 3: Prevent duplicate post
if [ -f "$FILENAME" ]; then
  echo "⚠️ Post already exists: $FILENAME"
  exit 0
fi

# Step 4: Generate post
echo "🧠 Generating Jekyll post..."
POST_CONTENT=$(chatgpt "Write a Jekyll-compatible Markdown blog post about the topic: \"$TOPIC\". Include YAML front matter with title, date (today), and categories. The content should be engaging and informative. Include at least one image with alt text.")

# Step 5: Convert Markdown images to HTML with img-fluid class
POST_CONTENT_MODIFIED=$(echo "$POST_CONTENT" | sed -E 's|!\[([^\]]*)\]\(([^)]+)\)|<img src="\2" alt="\1" class="img-fluid">|g')

# Step 6: Save post
echo "$POST_CONTENT_MODIFIED" > "$FILENAME"
echo "✅ Post created: $FILENAME"
