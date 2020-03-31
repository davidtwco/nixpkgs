{ stdenv
, fetchFromGitHub
, buildSbtPackage
}:

buildSbtPackage rec {
  name = "scala-play-realworld-example-app";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "gothinkster";
    repo = name;
    rev = version;
    sha256 = "0h2lkrira168cspyy70sqqpxn6kndf2m5p9m411amcyz5wwsrk3v";
  };

  sbtHash = "0000000000000000000000000000000000000000000000000000";
  sbtLockFile = ./foo-lock.sbt;

  meta = with stdenv.lib; {
    description = "Exemplary real world application built with Scala 2.13 & Play";
    licenses = licenses.mit;
    homepage = "http://realworld.io";
    platforms = platforms.all;
    maintainers = with maintainers; [ davidtwco ];
  };
}
