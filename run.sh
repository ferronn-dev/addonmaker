set -e
echo 'Building addonmaker...'
if [ -z $ADDONMAKER_BUILDCACHE ]; then
  docker buildx build --platform linux/amd64 --iidfile=/tmp/iid.$$ --load addonmaker
  image=$(cat /tmp/iid.$$)
else
  image=addonmaker.$$
  docker buildx build --platform linux/amd64 -t $image --load \
      --cache-from=type=local,src=$ADDONMAKER_BUILDCACHE \
      --cache-to=type=local,dest=$ADDONMAKER_BUILDCACHE \
      addonmaker
fi
echo 'Running addonmaker...'
docker run --platform linux/amd64 --rm -t -v "$PWD:/addon" -u `id -u`:`id -g` --net host $image "$@"
echo 'Done.'
