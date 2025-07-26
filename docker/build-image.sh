set -e
set +x

BUILD_GHCR_IMAGES=$1

rm -rf build
mkdir build
cp -a ../dist build

docker build . --tag s3-object-manager:latest

if [[ -n "$BUILD_GHCR_IMAGES" ]]; then
    echo "Building ghci.io images"
    VERSION=$(grep VERSION ../.env.production | cut -d '=' -f 2)
    docker build . -t ghcr.io/mtseet/s3-object-manager:latest
    docker build . -t ghcr.io/mtseet/s3-object-manager:$VERSION    
    echo docker push ghcr.io/mtseet/s3-object-manager:latest
    echo docker push ghcr.io/mtseet/s3-object-manager:$VERSION
fi

rm -rf build