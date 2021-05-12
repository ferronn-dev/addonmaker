#!/bin/sh
set -e
file=$(echo *.zip)
mkdir -p /tmp/rel/old
unzip -q -d /tmp/rel/new "$file"
echo 'Checking for existing release...'
if tag=$(gh api repos/:owner/:repo/releases/latest --jq .tag_name); then
  echo "Found release '$tag'. Checking for diffs..."
  gh release download -D /tmp/rel/rel "$tag"
  unzip -q -d /tmp/rel/old "/tmp/rel/rel/$file"
  if diff -qrN /tmp/rel/old /tmp/rel/new; then
    echo 'No difference since last release.'
    exit 0
  fi
else
  echo 'No existing release.'
  tag=v0
fi
newtag=v$(($(echo "$tag" | tr -d v) + 1))
echo "Creating new release '$newtag'..."
(cd /tmp/rel;
 echo '```';
 git diff --no-index --stat=120 old new || true;
 echo '```') > /tmp/thediff.md
gh release create -t "$newtag" -F /tmp/thediff.md "$newtag"
gh release upload "$newtag" "$file"
echo 'Done.'
