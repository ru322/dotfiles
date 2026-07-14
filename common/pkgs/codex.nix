{
  lib,
  stdenvNoCC,
  fetchurl,
  bubblewrap,
  makeWrapper,
}:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.144.1";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-hAka4gxl/MfUEg25fRvVfX/435x2Cft4HHjC671PWig=";
    #hash = lib.fakeHash;
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex
    wrapProgram $out/bin/codex \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
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
