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
      clientDir = "Games/WoW";
      # The ChromieCraft zip extracts with its own top-level folder rather
      # than dropping Wow.exe straight into clientDir -- this is where the
      # actual client (and thus realmlist.wtf) has to live.
      gameDir = "${clientDir}/ChromieCraft_3.3.5a";
      wine = pkgs.wineWow64Packages.stable;
      launcher = pkgs.writeShellApplication {
        name = "wow-335a";
        runtimeInputs = [wine];
        text = ''
          export WINEPREFIX="$HOME/${clientDir}/.wine"
          cd "$HOME/${gameDir}"
          # Runs inside a Wine virtual desktop instead of true fullscreen:
          # this 2010-era client's D3D9/GDI fullscreen path doesn't handle
          # an ultrawide host resolution, and only ends up rendering into a
          # small corner of the real screen. A normal 1920x1080 virtual
          # desktop sidesteps that entirely.
          exec wine explorer /desktop=WoW,1920x1080 Wow.exe "$@"
        '';
      };
    in {
      home.packages = [launcher wine pkgs.winetricks];

      # Overwrites whatever realmlist the downloaded client ships with --
      # points it at the homelab AzerothCore server
      # (dendritic/hosts/homelab/x86_64-linux/gaming) instead of wherever
      # the client's original source pointed it. Two copies: this client
      # ships one in the client root and another, separate one under
      # Data/enUS, and it isn't obvious which one it actually reads.
      home.file = {
        "${gameDir}/realmlist.wtf".text = "set realmlist 10.0.10.10";
        "${gameDir}/Data/enUS/realmlist.wtf".text = "set realmlist 10.0.10.10";
      };

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
