set -e
set +x

rm -rf build
mkdir build
cp -a ../dist build

docker build . --tag s3-object-manager:latest
docker build . -t ghcr.io/mtseet/s3-object-manager:latest

rm -rf build