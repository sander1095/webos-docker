#!/bin/sh
# A named volume mounts as 0755 root-owned, which ssh rejects for key material.
chmod 700 /root/.ssh 2>/dev/null || true
for key in /root/.ssh/*; do
  [ -f "$key" ] && chmod 600 "$key" 2>/dev/null
done
exec "$@"
