set -e
set +x

rm -rf build
mkdir build
cp -a ../dist build

docker build . --tag s3-manager:latest

rm -rf build