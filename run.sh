set -e
tag="$(basename $PWD)-maker"
echo 'Building addonmaker...'
if ! docker buildx build -t "$tag" --cache-from=type=local,src=$HOME/.docker-cache --cache-to=type=local,mode=max,dest=$HOME/.docker-cache addonmaker 2>/tmp/buildx.err.$$; then
  cat /tmp/buildx.err.$$
  rm /tmp/buildx.err.$$
  exit 1
fi
echo 'Running addonmaker...'
docker run --rm -t -v "$PWD:/addon" -u `id -u`:`id -g` --net host "$tag"
echo 'Done.'
