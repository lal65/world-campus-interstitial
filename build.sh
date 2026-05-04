#!/usr/bin/env bash

set -euo pipefail

# Allow a prefix to be passed in, falling back to an empty string if not
# provided. This allows the build process to generate release artifacts for
# multiple hosting platforms.
#
# For example, GitHub Pages needs a prefix of the repository name.
asset_prefix="${1:-}"

# Remove a leading slash from the prefix (if applicable).
asset_prefix="${asset_prefix#/}"

# Remove a trailing slash from the prefix (if applicable).
asset_prefix="${asset_prefix%/}"

# Create the output directory if it doesn't already exist.
mkdir -p dist/

# Copy simple assets over.
cp src/robots.txt "dist/"
cp src/psu-mark.svg "dist/"
cp src/wc-mark.svg "dist/"

# Aggregate CSS by concatenating upstream dependencies and overrides.
cat node_modules/@psu-online-education/*/dist/styles.css > "dist/interstitial.css"
cat src/overrides.css >> "dist/interstitial.css"

# Compile the HTML by using gzip compression on the partials and base64
# encoding them into the page source. This is needed because Cloudflare limits
# us to 10kB for managed challenge DOM sizes.

mkdir -p build/
cp src/_before_begin_main.html build/
cp src/_after_begin_main.html build/
cp src/_before_end_main.html build/
cp src/_after_end_main.html build/

sed -i "s|::ASSET_PREFIX::|${asset_prefix:+/$asset_prefix}|" build/_before_begin_main.html
sed -i "s|::ASSET_PREFIX::|${asset_prefix:+/$asset_prefix}|" build/_after_begin_main.html
sed -i "s|::ASSET_PREFIX::|${asset_prefix:+/$asset_prefix}|" build/_before_end_main.html
sed -i "s|::ASSET_PREFIX::|${asset_prefix:+/$asset_prefix}|" build/_after_end_main.html


cp src/index.html dist/
sed -i "s|::ASSET_PREFIX::|${asset_prefix:+/$asset_prefix}|" dist/index.html

sed -i "s|::BEFORE_BEGIN_MAIN::|$(gzip -9c build/_before_begin_main.html | base64 -w 0)|" dist/index.html
sed -i "s|::AFTER_BEGIN_MAIN::|$(gzip -9c build/_after_begin_main.html | base64 -w 0)|" dist/index.html
sed -i "s|::BEFORE_END_MAIN::|$(gzip -9c build/_before_end_main.html | base64 -w 0)|" dist/index.html
sed -i "s|::AFTER_END_MAIN::|$(gzip -9c build/_after_end_main.html | base64 -w 0)|" dist/index.html
