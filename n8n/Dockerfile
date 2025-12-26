FROM n8nio/n8n:latest
USER root
# Reinstall apk-tools since n8n removes it
RUN ARCH=$(uname -m) && \
    wget -qO- "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[^"]*\.apk"' | head -1 | cut -d'"' -f2 | \
    xargs -I {} wget -q "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/{}" && \
    tar -xzf apk-tools-static-*.apk && \
    ./sbin/apk.static -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-*.apk
# Now apk works normally - install your packages
RUN apk add --no-cache \
    ffmpeg \
    imagemagick \
    exiftool \
    mediainfo \
    sox \
    ghostscript \
    python3 \
    py3-pip \
    && rm -rf /var/cache/apk/*
# Install Python libraries for advanced media processing
RUN pip3 install --no-cache-dir --break-system-packages \
    pydub \
    Pillow \
    && rm -rf /root/.cache
# Create media directories with proper permissions for node user
RUN mkdir -p /data/media /data/temp && \
    chown -R 1000:1000 /data/media /data/temp && \
    chmod 775 /data/media /data/temp
USER node
WORKDIR /data
