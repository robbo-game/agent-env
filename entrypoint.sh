#!/usr/bin/env bash
set -eu

case "$AGENT_UID:$AGENT_GID" in
  *[!0-9:]*|:*|*:|0:*|*:0) echo 'AGENT_UID and AGENT_GID must be nonzero numbers' >&2; exit 1 ;;
esac

old_uid="$(id -u agent)"
old_gid="$(id -g agent)"
if [ "$old_gid" != "$AGENT_GID" ]; then /usr/sbin/groupmod -g "$AGENT_GID" agent; fi
if [ "$old_uid" != "$AGENT_UID" ]; then /usr/sbin/usermod -u "$AGENT_UID" agent; fi

# Leave the mounted authorized_keys file and other owners unchanged.
for dir in /home/agent /workspaces; do
  find "$dir" -xdev -path /home/agent/.ssh/authorized_keys -prune -o -uid "$old_uid" -exec chown -h "$AGENT_UID" {} +
  find "$dir" -xdev -path /home/agent/.ssh/authorized_keys -prune -o -gid "$old_gid" -exec chgrp -h "$AGENT_GID" {} +
done

# Read secrets in interactive and login shells without writing values to disk.
for profile in /home/agent/.bashrc /home/agent/.bash_profile; do
  for token in GH_TOKEN GHCR_TOKEN; do
    if ! grep -Fq "# agent-env $token" "$profile"; then
      cat >> "$profile" <<EOF
# agent-env $token
if [[ -r /run/secrets/$token ]]; then
    export $token="\$(cat /run/secrets/$token)"
fi
EOF
    fi
  done
done

bash /usr/local/bin/setup.sh >&2 </dev/null &
exec /usr/local/sbin/docker-entrypoint
