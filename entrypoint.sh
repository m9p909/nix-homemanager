#!/bin/bash
set -e

echo "Starting SSH server on port 22..."
exec /usr/sbin/sshd -D -e
