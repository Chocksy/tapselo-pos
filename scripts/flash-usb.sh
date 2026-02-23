#!/bin/bash
# =============================================================================
# Flash Tapselo POS USB Image from GitHub Releases
# =============================================================================
# Downloads the image, streams it to USB, then deletes it to save disk space.
#
# Usage:
#   ./flash-usb.sh              # Flash latest release
#   ./flash-usb.sh v0.6.1       # Flash specific version
#
# If download hangs, download manually in browser from:
#   https://github.com/Chocksy/tapselo-pos/releases
# Then move the .img.gz to /tmp/ and re-run — script skips download.
# =============================================================================

set -euo pipefail

GITHUB_REPO="Chocksy/tapselo-pos"
TMP_DIR="/tmp"
TOTAL_STEPS=5

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

step() { echo -e "\n${BOLD}${GREEN}━━━ Step $1/${TOTAL_STEPS}: $2 ━━━${NC}"; }
log()  { echo -e "${GREEN}[FLASH]${NC} $1"; }
info() { echo -e "${CYAN}  ➜${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ━━━ Step 1: Resolve version ━━━
step 1 "Resolve version"

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
    log "Fetching latest release..."
    VERSION=$(gh release view --repo "$GITHUB_REPO" --json tagName --jq '.tagName') \
        || err "Failed to get latest release. Is 'gh' installed and authenticated?"
fi
VERSION_NUM="${VERSION#v}"
IMAGE_NAME="pos-usb-v${VERSION_NUM}.img.gz"
IMAGE_PATH="${TMP_DIR}/${IMAGE_NAME}"

log "Version: ${BOLD}${VERSION}${NC}"
log "Image:   ${IMAGE_NAME}"

# Verify asset exists in release
ASSET_EXISTS=$(gh release view "$VERSION" --repo "$GITHUB_REPO" --json assets \
    --jq ".assets[] | select(.name == \"${IMAGE_NAME}\") | .name" 2>/dev/null) || true

[[ -z "$ASSET_EXISTS" ]] && err "No USB image '${IMAGE_NAME}' found in release ${VERSION}.
Available assets:
$(gh release view "$VERSION" --repo "$GITHUB_REPO" --json assets --jq '.assets[].name' 2>/dev/null)"

# ━━━ Step 2: Select target disk ━━━
step 2 "Select target disk"

info "Available external disks:"
echo ""
if [[ "$(uname)" == "Darwin" ]]; then
    diskutil list external 2>/dev/null || diskutil list
else
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
fi

echo ""
warn "This will ${BOLD}ERASE${NC}${YELLOW} the target disk!${NC}"
echo -n "Enter target device (e.g., /dev/disk4 on macOS, /dev/sdX on Linux): "
read -r TARGET_DISK
[[ -z "$TARGET_DISK" ]] && err "No target specified."

# Safety: reject system disks
if [[ "$(uname)" == "Darwin" ]]; then
    [[ "$TARGET_DISK" == "/dev/disk0" || "$TARGET_DISK" == "/dev/disk1" ]] && \
        err "Refusing to write to system disk $TARGET_DISK"
else
    [[ "$TARGET_DISK" == "/dev/sda" || "$TARGET_DISK" == "/dev/nvme0n1" ]] && \
        err "Refusing to write to system disk $TARGET_DISK"
fi

echo ""
warn "About to ERASE ${BOLD}${TARGET_DISK}${NC}${YELLOW} and write POS image ${VERSION}${NC}"
echo -n "Type YES to confirm: "
read -r CONFIRM
[[ "$CONFIRM" != "YES" ]] && err "Aborted."

# ━━━ Step 3: Download image ━━━
step 3 "Download image"

if [[ -f "$IMAGE_PATH" ]]; then
    log "Already downloaded: ${IMAGE_PATH} ($(du -h "$IMAGE_PATH" | cut -f1))"
else
    # Get the direct download URL from GitHub release
    DOWNLOAD_URL=$(gh release view "$VERSION" --repo "$GITHUB_REPO" --json assets \
        --jq ".assets[] | select(.name == \"${IMAGE_NAME}\") | .url" 2>/dev/null) || true

    MANUAL_MSG="Download manually from:
  https://github.com/${GITHUB_REPO}/releases/tag/${VERSION}
Then: mv ~/Downloads/${IMAGE_NAME} ${IMAGE_PATH}"

    if [[ -n "$DOWNLOAD_URL" ]]; then
        GH_TOKEN=$(gh auth token 2>/dev/null) || true
        log "Downloading via curl (${BOLD}~1.5 GB${NC}, progress bar below)..."
        curl -L --progress-bar \
            -H "Accept: application/octet-stream" \
            ${GH_TOKEN:+-H "Authorization: Bearer ${GH_TOKEN}"} \
            -o "$IMAGE_PATH" \
            "$DOWNLOAD_URL" \
            || err "Download failed. ${MANUAL_MSG}"
    else
        gh release download "$VERSION" --repo "$GITHUB_REPO" \
            --pattern "$IMAGE_NAME" --dir "$TMP_DIR" \
            || err "Download failed. ${MANUAL_MSG}"
    fi

    log "Downloaded: $(du -h "$IMAGE_PATH" | cut -f1)"
fi

# ━━━ Step 4: Flash to USB ━━━
step 4 "Flash to USB"

COMPRESSED_SIZE=$(stat -f%z "$IMAGE_PATH" 2>/dev/null || stat -c%s "$IMAGE_PATH" 2>/dev/null)
log "Compressed image: $(du -h "$IMAGE_PATH" | cut -f1)"

# Prime sudo credentials BEFORE the pipeline so password prompt
# doesn't get mixed into the pv progress bar output
log "Requesting sudo access for disk write..."
sudo -v || err "sudo authentication failed"

HAS_PV=false
if command -v pv &>/dev/null; then
    HAS_PV=true
fi

if [[ "$(uname)" == "Darwin" ]]; then
    RAW_DISK="${TARGET_DISK/disk/rdisk}"
    diskutil unmountDisk "$TARGET_DISK" || true

    if $HAS_PV; then
        log "Flashing to ${BOLD}${RAW_DISK}${NC} with progress bar..."
        pv -petab -s "$COMPRESSED_SIZE" "$IMAGE_PATH" | gunzip | sudo dd of="$RAW_DISK" bs=4m 2>/dev/null
    else
        log "Flashing to ${RAW_DISK} (install 'pv' for progress bar: brew install pv)..."
        gunzip -c "$IMAGE_PATH" | sudo dd of="$RAW_DISK" bs=4m status=progress
    fi
    sync
    diskutil eject "$TARGET_DISK"
else
    if $HAS_PV; then
        log "Flashing to ${BOLD}${TARGET_DISK}${NC} with progress bar..."
        pv -petab -s "$COMPRESSED_SIZE" "$IMAGE_PATH" | gunzip | sudo dd of="$TARGET_DISK" bs=4M conv=fsync 2>/dev/null
    else
        log "Flashing to ${TARGET_DISK} (install 'pv' for progress bar: apt install pv)..."
        gunzip -c "$IMAGE_PATH" | sudo dd of="$TARGET_DISK" bs=4M status=progress conv=fsync
    fi
    sync
fi

# ━━━ Step 5: Cleanup ━━━
step 5 "Cleanup"

log "Deleting downloaded image to save disk space..."
rm -f "$IMAGE_PATH"
log "Deleted ${IMAGE_PATH}"

echo ""
echo -e "${BOLD}${GREEN}━━━ ✔ Done! USB stick is ready to boot. ━━━${NC}"
echo ""
info "At the store:"
info "  1. Plug USB into PC"
info "  2. Boot from USB (F12/F2/Del for boot menu)"
info "  3. POS kiosk starts automatically"
info "  4. Logs: /home/pos/.local/share/com.tapselo.pos/logs/pos-app.log"
info "  5. SSH: ssh pos@<ip> (password: pos)"
