####################################################################################################
## Builder
####################################################################################################
FROM rust:latest AS builder

RUN update-ca-certificates

ARG VERS="23.2"
ARG ARCH="linux-x86_64"

RUN apt update && apt -y install wget && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v${VERS}/protoc-${VERS}-${ARCH}.zip \
    --output-document=/protoc-${VERS}-${ARCH}.zip && \
    apt update && apt install -y unzip && \
    unzip -o protoc-${VERS}-${ARCH}.zip -d /protoc-${VERS}-${ARCH}
ENV PATH="${PATH}:/protoc-${VERS}-${ARCH}/bin"

RUN which protoc

# Create appuser
ENV USER=rusted
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"


WORKDIR /rusted

COPY ./ .

# We no longer need to use the x86_64-unknown-linux-musl target
RUN cargo build --release

####################################################################################################
## Final image
####################################################################################################
FROM gcr.io/distroless/cc

# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /rusted

# Copy our build
COPY --from=builder /rusted/target/release/rusted ./

# Use an unprivileged user.
USER rusted:rusted

CMD ["/rusted/rusted"]