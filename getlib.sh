repo="$1"
out="$2"
fetch() {
  if echo "$repo" | grep -q "/trunk\(/\|\$\)\|/tags/"
  then
    repo=$(echo "$repo" | sed 's/svn:\/\/svn\.wowace\./https:\/\/repos\.wowace\./' | sed s'/\/mainline\//\//')
    if ! svn checkout "$repo" "$out"
    then
      return 1
    fi
  else
    if ! git clone --recurse-submodules "$repo" "$out"
    then
      return 1
    fi
  fi
  if [ -f "$out/build.yaml" ] || [ -f "$out/.pkgmeta" ]
  then
    if ! (cd "$out" && sh /addonmaker/main.sh); then
      # Die on unrecoverable errors, say a test failure.
      exit 1
    fi
  else
    return 0
  fi
}
while ! fetch
do
  rm -rf "$out"
  sleep 5
done
