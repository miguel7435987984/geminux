#!/usr/bin/env bash
# ==============================================================================
# Geminux OS - ISO Image Generator Script
# Author: Geminux Project
# Base: Ubuntu Linux
# ==============================================================================

set -e

# Configuration
CODENAME="${CODENAME:-resolute}"
MIRROR="${MIRROR:-http://archive.ubuntu.com/ubuntu/}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${SCRIPT_DIR}/build-workspace"
ROOTFS_DIR="${WORK_DIR}/rootfs"
IMAGE_DIR="${WORK_DIR}/image"
OUT_ISO="${SCRIPT_DIR}/geminux-1.0-amd64.iso"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[GEMINUX]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[GEMINUX ✓]${NC} $1"
}

log_err() {
    echo -e "${RED}[GEMINUX ✗]${NC} $1"
}

# Require Root
if [ "$EUID" -ne 0 ]; then
    log_err "Please run this build script as root (sudo ./build/build-iso.sh)"
    exit 1
fi

# Check Dependencies
log "Checking required build tools..."
DEPS="debootstrap xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin mtools dosfstools"
for dep in $DEPS; do
    if ! dpkg -s "$dep" >/dev/null 2>&1; then
        log "Installing missing dependency: $dep"
        apt-get update && apt-get install -y "$dep"
    fi
done

# Prepare Workspace
log "Preparing build directory at ${WORK_DIR}..."
rm -rf "${WORK_DIR}"
mkdir -p "${ROOTFS_DIR}" "${IMAGE_DIR}/casper" "${IMAGE_DIR}/boot/grub/x86_64-efi" "${IMAGE_DIR}/EFI/BOOT"

# Step 1: Debootstrap Rootfs
log "Step 1: Running debootstrap for Ubuntu (${CODENAME})..."
debootstrap --arch=amd64 --variant=minbase "${CODENAME}" "${ROOTFS_DIR}" "${MIRROR}"

# Step 2: Setup Mounts for Chroot
log "Step 2: Mounting virtual filesystems for chroot..."
mount --bind /dev "${ROOTFS_DIR}/dev"
mount --bind /run "${ROOTFS_DIR}/run"
mount -t devpts devpts "${ROOTFS_DIR}/dev/pts"
mount -t proc proc "${ROOTFS_DIR}/proc"
mount -t sysfs sysfs "${ROOTFS_DIR}/sys"

# Setup DNS inside chroot
rm -f "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 8.8.8.8" > "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 1.1.1.1" >> "${ROOTFS_DIR}/etc/resolv.conf"

cleanup() {
    log "Cleaning up mounts..."
    umount -lf "${ROOTFS_DIR}/dev/pts" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/dev" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/run" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/proc" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/sys" 2>/dev/null || true
}
trap cleanup EXIT

# Copy Geminux assets into chroot
mkdir -p "${ROOTFS_DIR}/tmp/geminux-build"
cp -r "${SCRIPT_DIR}/apps" "${ROOTFS_DIR}/tmp/geminux-build/"
cp -r "${SCRIPT_DIR}/branding" "${ROOTFS_DIR}/tmp/geminux-build/"
cp -r "${SCRIPT_DIR}/config" "${ROOTFS_DIR}/tmp/geminux-build/"
cp -r "${SCRIPT_DIR}/installer" "${ROOTFS_DIR}/tmp/geminux-build/"
cp "${SCRIPT_DIR}/build/live-hooks/customize.sh" "${ROOTFS_DIR}/tmp/geminux-build/"
cp "${SCRIPT_DIR}/build/packages.list" "${ROOTFS_DIR}/tmp/geminux-build/"

# Step 3: Install Packages inside Chroot
log "Step 3: Installing packages and kernel inside chroot..."
cat <<EOF | chroot "${ROOTFS_DIR}" /bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Sources list
cat <<SOURCES > /etc/apt/sources.list
deb ${MIRROR} ${CODENAME} main restricted universe multiverse
deb ${MIRROR} ${CODENAME}-updates main restricted universe multiverse
deb ${MIRROR} ${CODENAME}-security main restricted universe multiverse
SOURCES

apt-get update

# Install packages
grep -v '^#' /tmp/geminux-build/packages.list | grep -v '^$' | xargs apt-get install -y --no-install-recommends

# Run Geminux Customization Hook
bash /tmp/geminux-build/customize.sh

# Clean package cache (keep lists so Geminux Store has instant catalog)
apt-get clean
EOF

# Step 4: Extract Kernel & Initrd for Boot
log "Step 4: Extracting kernel and initramfs to ISO image..."
VMLINUZ=$(ls -1t "${ROOTFS_DIR}/boot/vmlinuz-"* 2>/dev/null | head -n 1)
INITRD=$(ls -1t "${ROOTFS_DIR}/boot/initrd.img-"* 2>/dev/null | head -n 1)

if [ -z "${INITRD}" ] || [ ! -f "${INITRD}" ]; then
    log "Generating initrd for kernel..."
    KERNEL_VER=$(ls -1 "${ROOTFS_DIR}/lib/modules" | tail -n 1)
    chroot "${ROOTFS_DIR}" update-initramfs -c -k "${KERNEL_VER}"
    INITRD=$(ls -1t "${ROOTFS_DIR}/boot/initrd.img-"* 2>/dev/null | head -n 1)
fi

log "Kernel found: ${VMLINUZ}"
log "Initramfs found: ${INITRD}"

cp "${VMLINUZ}" "${IMAGE_DIR}/casper/vmlinuz"
cp "${INITRD}" "${IMAGE_DIR}/casper/initrd"

# Step 5: Clean Chroot & Unmount Virtual FS before SquashFS
log "Step 5: Cleaning up rootfs and unmounting virtual filesystems..."
rm -rf "${ROOTFS_DIR}/tmp/geminux-build"
rm -rf "${ROOTFS_DIR}/var/cache/apt/archives"/*
rm -rf "${ROOTFS_DIR}/tmp"/*

# Explicitly unmount virtual fs so mksquashfs only compresses real files
umount -lf "${ROOTFS_DIR}/dev/pts" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/dev" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/run" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/proc" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/sys" 2>/dev/null || true

# Step 6: Create SquashFS Image
log "Step 6: Compressing root filesystem into filesystem.squashfs..."
mksquashfs "${ROOTFS_DIR}" "${IMAGE_DIR}/casper/filesystem.squashfs" -noappend -comp xz -b 1048576 -Xdict-size 100%

# Calculate filesystem size
printf $(du -sx --block-size=1 "${ROOTFS_DIR}" | cut -f1) > "${IMAGE_DIR}/casper/filesystem.size"

# Step 7: Configure GRUB Bootloader for ISO
log "Step 7: Generating GRUB boot configurations..."
cat <<EOF > "${IMAGE_DIR}/boot/grub/grub.cfg"
search --set=root --file /casper/vmlinuz
set default="0"
set timeout=5

insmod font
if loadfont /boot/grub/font.pf2 ; then
    insmod gfxterm
    set gfxmode=auto
    terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=cyan/black

menuentry "Try or Install Geminux OS (Live)" {
    set gfxpayload=keep
    linux   /casper/vmlinuz boot=casper quiet splash ---
    initrd  /casper/initrd
}

menuentry "Geminux OS (Safe Graphics)" {
    set gfxpayload=keep
    linux   /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd  /casper/initrd
}

menuentry "Check disc for defects" {
    linux   /casper/vmlinuz boot=casper integrity-check quiet splash ---
    initrd  /casper/initrd
}

menuentry "Boot from next volume" {
    exit
}
EOF

# Embedded early grub config for EFI to locate CD-ROM root
cat <<EOF > "${WORK_DIR}/early-grub.cfg"
search --set=root --file /casper/vmlinuz
set prefix=(\$root)/boot/grub
configfile \$prefix/grub.cfg
EOF

# Step 8: Build EFI Boot image & Hybrid BIOS Boot
log "Step 8: Setting up EFI boot loader and BIOS boot..."

# Copy GRUB modules to ISO so normal.mod is always available for BIOS & EFI
mkdir -p "${IMAGE_DIR}/boot/grub/i386-pc" "${IMAGE_DIR}/boot/grub/x86_64-efi"
cp -r /usr/lib/grub/i386-pc/* "${IMAGE_DIR}/boot/grub/i386-pc/" 2>/dev/null || true
cp -r /usr/lib/grub/x86_64-efi/* "${IMAGE_DIR}/boot/grub/x86_64-efi/" 2>/dev/null || true

grub-mkstandalone \
    --format=x86_64-efi \
    --output="${IMAGE_DIR}/EFI/BOOT/BOOTX64.EFI" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=${WORK_DIR}/early-grub.cfg"

# Create FAT image for EFI
dd if=/dev/zero of="${IMAGE_DIR}/boot/grub/efi.img" bs=1M count=10
mkfs.vfat "${IMAGE_DIR}/boot/grub/efi.img"
mmd -i "${IMAGE_DIR}/boot/grub/efi.img" ::EFI
mmd -i "${IMAGE_DIR}/boot/grub/efi.img" ::EFI/BOOT
mcopy -i "${IMAGE_DIR}/boot/grub/efi.img" "${IMAGE_DIR}/EFI/BOOT/BOOTX64.EFI" ::EFI/BOOT/

# Build BIOS i386-pc core image with standard cdboot for El Torito
grub-mkimage \
    --format=i386-pc-eltorito \
    --output="${IMAGE_DIR}/boot/grub/bios.img" \
    --prefix=/boot/grub \
    iso9660 biosdisk search search_fs_file normal test

# Step 9: Generate Universal Hybrid ISO with xorriso
log "Step 9: Creating Bootable ISO: ${OUT_ISO}..."
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "GEMINUX_OS" \
    -eltorito-boot boot/grub/bios.img \
    -eltorito-catalog boot/grub/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -output "${OUT_ISO}" \
    "${IMAGE_DIR}"

log_ok "Geminux OS ISO generated successfully: ${OUT_ISO}"
log_ok "To test the ISO in QEMU: qemu-system-x86_64 -enable-kvm -m 4G -cdrom ${OUT_ISO} -boot d"
