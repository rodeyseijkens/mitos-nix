{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  installShellFiles,
}: let
  pname = "mitos";
  version = "0.2.1";

  hashes = {
    x86_64-linux = "sha256-CkzLsO2ixewMcCEJcNOh1flHFQEbCwP/+dkmlnWmc6g=";
    aarch64-linux = "sha256-tcXqH7HyLEDHyNbq2mWWMMlVC6HZWLwBi6ykf3iHWjg=";
  };

  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "aarch64";
    }.${stdenv.hostPlatform.system}
    or (throw "mitos: unsupported system ${stdenv.hostPlatform.system}");

  runtimeDir = "$out/lib/mitos/runtime";
in
  stdenv.mkDerivation (finalAttrs: {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/mitos-editor/mitos/releases/download/v${finalAttrs.version}/mitos-v${finalAttrs.version}-${arch}-linux.tar.xz";
      hash = hashes.${stdenv.hostPlatform.system};
    };

    sourceRoot = "mitos-v${finalAttrs.version}-${arch}-linux";

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      installShellFiles
    ];

    buildInputs = [
      stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ms $out/bin/ms
      install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE

      mkdir -p $out/lib/mitos
      cp -r runtime ${runtimeDir}

      installShellCompletion --cmd ms \
        --bash contrib/completion/ms.bash \
        --fish contrib/completion/ms.fish \
        --zsh contrib/completion/ms.zsh

      install -Dm644 ${./contrib/Mitos.desktop} $out/share/applications/Mitos.desktop
      install -Dm644 ${./contrib/Mitos.svg} $out/share/icons/hicolor/scalable/apps/Mitos.svg

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/ms --set MITOS_RUNTIME ${runtimeDir}
    '';

    meta = {
      description = "Fast and minimal modal text editor";
      homepage = "https://mitos.computer";
      changelog = "https://github.com/mitos-editor/mitos/blob/v${finalAttrs.version}/CHANGELOG.md";
      license = lib.licenses.mpl20;
      mainProgram = "ms";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = builtins.attrNames hashes;
    };
  })
