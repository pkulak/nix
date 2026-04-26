FROM browserless/chrome:latest

USER root

# Download and extract CloakBrowser (stealth Chromium binary)
RUN mkdir -p /opt/cloakbrowser && \
    curl -L https://github.com/CloakHQ/CloakBrowser/releases/download/chromium-v146.0.7680.177.3/cloakbrowser-linux-x64.tar.gz \
    | tar xz -C /opt/cloakbrowser

# Replace the stock Chrome binary with CloakBrowser
RUN mv /usr/bin/google-chrome /usr/bin/google-chrome.orig && \
    ln -s /opt/cloakbrowser/chrome /usr/bin/google-chrome && \
    chmod +x /opt/cloakbrowser/chrome

# CloakBrowser's chrome doesn't pass --database to crashpad_handler,
# causing it to fail. Fix: wrap the handler to inject --database.
RUN mv /opt/cloakbrowser/chrome_crashpad_handler /opt/cloakbrowser/chrome_crashpad_handler.real && \
    printf '#!/bin/sh\nmkdir -p /tmp/crashpad-db 2>/dev/null\nexec /opt/cloakbrowser/chrome_crashpad_handler.real --database=/tmp/crashpad-db "$@"\n' > /opt/cloakbrowser/chrome_crashpad_handler && \
    chmod +x /opt/cloakbrowser/chrome_crashpad_handler

# Create crashpad db dir and fontconfig cache dirs for the non-root user
RUN mkdir -p /tmp/crashpad-db && chmod 777 /tmp/crashpad-db && \
    mkdir -p /.cache/fontconfig /.fontconfig && chmod -R 777 /.cache /.fontconfig && \
    mkdir -p /var/cache/fontconfig && chmod 777 /var/cache/fontconfig

USER 1000

RUN ldd /opt/cloakbrowser/chrome 2>&1 | grep -i "not found" || true