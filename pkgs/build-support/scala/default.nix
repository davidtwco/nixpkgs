{ stdenv, fetchSbt, sbt }:

{ name ? "${args.name}-${args.version}"
, src ? null
, srcs ? null
# Hash for the vendor derivation.
, sbtHash ? "unset"
, sbtHashAlgo ? "sha256"
, sbtAttrs ? {}
# Use the `sbt-lock` plugin for sbt to ensure that dependency versions are pinned.
, sbtWithLockFile ? true
, sbtLockVersion ? "0.6.2"
, sbtLockFile
, ...
} @ args:
with stdenv.lib;
let
  sbtLockScript = optionalString sbtWithLockFile ''
    echo -e '\naddSbtPlugin("com.github.tkawachi" % "sbt-lock" % "${sbtLockVersion}")' \
      >> project/plugins.sbt
    cp ${sbtLockFile} lock.sbt
  '';

  sbtDeps = fetchSbt ({
    inherit name src srcs;
    hash = sbtHash;
    hashAlgo = sbtHashAlgo;
    extraInstallPhase = sbtLockScript;
  } // sbtAttrs);
in
stdenv.mkDerivation (args // {
  inherit sbtDeps;

  nativeBuildInputs = [ sbt ];

  buildPhase = ''
    runHook preBuild

    ${sbtLockScript}

    # Cannot use `$sbtDeps/sbt/boot` or `$sbtDeps/ivy2` directly - sbt wants to write lock files
    # in both directories, but the downloaded jars from the vendor derivation must be re-used.
    # Unfortunately, sbt makes lock files in just about every subdirectory, so there isn't a single
    # directory that can be symlink'd from `$sbtDeps`, both directories just have to be copied.
    cp -r $sbtDeps/sbt .sbt
    cp -r $sbtDeps/ivy2 .ivy2
    chmod -R +w .sbt .ivy2

    sbt "set offline := true" \
      -Dsbt.ivy.home=.ivy2 \
      -Dsbt.global.base=.sbt/1.0 \
      -Dsbt.repository.config=./sbt/repositories \
      -Dsbt.boot.directory=.sbt/boot \
      -Dsbt.offline=true \
      --batch \
      compile

    runHook postBuild
  '';

  passthru = { inherit sbtDeps; } // (args.passthru or {});
})
