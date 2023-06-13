docker build \
  --tag=gcr.io/milk-platform-service/cloudrust:latest \
  --file=./Dockerfile \
  .

# docker run \
#   --interactive --tty \
#   --publish=8080:8080 \
#   --publish=8090:8090 \
#   --env=PORT="8080" \
#   gcr.io/milk-platform-service/cloudrust:latest