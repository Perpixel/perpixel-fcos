#!/bin/sh

set -ouex pipefail

INCLUDED_PACKAGES=(
alacritty
ansible
distrobox
emacs
fd-find
ffmpeg
ffmpeg-libs
ffmpegthumbnailer
flac
git
gnome-tweaks
htop
ifuse
irssi
kitty
libmad
libavcodec-freeworld
libva-utils
libvorbis
lm_sensors
material-icons-fonts
mesa-va-drivers-freeworld
neovim
npm
openh264
pipewire-codec-aptx
qemu
ripgrep
rclone
samba
SDL2
tmux
vdpauinfo
virt-viewer
VirtualBox
zsh
)

EXCLUDED_PACKAGES=(
libavcodec-free
libavdevice-free
libavfilter-free
libavformat-free
libavutil-free
libpostproc-free
libswresample-free
libswscale-free
mesa-va-drivers
vi
)

if [[ ${#EXCLUDED_PACKAGES[@]} -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

if [[ ${#INCLUDED_PACKAGES[@]} -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -eq 0 ]]; then
    rpm-ostree install \
        ${INCLUDED_PACKAGES[@]}

elif [[ ${#INCLUDED_PACKAGES[@]} -eq 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]}

elif [[ ${#INCLUDED_PACKAGES[@]} -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]} \
        $(printf -- "--install=%s " ${INCLUDED_PACKAGES[@]})

else
    echo "No packages to install."
fi

# nvidia

source /var/cache/akmods/nvidia-vars

rpm-ostree install \
    xorg-x11-drv-${NVIDIA_PACKAGE_NAME}-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
    nvidia-vaapi-driver \
    nvtop \
    /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
