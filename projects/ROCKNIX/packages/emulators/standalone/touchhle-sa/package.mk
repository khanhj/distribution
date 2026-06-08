# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="touchhle-sa"
PKG_LICENSE="MPLv2"
PKG_VERSION="3c5850585ba55615b17a58c58331b6d6f52d4a9d"
PKG_SITE="https://github.com/touchHLE/touchHLE"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust SDL2 sndio libsamplerate"
PKG_LONGDESC="touchHLE: high-level emulator for iPhone OS apps"
PKG_TOOLCHAIN="manual"
PKG_ARCH="aarch64"

post_unpack() {
  cd ${PKG_BUILD}/vendor/openal-soft
  sed -i 's/false,/AL_FALSE_ENUM,/g' alc/backends/sdl2.c 2>/dev/null || true
  sed -i 's/enum CompatFlags : uint8_t/enum CompatFlags/g' alc/alu.h
  sed -i 's/enum class UhjQualityType : uint8_t/enum UhjQualityType/g' core/uhjfilter.h
 # Disable JACK backend (avoids needing jack/jack.h in sysroot)
  sed -i '/build.define("ALSOFT_EXAMPLES", "OFF");/a\  build.define("ALSOFT_BACKEND_JACK", "OFF");' ${PKG_BUILD}/src/audio/openal_soft_wrapper/build.rs

  # Unpack pre-vendored Rust crates (build server has no internet for cargo fetch)
  if [ -f "${SOURCES}/touchhle-sa/touchhle-rust-vendor.tar.gz" ]; then
    tar xf "${SOURCES}/touchhle-sa/touchhle-rust-vendor.tar.gz" -C "${PKG_BUILD}/"
    cat >> "${PKG_BUILD}/.cargo/config.toml" << 'ENDCARGO'

[source.crates-io]
replace-with = "vendored-sources"

[source."git+https://github.com/touchHLE/rust-sdl2?tag=touchHLE-3#b67f98fe6a147773b6f05d50ae775d9fe16561e7"]
git = "https://github.com/touchHLE/rust-sdl2"
tag = "touchHLE-3"
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "rust-vendor"
ENDCARGO
  fi
}

make_target() {
  unset CMAKE
  export RUSTFLAGS="-C link-arg=-lasound"
  export CMAKE_POLICY_VERSION_MINIMUM="3.5"
  export CFLAGS="${CFLAGS} -std=gnu11"

  export CMAKE_ARGS="${CMAKE_ARGS} -DALSOFT_BACKEND_JACK=OFF"

  # FIXCONFIG modifies config.sub in vendored packages; update checksums to match
  for csub in rust-vendor/sdl2-sys/SDL/build-scripts/config.sub \
               rust-vendor/sdl2-sys/SDL/build-scripts/config.guess; do
    [ -f "$csub" ] || continue
    pkg_dir=$(dirname $(dirname $(dirname $csub)))
    checksum_file="${pkg_dir}/.cargo-checksum.json"
    [ -f "$checksum_file" ] || continue
    rel="${csub#${pkg_dir}/}"
    new_hash=$(sha256sum "$csub" | cut -d' ' -f1)
    python3 -c "
import json
cf = '${checksum_file}'
d = json.load(open(cf))
d['files']['${rel}'] = '${new_hash}'
json.dump(d, open(cf, 'w'))
"
  done

  cargo build \
    --target ${TARGET_NAME} \
    --release
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/touchHLE ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs
  cp -rf ${PKG_BUILD}/touchHLE_dylibs/lib* ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs/
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_fonts/LiberationSans-* ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_default_options.txt ${INSTALL}/usr/lib/touchHLE/
  mkdir -p ${INSTALL}/usr/config/touchHLE
  cp -rf ${PKG_BUILD}/touchHLE_options.txt ${INSTALL}/usr/config/touchHLE/
  chmod +x ${INSTALL}/usr/bin/*
}
