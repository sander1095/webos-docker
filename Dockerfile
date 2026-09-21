FROM node:20-bookworm-slim

# openssh-client backs the device key handling in ares-novacom; curl fetches app packages.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      openssh-client \
 && rm -rf /var/lib/apt/lists/*

ARG CLI_VERSION=3.2.6
RUN npm install -g --no-fund --no-audit "@webos-tools/cli@${CLI_VERSION}"

# Device registrations land in /root/.webos and the per-device SSH key in /root/.ssh.
# Both are mounted as named volumes by compose so a registered TV survives container restarts.
RUN mkdir -p /root/.webos /root/.ssh && chmod 700 /root/.ssh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
