#!/bin/bash

# This script needs to be executed at the root of the project



# Clear the output file if it exists
counter=1

# Get the latest GitHub tag
latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1))

echo "Latest GitHub tag: $latest_tag"

mkdir -p releases/$latest_tag

cp deploy/index.html releases/index.html
output_file="releases/$latest_tag/package.dhall"


for file in $(find src -type f -name "*.dhall"); do
    filename=$(basename "$file" .dhall)
    filepath=$(dirname "$file" | sed 's|^src/||')
    
    if [[ $counter -eq 1 ]]; then
      prefix="{"
    else 
      prefix=","
    fi

    echo "$prefix $filepath/$filename = (./$file)" >> "$output_file"
    
    ((counter++))
done
echo "}" >> "$output_file"

CHECKSUM=$(sha256sum "$output_file" | awk '{print $1}')

echo ls --recursive releases

echo "Generated $output_file with checksum $CHECKSUM"
