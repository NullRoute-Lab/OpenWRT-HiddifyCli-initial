#!/bin/sh

# List of subscription links is passed as an environment variable (SUB_URLS)

# State file to store the current subscription URL
STATE_FILE="/tmp/hiddify_current_sub_url"

# Temporary file to store the downloaded content
TMP_FILE="/tmp/hiddify_sub_content"

# Get the current subscription URL
if [ -f "$STATE_FILE" ]; then
    CURRENT_SUB_URL=$(cat "$STATE_FILE")
else
    CURRENT_SUB_URL=${SUB_URLS[0]}
fi

# Function to check if a URL is available
is_available() {
    curl -L --output /dev/null --silent --head --fail "$1"
}

# Function to get the content of a URL
get_content() {
    curl -L --silent "$1"
}

# Find the best subscription link
BEST_SUB_URL=""
for url in $SUB_URLS; do
    if is_available "$url"; then
        CONTENT=$(get_content "$url")
        if [ -n "$CONTENT" ]; then
            if [ "$url" != "$CURRENT_SUB_URL" ]; then
                echo "$CONTENT" > "$TMP_FILE"
                if ! cmp -s "$TMP_FILE" <(get_content "$CURRENT_SUB_URL"); then
                    BEST_SUB_URL=$url
                    break
                fi
            else
                BEST_SUB_URL=$url
                break
            fi
        fi
    fi
done

# If no new link is found, use the current one if it's still available
if [ -z "$BEST_SUB_URL" ] && is_available "$CURRENT_SUB_URL"; then
    BEST_SUB_URL=$CURRENT_SUB_URL
fi

# If a best link is found, update the state file
if [ -n "$BEST_SUB_URL" ]; then
    echo "$BEST_SUB_URL" > "$STATE_FILE"
fi

# Clean up temporary files
rm -f "$TMP_FILE"
