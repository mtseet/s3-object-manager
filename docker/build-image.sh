set -e
set +x

rm -rf build
mkdir build
cp -a ../dist build

docker build . --tag s3-object-manager:latest
docker build . -t ghcr.io/mtseet/s3-object-manager:latest
docker build . -t ghcr.io/mtseet/s3-object-manager:1.0.1             
echo docker push ghcr.io/mtseet/s3-object-manager:latest
echo docker push ghcr.io/mtseet/s3-object-manager:1.0.1

rm -rf build