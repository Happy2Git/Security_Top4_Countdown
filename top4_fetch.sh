#!/bin/bash

CACHE=top4_data.json
YQ_PATH="/opt/homebrew/bin/yq"

# If the cache doesn't exist or is older than 7 days, update it
if [ ! -f "$CACHE" ] || [ $(find "$CACHE" -mtime +7) ]; then
  curl -s 'https://raw.githubusercontent.com/sec-deadlines/sec-deadlines.github.io/master/_data/conferences.yml' | "$YQ_PATH" -o=json > "$CACHE"
fi

# Just print the current cache content
cat "$CACHE"
