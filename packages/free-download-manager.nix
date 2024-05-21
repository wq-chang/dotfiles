{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  name = "fdm";
  version = "6.22";
  src = pkgs.fetchurl {
    url = "https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb";
    hash = "sha256-JDltgnbvEu2Io0NJ48Og25XNAocc/dIbV5MmUE+0gQs=";
  };
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
  ];

  buildInputs =
    with pkgs;
    [
      gtk3
      libpulseaudio
      mysql80
      postgresql.lib
      unixODBC
    ]
    ++ (with xorg; [
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilwm
    ])
    ++ (with gst_all_1; [
      gstreamer
      gst-plugins-base
    ]);

  unpackPhase = "dpkg-deb -x $src .";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r opt/freedownloadmanager $out
    cp -r usr/share $out
    ln -s $out/freedownloadmanager/fdm $out/bin/${name}

    substituteInPlace $out/share/applications/freedownloadmanager.desktop \
      --replace 'Exec=/opt/freedownloadmanager/fdm' 'Exec=${name}' \
      --replace "Icon=/opt/freedownloadmanager/icon.png" "Icon=$out/freedownloadmanager/icon.png"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A smart and fast internet download manager";
    homepage = "https://www.freedownloadmanager.org";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
