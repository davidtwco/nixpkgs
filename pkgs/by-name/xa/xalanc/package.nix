{
  lib,
  stdenv,
  fetchFromGitHub,
  xercesc,
  getopt,
  cmake,
}:

stdenv.mkDerivation {
  pname = "xalan-c";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "xalan-c";
    rev = "Xalan-C_1_12_0";
    sha256 = "sha256:0q1204qk97i9h14vxxq7phcfpyiin0i1zzk74ixvg4wqy87b62s8";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    xercesc
    getopt
  ];

  meta = {
    homepage = "https://xalan.apache.org/";
    description = "XSLT processor for transforming XML documents";
    mainProgram = "Xalan";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [ lib.maintainers.jagajaga ];
  };
}
