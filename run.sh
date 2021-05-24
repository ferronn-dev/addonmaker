set -e
echo 'Building addonmaker...'
if [ -z $ADDONMAKER_BUILDCACHE ]; then
  docker buildx build --iidfile=/tmp/iid.$$ --load addonmaker
  image=$(cat /tmp/iid.$$)
else
  image=addonmaker.$$
  docker buildx build -t $image --load \
      --cache-from=type=local,src=$ADDONMAKER_BUILDCACHE \
      --cache-to=type=local,dest=$ADDONMAKER_BUILDCACHE \
      addonmaker
fi
echo 'Running addonmaker...'
docker run --rm -t -v "$PWD:/addon" -u `id -u`:`id -g` --net host $image "$@"
echo 'Done.'
