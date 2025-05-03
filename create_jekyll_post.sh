#!/bin/bash

# Load .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ensure required API keys are available
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ Error: OPENAI_API_KEY not set"
  exit 1
fi

if [ -z "$PIXABAY_API_KEY" ]; then
  echo "❌ Error: PIXABAY_API_KEY not set"
  exit 1
fi


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

# Step 1: Get topic
echo "🔍 Getting topic..."
topic_prompt="What is the most popular or trending topic today in Drupal, AI, or Web Technology? Respond with a concise topic title."
TOPIC=$(chatgpt "$topic_prompt" | sed 's/^"//;s/"$//')
echo "📝 Topic: $TOPIC"

# Step 2: Slug/date/filename
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[\"'\'']//g' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')
DATE=$(date '+%Y-%m-%d')
FILENAME="_posts/${DATE}-${SLUG}.md"
mkdir -p assets/images

# Step 3: Skip if file exists
if [ -f "$FILENAME" ]; then
  echo "⚠️ Post already exists: $FILENAME"
  exit 0
fi

# Step 4: Generate post
echo "🧠 Generating post content..."
POST_RAW=$(chatgpt "Write a Jekyll-compatible Markdown blog post about the topic: \"$TOPIC\". Include YAML front matter with title, date (today), and categories. The content should be engaging and informative. Include at least one direct image URL (https://...) ending in .jpg or .png, using standard Markdown image syntax.")

# Step 5: Fix front matter date
POST_CONTENT=$(echo "$POST_RAW" | sed -E "s/^date: .*/date: $DATE/")

# Fallback logic using Pixabay API
if [ ! -s "$DEST_FS" ]; then
  echo "❌ Download failed. Attempting fallback from Pixabay..."

  QUERY=$(echo "$SLUG" | tr '-' '+')
  PIXABAY_JSON=$(curl -s "https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=$QUERY&image_type=photo&orientation=horizontal&safesearch=true&per_page=3")

  FALLBACK_URL=$(echo "$PIXABAY_JSON" | jq -r '.hits[0].largeImageURL')

  if [[ "$FALLBACK_URL" == "null" || -z "$FALLBACK_URL" ]]; then
    echo "❌ No fallback image found on Pixabay for '$QUERY'"
    continue
  fi

  FALLBACK_FILENAME="${SLUG}.jpg"
  DEST_FS="assets/images/$FALLBACK_FILENAME"
  DEST_MD="/assets/images/$FALLBACK_FILENAME"

  echo "📥 Downloading fallback image from Pixabay: $FALLBACK_URL"
  curl -sL "$FALLBACK_URL" -o "$DEST_FS"

  if [ ! -s "$DEST_FS" ]; then
    echo "❌ Failed to save fallback image from Pixabay."
    continue
  fi
fi



# Step 7: Replace image markdown with <img> + img-fluid class
POST_CONTENT=$(echo "$POST_CONTENT" | sed -E 's|!\[([^\]]*)\]\((/assets/images/[^)]+)\s*"?([^"]*)"?\)|<img src="\2" alt="\1" title="\3" class="img-fluid">|g')

# Step 8: Save the post
echo "$POST_CONTENT" > "$FILENAME"
echo "✅ Post created: $FILENAME"
