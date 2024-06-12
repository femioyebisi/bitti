# Use Debian Bookworm slim image as a base for the builder stage
FROM debian:bookworm-slim as builder

# Set environment variables for Bitcoin Core version and URLs
ENV BITCOIN_VERSION=22.0
ENV BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-$BITCOIN_VERSION/bitcoin-$BITCOIN_VERSION-x86_64-linux-gnu.tar.gz \
    BITCOIN_SHA256=59ebd25dd82a51638b7a6bb914586201e67db67b919b2a1ff08925a7936d1b16

# Install necessary packages and verify the checksum of the downloaded Bitcoin Core tarball
RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates wget \
    && cd /tmp \
    && wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
    && echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
    && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt

# Use Debian Bookworm slim image as a base for the runtime stage
FROM debian:bookworm-slim

# Copy the necessary binaries from the builder stage
COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli /usr/local/bin/

# Create a bitcoin group and user
RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

# Set environment variable for Bitcoin data directory
ENV BITCOIN_DATA=/data

# Create the data directory, set ownership and create a symbolic link to the home directory
RUN mkdir "$BITCOIN_DATA" \
    && chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
    && ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
    && chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

# Expose the data directory as a volume
VOLUME /data

# Copy the entrypoint script into the container
COPY docker-entrypoint.sh /entrypoint.sh

# Ensure the entrypoint script is executable
RUN chmod +x /entrypoint.sh

# Switch to the bitcoin user
USER bitcoin

# Set the entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bitcoind"]