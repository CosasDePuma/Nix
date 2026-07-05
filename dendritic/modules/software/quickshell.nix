_: {
  flake = {
    homeManagerModules.software-quickshell = {pkgs, ...}: let
      quickshell-wrapped = pkgs.symlinkJoin {
        name = "quickshell-wrapped";
        paths = [pkgs.quickshell];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/quickshell \
            --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
          if [ -e $out/bin/qs ]; then
            wrapProgram $out/bin/qs \
              --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
          fi
        '';
      };
    in {
      home.packages = [quickshell-wrapped pkgs.qt6.qt5compat];
    };

    nixosModules.software-quickshell = {pkgs, ...}: let
      quickshell-wrapped = pkgs.symlinkJoin {
        name = "quickshell-wrapped";
        paths = [pkgs.quickshell];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/quickshell \
            --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
          if [ -e $out/bin/qs ]; then
            wrapProgram $out/bin/qs \
              --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
          fi
        '';
      };
    in {
      environment.systemPackages = [quickshell-wrapped pkgs.qt6.qt5compat];
    };
  };
}
