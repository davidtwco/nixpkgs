{ stdenv, sbt }:

{ name ? "sbt-deps"
, hash
, hashAlgo
, extraInstallPhase
,  ... } @ args:
with stdenv.lib;
let
  flags = builtins.concatStringsSep " " [
    "-Dsbt.ivy.home=$out/ivy2"
    "-Dsbt.global.base=$out/sbt/1.0"
    "-Dsbt.repository.config=$out/sbt/repositories"
    "-Dsbt.boot.directory=$out/sbt/boot"
    "--batch"
  ];
in
stdenv.mkDerivation ({
  name = "${name}-vendor";

  nativeBuildInputs = [ sbt ];

  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    set -x

    ${extraInstallPhase}

    # Run `sbt update` with the `scalaVersion` matching what will be used to build the project
    # (rather than the Scala version that sbt wants to use), so that it is guaranteed to be
    # downloaded.
    SCALA_VER="$(sbt ${flags} scalaVersion | tail -n1 | cut -f2 -d' ')"
    sbt ${flags} update

    # Keeping `update.log` causes the Nix build to fail with a "path is not valid" error.
    rm $out/sbt/boot/update.log $out/sbt/boot/sbt.boot.lock
    # Replacing the dates in the `.properties` files is required to have a reproducible output.
    find $out/ivy2 -type f -iname "*.properties" \
      -exec sed -i '2s/.*/#Thurs Jan 1 00:00:00 UTC 1970/' {} \;

    runHook postInstall
  '';

  outputHashAlgo = hashAlgo;
  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenv.lib.fetchers.proxyImpureEnvVars;
  preferLocalBuild = true;
} // (builtins.removeAttrs args [ "name" "hash" "hashAlgo" "extraInstallPhase" ]))
