{ stdenv, python3, fetchFromGitHub, ebtables, dnsmasq }:

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
    runHook preInstall

    mkdir -p $out/{bin,lib/udev/rules.d,etc/init.d}
    cp -av $src/base/host/deploy/capability_query.py $out/bin
    cp -av $src/base/host/deploy/unpack_boot_image.py $out/bin
    cp -av $src/base/host/deploy/install_zip.sh $out/bin

    cp -av $src/base/debian/cuttlefish-base.udev $out/lib/udev/rules.d/60-cuttlefish-base.rules

    cp -av $src/base/debian/cuttlefish-base.cuttlefish-host-resources.init $out/etc/init.d/

    substituteInPlace $out/etc/init.d/cuttlefish-base.cuttlefish-host-resources.init --replace '$ebtables' '${ebtables}/bin/ebtables'
    substituteInPlace $out/etc/init.d/cuttlefish-base.cuttlefish-host-resources.init --replace 'dnsmasq \' '${dnsmasq}/bin/dnsmasq \'

    runHook postInstall
  '';
})
