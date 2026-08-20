{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.148.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.gz";
    # hash = lib.fakeHash;
    hash = "sha256-jHkFAK8rpudM5JSP4mxlGsH3f227AFtHyNJv9xEUYmI=";
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a bin codex-resources codex-path codex-package.json "$out/"

    # Keep the upstream package layout intact. Codex resolves runtime
    # companions such as codex-code-mode-host relative to this layout.
    test -x "$out/bin/codex"
    test -x "$out/bin/codex-code-mode-host"
    test -f "$out/codex-package.json"

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
