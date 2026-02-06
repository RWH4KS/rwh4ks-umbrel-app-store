#!/bin/sh
set -e
# Debian bookworm usually provides php-fpm as a versioned binary
if command -v php-fpm >/dev/null 2>&1; then
PHPFPM="php-fpm"
elif command -v php-fpm8.2 >/dev/null 2>&1; then
PHPFPM="php-fpm8.2"
else
echo "ERROR: php-fpm binary not found in PATH"
exit 127
fi
$PHPFPM -D
exec nginx -g "daemon off;"
