# fcitx5 frontend for the Karukan Japanese IME.
# https://github.com/togatoga/karukan
#
# The source is pinned by the `karukan` flake input. When updating it,
# refresh `cargoDeps.hash` (build once with lib.fakeHash to get the new value).
{
  lib,
  stdenv,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  pkg-config,
  kdePackages,
  fcitx5,
  libxkbcommon,
  clang,
  llvmPackages,
  src,
  rev ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-karukan";
  version = "0.1.0${lib.optionalString (rev != null) "+${builtins.substring 0 7 rev}"}";

  inherit src;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-ZsO9FZ2GotgsoB9Nb9mSqZzGCIkfc3tX5XUWv5rqzFg=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    clang
  ];

  buildInputs = [
    fcitx5
    libxkbcommon
  ];

  env = {
    # bindgen (llama-cpp-sys-2) needs libclang.
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    # Don't build with -C target-cpu=native so the result is reproducible.
    KARUKAN_NATIVE = "OFF";
  };

  # CMake drives the Rust build through cargo; skip the default configure hook.
  dontUseCmakeConfigure = true;

  configurePhase = ''
    runHook preConfigure
    cd karukan-im/fcitx5/fcitx5-addon
    cmake -B build -DCMAKE_INSTALL_PREFIX="$out" -DKARUKAN_NATIVE=OFF
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build -j"$NIX_BUILD_CORES"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install build
    runHook postInstall
  '';

  meta = {
    description = "Karukan Japanese input method addon for fcitx5";
    homepage = "https://github.com/togatoga/karukan";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = lib.platforms.linux;
  };
})
