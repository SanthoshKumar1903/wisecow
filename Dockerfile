FROM debian:bookworm-slim

WORKDIR /app

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fortune-mod \
    fortunes \
    cowsay \
    netcat-openbsd \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale to suppress perl warnings
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8

# Set environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH="/usr/games:${PATH}"

# Copy the wisecow script (original, unmodified)
COPY wisecow.sh .

# Make script executable
RUN chmod +x wisecow.sh

# Run as non-root user
RUN groupadd -r worker && \
    useradd -r -u 1000 -g worker -s /bin/bash worker && \
    chown -R worker:worker /app
USER worker

# Expose the service port
EXPOSE 4499

# Run the application
CMD ["./wisecow.sh"]
