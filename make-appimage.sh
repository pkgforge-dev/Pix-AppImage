#!/bin/sh
set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export DEPLOY_GSTREAMER=1
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=/usr/share/applications/pix.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/pix.svg

export PATH_MAPPING='
	/usr/lib/pix:${SHARUN_DIR}/lib/pix
	/usr/share/pix:${SHARUN_DIR}/share/pix
'

# Keep only the thumbnailers whose binaries are bundled and patch them for PATH lookup
find /usr/share/thumbnailers/ -type f ! -name 'gst-*.thumbnailer' -delete 2>/dev/null || true
sed -i -e 's|/usr/bin/||g' /usr/share/thumbnailers/gst-*.thumbnailer 2>/dev/null || true

# Deploy dependencies
quick-sharun \
	/usr/bin/pix \
	/usr/bin/gst-video-thumbnailer \
	/usr/bin/gst-audio-thumbnailer \
	/usr/lib/pix \
	/usr/share/pix \
	/usr/share/thumbnailers

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage
quick-sharun --simple-test ./dist/*.AppImage
