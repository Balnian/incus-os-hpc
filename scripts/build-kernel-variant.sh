#!/bin/sh

set -eu

KERNEL_VARIANT="${KERNEL_VARIANT:-base}"
KERNEL_PACKAGE="${KERNEL_PACKAGE:-linux-image-zabbly}"
KERNEL_HEADERS_PACKAGE="${KERNEL_HEADERS_PACKAGE:-linux-zabbly}"

mkdir -p mkosi.sandbox/etc/apt/sources.list.d mkosi.sandbox/etc/apt/keyrings

# Use the official CachyOS repository signing key, pinned by the upstream keyring payload
# instead of disabling apt verification for the entire repo.
case "$KERNEL_VARIANT" in
    base)
        rm -f mkosi.sandbox/etc/apt/sources.list.d/cachyos-*.sources
        rm -f mkosi.sandbox/etc/apt/keyrings/cachyos-archive-keyring.gpg
        ;;
    x86-64-v3)
        curl -fsSL https://mirror.cachyos.org/repo/x86_64_v3/cachyos.gpg -o mkosi.sandbox/etc/apt/keyrings/cachyos-archive-keyring.gpg
        cat <<'EOF' > mkosi.sandbox/etc/apt/sources.list.d/cachyos-v3.sources
Enabled: yes
Types: deb
URIs: https://mirror.cachyos.org/repo/x86_64_v3/cachyos-v3
Suites: cachyos
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/cachyos-archive-keyring.gpg
EOF
        ;;
    x86-64-v4)
        curl -fsSL https://mirror.cachyos.org/repo/x86_64_v4/cachyos.gpg -o mkosi.sandbox/etc/apt/keyrings/cachyos-archive-keyring.gpg
        cat <<'EOF' > mkosi.sandbox/etc/apt/sources.list.d/cachyos-v4.sources
Enabled: yes
Types: deb
URIs: https://mirror.cachyos.org/repo/x86_64_v4/cachyos-v4
Suites: cachyos
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/cachyos-archive-keyring.gpg
EOF
        ;;
    zen4)
        curl -fsSL https://mirror.cachyos.org/repo/x86_64_v4/cachyos.gpg -o mkosi.sandbox/etc/apt/keyrings/cachyos-archive-keyring.gpg
        cat <<'EOF' > mkosi.sandbox/etc/apt/sources.list.d/cachyos-znver4.sources
Enabled: yes
Types: deb
URIs: https://mirror.cachyos.org/repo/x86_64_v4/cachyos-znver4
Suites: cachyos
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/cachyos-archive-keyring.gpg
EOF
        ;;
    *)
        echo "Unsupported kernel variant: ${KERNEL_VARIANT}" >&2
        exit 1
        ;;
esac

cat <<EOF > mkosi.images/base/mkosi.conf.d/01-kernel.conf
[Content]
# This file is rewritten by the build system for the requested kernel profile.
# Supported profiles: base, x86-64-v3, x86-64-v4, zen4.
Packages=
    kmod
    ${KERNEL_PACKAGE}
    systemd-boot-efi
BuildPackages=
    gcc
    libelf1
    ${KERNEL_HEADERS_PACKAGE}
Bootable=false

# Profile metadata retained for downstream tooling.
# variant=${KERNEL_VARIANT}
EOF
