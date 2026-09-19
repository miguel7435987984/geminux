#!/usr/bin/env bash
# ==============================================================================
# Geminux OS 0.9 LTS (Ubuntu 25.10 Kanguru) - Gerador de Imagem ISO Oficial
# ==============================================================================
# Totalmente isolado no diretório 'Geminux 0.9 LTS'
# Preserva 100% o Geminux 1.0 LTS e as tags no GitHub
# ==============================================================================

set -e

CODENAME="${CODENAME:-questing}"
MIRROR="${MIRROR:-http://archive.ubuntu.com/ubuntu/}"
KEYRING="${KEYRING:-/usr/share/keyrings/ubuntu-archive-keyring.gpg}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${SCRIPT_DIR}/build-workspace"
ROOTFS_DIR="${WORK_DIR}/rootfs"
IMAGE_DIR="${WORK_DIR}/image"
OUT_ISO="${SCRIPT_DIR}/geminux-0.9-amd64.iso"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[GEMINUX 0.9]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[GEMINUX 0.9 ✓]${NC} $1"
}

log_err() {
    echo -e "${RED}[GEMINUX 0.9 ✗]${NC} $1"
}

if [ "$EUID" -ne 0 ]; then
    log_err "Execute este script como root: sudo ./build/build-iso.sh"
    exit 1
fi

log "==> [1/6] Verificando dependências de compilação..."
DEPS="debootstrap xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin mtools dosfstools"
for dep in $DEPS; do
    if ! command -v "$dep" &>/dev/null && ! dpkg -s "$dep" >/dev/null 2>&1; then
        log "Instalando dependência necessária: $dep"
        apt-get update && apt-get install -y "$dep"
    fi
done

log "==> [2/6] Preparando workspace em ${WORK_DIR}..."
mkdir -p "${ROOTFS_DIR}" "${IMAGE_DIR}/casper" "${IMAGE_DIR}/boot/grub/x86_64-efi" "${IMAGE_DIR}/EFI/BOOT" "${IMAGE_DIR}/.disk"
echo "Geminux OS 0.9 LTS (Ubuntu 25.10 Kanguru) - Release amd64" > "${IMAGE_DIR}/.disk/info"
touch "${IMAGE_DIR}/.disk/base_installable"

if [ ! -f "${ROOTFS_DIR}/bin/bash" ]; then
    log "Limpando qualquer resquício de tentativa anterior em ${ROOTFS_DIR}..."
    rm -rf "${ROOTFS_DIR}"
    mkdir -p "${ROOTFS_DIR}"
    log "Passo: Executando debootstrap para Ubuntu 25.10 (${CODENAME}) com chaveiro oficial..."
    debootstrap --arch=amd64 --variant=minbase --keyring="${KEYRING}" "${CODENAME}" "${ROOTFS_DIR}" "${MIRROR}"
else
    log_ok "Rootfs pré-existente encontrado em ${ROOTFS_DIR}. Pulando debootstrap..."
fi

log "==> [3/6] Montando sistemas de arquivos virtuais..."
mount --bind /dev "${ROOTFS_DIR}/dev"
mount --bind /run "${ROOTFS_DIR}/run"
mount -t devpts devpts "${ROOTFS_DIR}/dev/pts"
mount -t proc proc "${ROOTFS_DIR}/proc"
mount -t sysfs sysfs "${ROOTFS_DIR}/sys"

rm -f "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 8.8.8.8" > "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 1.1.1.1" >> "${ROOTFS_DIR}/etc/resolv.conf"

cleanup() {
    log "Desmontando sistemas de arquivos virtuais..."
    umount -lf "${ROOTFS_DIR}/dev/pts" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/dev" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/run" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/proc" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/sys" 2>/dev/null || true
}
trap cleanup EXIT

log "==> [4/6] Copiando arquivos de branding e configuração para o chroot..."
mkdir -p "${ROOTFS_DIR}/tmp/geminux-build"
cp -r "${SCRIPT_DIR}/branding" "${ROOTFS_DIR}/tmp/geminux-build/"
cp -r "${SCRIPT_DIR}/config" "${ROOTFS_DIR}/tmp/geminux-build/"
cp "${SCRIPT_DIR}/build/customize.sh" "${ROOTFS_DIR}/tmp/geminux-build/customize.sh"
chmod +x "${ROOTFS_DIR}/tmp/geminux-build/customize.sh"

log "==> [5/6] Instalando pacotes essenciais, Kernel e customização no chroot..."
cat << 'EOF_CHROOT' | chroot "${ROOTFS_DIR}" /bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Fontes APT oficiais para Questing (Ubuntu 25.10)
cat << 'SOURCES' > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ questing main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ questing-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ questing-security main restricted universe multiverse
SOURCES

apt-get update

# Instalação dos pacotes oficiais
if [ -f /tmp/geminux-build/config/packages.list ]; then
    grep -v '^#' /tmp/geminux-build/config/packages.list | grep -v '^$' | xargs apt-get install -y --no-install-recommends
fi

# Executa customização do Geminux 0.9 LTS
bash /tmp/geminux-build/customize.sh

apt-get clean
EOF_CHROOT

# Extrai kernel e initrd para o diretório de boot da ISO
log "Extraindo Kernel e Initramfs para a ISO..."
VMLINUZ=$(ls -1t "${ROOTFS_DIR}/boot/vmlinuz-"* 2>/dev/null | head -n 1)
INITRD=$(ls -1t "${ROOTFS_DIR}/boot/initrd.img-"* 2>/dev/null | head -n 1)

if [ -z "${INITRD}" ] || [ ! -f "${INITRD}" ]; then
    log "Gerando initramfs para o kernel..."
    KERNEL_VER=$(ls -1 "${ROOTFS_DIR}/lib/modules" 2>/dev/null | tail -n 1)
    if [ -n "${KERNEL_VER}" ]; then
        chroot "${ROOTFS_DIR}" update-initramfs -c -k "${KERNEL_VER}"
        INITRD=$(ls -1t "${ROOTFS_DIR}/boot/initrd.img-"* 2>/dev/null | head -n 1)
    fi
fi

if [ -n "${VMLINUZ}" ] && [ -f "${VMLINUZ}" ]; then
    cp -L "${VMLINUZ}" "${IMAGE_DIR}/casper/vmlinuz"
    chmod 644 "${IMAGE_DIR}/casper/vmlinuz"
    log_ok "Kernel copiado: ${VMLINUZ}"
fi

if [ -n "${INITRD}" ] && [ -f "${INITRD}" ]; then
    cp -L "${INITRD}" "${IMAGE_DIR}/casper/initrd"
    chmod 644 "${IMAGE_DIR}/casper/initrd"
    log_ok "Initrd copiado: ${INITRD}"
fi

# Limpeza dos artefatos de build do chroot antes da compactação
rm -rf "${ROOTFS_DIR}/tmp/geminux-build"
rm -rf "${ROOTFS_DIR}/var/cache/apt/archives"/*

# Desmonta antes de rodar o mksquashfs
umount -lf "${ROOTFS_DIR}/dev/pts" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/dev" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/run" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/proc" 2>/dev/null || true
umount -lf "${ROOTFS_DIR}/sys" 2>/dev/null || true

log "==> [6/6] Criando squashfs e gerando imagem ISO híbrida ${OUT_ISO}..."
mksquashfs "${ROOTFS_DIR}" "${IMAGE_DIR}/casper/filesystem.squashfs" -comp xz -noappend -b 1M

# Configuração do GRUB de Inicialização da ISO
cat << 'EOF' > "${IMAGE_DIR}/boot/grub/grub.cfg"
set default="0"
set timeout=10

insmod all_video

menuentry "Experimentar ou Instalar o Geminux OS 0.9 LTS" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}

menuentry "Geminux OS 0.9 LTS (Modo Seguro de Gráficos)" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd /casper/initrd
}
EOF

xorriso -as mkisofs \
    -r -V "GEMINUX_0_9" \
    -J -l -b boot/grub/grub.cfg \
    -c boot/grub/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e EFI/BOOT/BOOTX64.EFI \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "${OUT_ISO}" \
    "${IMAGE_DIR}"

log_ok "ISO do Geminux 0.9 LTS gerada com sucesso em: ${OUT_ISO}"
