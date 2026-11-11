# Perfil do mkimage do Alpine: "SlotOS"
profile_slotos() {
	profile_standard
	profile_abbrev="slotos"
	title="SlotOS"
	desc="Liga e abre direto o jogo Tigre da Sorte"
	arch="x86_64"
	kernel_flavors="lts"
	kernel_cmdline="console=tty1 quiet loglevel=3"
	hostname="slotos"
	apkovl="genapkovl-slotos.sh"
	apks="alpine-base alpine-baselayout busybox openrc
		eudev udev-init-scripts udev-init-scripts-openrc libinput
		seatd cage chromium
		mesa-dri-gallium mesa-egl mesa-gles mesa-gbm
		font-dejavu alsa-utils alsa-lib
		linux-firmware-i915 linux-firmware-amdgpu linux-firmware-radeon
		linux-firmware-nvidia linux-firmware-intel"
	local _k
	for _k in $kernel_flavors; do
		apks="$apks linux-$_k"
	done
}
