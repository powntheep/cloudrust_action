docker buildx build --platform="linux/amd64" \
  --tag=gcr.io/milk-platform-service/cloudrust:latest \
  --file=./Dockerfile \
  .