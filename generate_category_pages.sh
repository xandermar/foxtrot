#!/bin/bash

# Create or clear the output folder
mkdir -p _category_pages
rm -f _category_pages/*.md

# Extract unique categories from _posts
grep -rho '^categories:.*' _posts | \
sed -E 's/^categories:[[:space:]]*\[?//; s/\]//; s/,/ /g' | \
tr ' ' '\n' | \
sed '/^$/d' | sort -u | while read category; do
  filename="_category_pages/${category}.md"
  title="$(echo "$category" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
  echo "Creating category page: $filename"
  cat <<EOF > "$filename"
---
layout: category
title: $title
category: $category
permalink: /category/${category}.html
---
EOF
done

echo "✅ Done generating category pages."

