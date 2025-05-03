#!/bin/bash

# Load environment variables from .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ensure API key is present
if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY not set."
  exit 1
fi

# Function to send prompt to OpenAI ChatGPT
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

# Step 1: Get the trending topic
echo "Getting topic..."
topic_prompt="What is the most popular or trending topic today in Drupal, AI, or Web Technology? Respond with a concise topic title."
TOPIC=$(chatgpt "$topic_prompt")
echo "Topic: $TOPIC"

# Create a safe slug for the filename
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/^-//;s/-$//')

# Step 2: Generate Jekyll post content
echo "Generating Jekyll post..."
POST_CONTENT=$(chatgpt "Write a Jekyll-compatible Markdown blog post about the topic: \"$TOPIC\". Include YAML front matter with title, date (today), and categories. The content should be engaging and informative.")

# Step 3: Write the post to the _posts directory
DATE=$(date '+%Y-%m-%d')
FILENAME="_posts/${DATE}-${SLUG}.md"
echo "$POST_CONTENT" > "$FILENAME"

echo "Post created at $FILENAME"
