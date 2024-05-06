{ stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cuttlefish-base";
  version = "latest";

  src = fetchFromGitHub {
    owner = "google";
    repo = "android-cuttlefish";
    rev = "8f43d00bf10ec2e1ca94995a8cf2acb3fcd72292";
    sha256 = "sha256-PHAT5Ys+j4roAi0QVx0D2MvCfRJ6awZ/XYUGHmnxJ6Q=";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/{bin,lib/udev/rules.d}
    cp -av $src/base/host/deploy/capability_query.py $out/bin
    cp -av $src/base/host/deploy/unpack_boot_image.py $out/bin
    cp -av $src/base/host/deploy/install_zip.sh $out/bin

    cp -av $src/base/debian/cuttlefish-base.udev $out/lib/udev/rules.d/60-cuttlefish-base.rules
  '';
})
