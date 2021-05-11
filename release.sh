#!/bin/sh
set -e
file=$(echo *.zip)
mkdir -p /tmp/rel/old
unzip -q -d /tmp/rel/new "$file"
if gh release download -D /tmp/rel/rel latest; then
  echo 'Checking existing release...'
  unzip -q -d /tmp/rel/old "/tmp/rel/rel/$file"
  if diff -qrN /tmp/rel/old /tmp/rel/new; then
    echo 'No difference since last release.'
    exit 0
  fi
  echo 'Deleting existing release...'
  gh release delete latest < /dev/null
fi
echo 'Creating new release...'
(cd /tmp/rel;
 echo '```';
 git diff --no-index --stat=120 old new || true;
 echo '```') > /tmp/thediff.md
gh release create -t latest -F /tmp/thediff.md latest
gh release upload latest "$file"
echo 'Done.'
