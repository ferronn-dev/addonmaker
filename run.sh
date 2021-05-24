set -e
echo 'Building addonmaker...'
docker buildx build --iidfile=/tmp/iid.$$ --load addonmaker
echo 'Running addonmaker...'
docker run --rm -t -v "$PWD:/addon" -u `id -u`:`id -g` --net host $(cat /tmp/iid.$$)
echo 'Done.'
