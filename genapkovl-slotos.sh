#!/bin/sh -e
# Gera o "apkovl" (arquivos de configuração que entram na ISO).
# Chamado pelo mkimage com o hostname como $1.

HOSTNAME="$1"
[ -n "$HOSTNAME" ] || { echo "usage: $0 hostname"; exit 1; }
SRC="${SLOTOS_SRC:?SLOTOS_SRC não definido}"

cleanup() { rm -rf "$tmp"; }
makefile() {
	OWNER="$1"; PERMS="$2"; FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}
rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc/apk "$tmp"/usr/local/bin "$tmp"/opt

makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
eudev
udev-init-scripts
udev-init-scripts-openrc
libinput
seatd
cage
chromium
mesa-dri-gallium
mesa-egl
mesa-gles
mesa-gbm
font-dejavu
alsa-utils
alsa-lib
EOF

# tty1 roda o jogo (e reinicia sozinho se o navegador fechar)
makefile root:root 0644 "$tmp"/etc/inittab <<EOF
::sysinit:/sbin/openrc sysinit
::sysinit:/sbin/openrc boot
::wait:/sbin/openrc default
tty1::respawn:/usr/local/bin/slotgame
tty2::respawn:/sbin/getty 38400 tty2
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/openrc shutdown
EOF

# jogo e launcher
cp -r "$SRC"/jogo "$tmp"/opt/jogo
chmod -R a+rX "$tmp"/opt/jogo
cp "$SRC"/slotgame "$tmp"/usr/local/bin/slotgame
chmod 755 "$tmp"/usr/local/bin/slotgame

# serviços
rc_add devfs sysinit
rc_add dmesg sysinit
rc_add modloop sysinit
rc_add udev sysinit
rc_add udev-trigger sysinit
rc_add udev-settle sysinit
rc_add udev-postmount default

rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add hwclock boot

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc usr opt | gzip -9n > "$HOSTNAME".apkovl.tar.gz
