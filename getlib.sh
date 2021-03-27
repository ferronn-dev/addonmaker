repo="$1"
out="$2"
fetch() (
  set -e
  if echo "$repo" | grep -q "/trunk\(/\|\$\)\|/tags/"
  then
    repo=$(echo "$repo" | sed 's/svn:\/\/svn\.wowace\./https:\/\/repos\.wowace\./' | sed s'/\/mainline\//\//')
    svn checkout "$repo" "$out"
  else
    git clone --recurse-submodules "$repo" "$out"
  fi
  if [ -f "$out/build.yaml" -o -f "$out/.pkgmeta" ]
  then
    (cd "$out" && sh /addonmaker/main.sh)
  fi
)
while ! fetch
do
    rm -rf "$out"
    sleep 5
done
