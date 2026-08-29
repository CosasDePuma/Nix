_: {
  flake = {
    nixosModules.software-wow = {lib, ...}: {
      # Wine needs the 32-bit half of the GL/Vulkan stack to render a
      # 32-bit client through the NVIDIA driver; nothing else here turns
      # that on.
      hardware.graphics.enable32Bit = lib.mkDefault true;
    };

    homeManagerModules.software-wow = {
      lib,
      pkgs,
      ...
    }: let
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
      # mod-spelldraft needs client-side files (a patch MPQ + a Lua addon) to
      # match what the server expects -- unlike mod-playerbots and mod-ale,
      # which are purely server-side and need nothing here. Pinned to a rev
      # so a client rebuild can't silently drift from what the server built
      # in .github/workflows/azerothcore-kikewtf.yml (bump both together).
      spelldraftSrc = pkgs.fetchFromGitHub {
        owner = "bdodroid";
        repo = "mod-spelldraft";
        rev = "ca54a656710718af8e7d8c6e54749d72b0cc9df3";
        sha256 = "0gjwqcdhmzqvf03w1ag4i5w80q1p5vdcl5652gb7y8r9h4igwmrc";
      };
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

      # Overwrites whatever realmlist the downloaded client ships with.
      # Defaults to localhost (127.0.0.1); hosts override this with their
      # specific realm address. Two copies: this client ships one in the
      # client root and another, separate one under Data/enUS.
      home.file = {
        "${gameDir}/realmlist.wtf".text = lib.mkDefault "set realmlist 127.0.0.1";
        "${gameDir}/Data/enUS/realmlist.wtf".text = lib.mkDefault "set realmlist 127.0.0.1";

        "${gameDir}/Data/patch-P.mpq".source = "${spelldraftSrc}/wow-client/Data/patch-P.mpq";
        "${gameDir}/Interface/AddOns/SpellDraft".source = "${spelldraftSrc}/wow-client/Interface/AddOns/SpellDraft";
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
