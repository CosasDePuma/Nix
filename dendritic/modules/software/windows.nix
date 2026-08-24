_: {
  flake = {
    # Windows 11 under QEMU/KVM inside an OCI container, Omarchy-style: the
    # disk lives in a mounted host folder (also reachable from the guest as
    # the \\host.lan\Data share), the box starts on demand and stops again
    # when the RDP session ends.
    nixosModules.software-windows = {
      config,
      lib,
      ...
    }: let
      # Desktop-oriented module: derive the primary interactive user from the
      # system instead of hardcoding names or home paths.
      normalUsers =
        lib.attrNames
        (lib.filterAttrs (_: user: user.isNormalUser or false) config.users.users);
      primaryUser = lib.head (normalUsers ++ [null]);
      sharedDir =
        if primaryUser == null
        then "/var/lib/windows"
        else "/home/${primaryUser}/Windows";
    in {
      boot.kernelModules = ["kvm-intel" "kvm-amd"];

      virtualisation.docker.enable = lib.mkDefault true;
      virtualisation.oci-containers.backend = lib.mkDefault "docker";
      virtualisation.oci-containers.containers.windows = {
        image = lib.mkDefault "ghcr.io/dockur/windows:latest";
        autoStart = lib.mkDefault false;
        devices = lib.mkDefault [
          "/dev/kvm:/dev/kvm"
          "/dev/net/tun:/dev/net/tun"
        ];
        ports = lib.mkDefault [
          "127.0.0.1:3389:3389"
          "127.0.0.1:8006:8006"
        ];
        volumes = lib.mkDefault ["${sharedDir}:/data"];
        environment = {
          RAM_SIZE = lib.mkDefault "8G";
          CPU_CORES = lib.mkDefault "4";
          DISK_SIZE = lib.mkDefault "64G";
          USERNAME = lib.mkIf (primaryUser != null) (lib.mkDefault primaryUser);
        };
      };
    };

    homeManagerModules.software-windows = {pkgs, ...}: let
      omarchy-windows = pkgs.writeShellApplication {
        name = "omarchy-windows";
        runtimeInputs = [pkgs.coreutils pkgs.docker pkgs.freerdp pkgs.libnotify];
        text = ''
          if ! docker inspect windows > /dev/null 2>&1; then
            notify-send "Omarchy" "Windows container not found"
            exit 1
          fi

          state=$(docker inspect windows --format '{{.State.Running}}')
          if [ "$state" != "true" ]; then
            docker start windows > /dev/null
          fi

          # Wait for the RDP port; the first boot installs Windows itself and
          # can be followed on http://localhost:8006
          ready=""
          for _ in $(seq 1 600); do
            if (exec 3<> /dev/tcp/127.0.0.1/3389) 2> /dev/null; then
              exec 3>&-
              ready=1
              break
            fi
            sleep 1
          done
          if [ -z "$ready" ]; then
            notify-send "Omarchy" "Windows did not expose RDP in time"
            exit 1
          fi

          client=$(command -v sdl-freerdp || command -v wl-freerdp || command -v xfreerdp)
          "$client" /v:127.0.0.1:3389 /cert:ignore /dynamic-resolution "$@"
          status=$?

          # Release RAM and CPU once the RDP session is over
          docker stop windows > /dev/null
          exit "$status"
        '';
      };
    in {
      home.packages = [omarchy-windows];

      xdg.desktopEntries.windows = {
        name = "Windows 11";
        genericName = "Virtual Machine";
        exec = "${omarchy-windows}/bin/omarchy-windows";
        terminal = false;
        categories = ["System"];
        startupNotify = false;
      };
    };
  };
}
