set -e
echo 'Building addonmaker...'
if [ -n $ADDONMAKER_IMAGE ]; then
  image=$ADDONMAKER_IMAGE
elif [ -n $ADDONMAKER_BUILDCACHE ]; then
  image=addonmaker.$$
  docker buildx build -t $image --load \
      --cache-from=type=local,src=$ADDONMAKER_BUILDCACHE \
      --cache-to=type=local,dest=$ADDONMAKER_BUILDCACHE \
      addonmaker
else
  docker buildx build --iidfile=/tmp/iid.$$ --load addonmaker
  image=$(cat /tmp/iid.$$)
fi
echo 'Running addonmaker...'
docker run --rm -t -v "$PWD:/addon" -u `id -u`:`id -g` --net host $image "$@"
echo 'Done.'
