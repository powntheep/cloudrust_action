####################################################################################################
## Builder
####################################################################################################
FROM rust:latest AS builder

RUN update-ca-certificates

# ARG VERS="23.2"
# ARG ARCH="osx-universal_binary"

RUN apt update && apt -y install wget && apt -y install protobuf-compiler
# \
#     wget https://github.com/protocolbuffers/protobuf/releases/download/v${VERS}/protoc-${VERS}-${ARCH}.zip \
#     --output-document=/protoc-${VERS}-${ARCH}.zip && \
#     apt update && apt install -y unzip && \
#     unzip -o protoc-${VERS}-${ARCH}.zip -d /protoc-${VERS}-${ARCH}
# ENV PATH="${PATH}:/protoc-${VERS}-${ARCH}/bin"

# RUN echo "${PATH}:/protoc-${VERS}-${ARCH}/bin"

RUN protoc --help

WORKDIR /cloudrust_action

COPY ./ .

# We no longer need to use the x86_64-unknown-linux-musl target
RUN cargo install --path . 
RUN which cloudrust_action

####################################################################################################
## Final image
####################################################################################################
FROM gcr.io/distroless/cc

# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /cloudrust_action

# Copy our build
COPY --from=builder /usr/local/cargo/bin/cloudrust_action .

# Use an unprivileged user.
ENTRYPOINT ["./cloudrust_action"]