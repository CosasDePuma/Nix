_: {
  flake = {
    nixosModules.software-wow = {lib, ...}: {
      # Wine needs the 32-bit half of the GL/Vulkan stack to render a
      # 32-bit client through the NVIDIA driver; nothing else here turns
      # that on.
      hardware.graphics.enable32Bit = lib.mkDefault true;
    };

    homeManagerModules.software-wow = {pkgs, ...}: let
      # Where the client goes: nothing here fetches it (a multi-GB
      # Blizzard-copyrighted download isn't something Nix should package),
      # so the client itself has to be extracted here by hand -- see
      # https://chromiecraft.com/en/downloads/ for a clean 3.3.5a client.
      clientDir = "Games/wow-335a";
      wine = pkgs.wineWow64Packages.stable;
      launcher = pkgs.writeShellApplication {
        name = "wow-335a";
        runtimeInputs = [wine];
        text = ''
          export WINEPREFIX="$HOME/${clientDir}/.wine"
          cd "$HOME/${clientDir}"
          exec wine Wow.exe "$@"
        '';
      };
    in {
      home.packages = [launcher wine pkgs.winetricks];

      # Overwrites whatever realmlist the downloaded client ships with --
      # points it at the homelab AzerothCore server
      # (dendritic/hosts/homelab/x86_64-linux/gaming) instead of wherever
      # the client's original source pointed it.
      home.file."${clientDir}/realmlist.wtf".text = "set realmlist 10.0.10.10";

      xdg.desktopEntries.wow-335a = {
        name = "World of Warcraft 3.3.5a";
        genericName = "MMORPG";
        exec = "${launcher}/bin/wow-335a";
        terminal = false;
        categories = ["Game"];
      };
    };
  };
}
