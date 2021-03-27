repo="$1"
out="$2"
fetch() (
  set -e
  if echo "$repo" | grep /trunk$
  then
    svn checkout "$repo" "$out"
  else
    git clone --recurse-submodules "$repo" "$out"
  fi
  if [ -f "$out/build.yaml" ]
  then
    (cd "$out" && sh /addonmaker/main.sh)
  fi
)
while ! fetch
do
    rm -rf "$out"
    sleep 5
done
