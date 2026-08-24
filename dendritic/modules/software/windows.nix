_: {
  flake = {
    # Windows 11 under QEMU/KVM inside an OCI container: the disk lives in a
    # mounted host folder (also reachable from the guest as the
    # \\host.lan\Data share), the box starts on demand and stops again when
    # the RDP session ends.
    nixosModules.software-windowsvm = {
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

      # windows-vm drives the container through its systemd unit rather than
      # raw docker commands: autoRemoveOnStop means the container only ever
      # exists while docker-windows.service is running, so "docker start" on
      # a stopped/removed container always fails. Starting/stopping that
      # unit needs root; grant it to the docker group without a password,
      # since the launcher runs from a desktop entry with no TTY to prompt.
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "docker-windows.service" &&
              subject.isInGroup("docker")) {
            return polkit.Result.YES;
          }
        });
      '';

      virtualisation.docker.enable = lib.mkDefault true;
      virtualisation.oci-containers.backend = lib.mkDefault "docker";
      virtualisation.oci-containers.containers.windows = {
        image = lib.mkDefault "ghcr.io/dockur/windows:latest";
        autoStart = lib.mkDefault false;
        devices = [
          "/dev/kvm:/dev/kvm"
          "/dev/net/tun:/dev/net/tun"
        ];
        ports = [
          "127.0.0.1:3389:3389"
          "127.0.0.1:8006:8006"
        ];
        volumes = ["${sharedDir}:/data"];
        environment = {
          RAM_SIZE = lib.mkDefault "8G";
          CPU_CORES = lib.mkDefault "4";
          DISK_SIZE = lib.mkDefault "64G";
          USERNAME = lib.mkIf (primaryUser != null) (lib.mkDefault primaryUser);
        };
      };
    };

    homeManagerModules.software-windowsvm = {pkgs, ...}: let
      windows-vm = pkgs.writeShellApplication {
        name = "windows-vm";
        runtimeInputs = [pkgs.coreutils pkgs.freerdp pkgs.libnotify pkgs.systemd];
        text = ''
          if ! systemctl start docker-windows.service; then
            notify-send "Windows VM" "Failed to start Windows container"
            exit 1
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
            notify-send "Windows VM" "Windows did not expose RDP in time"
            exit 1
          fi

          client=$(command -v sdl-freerdp || command -v wl-freerdp || command -v xfreerdp)
          "$client" /v:127.0.0.1:3389 /cert:ignore /dynamic-resolution "$@"
          status=$?

          # Release RAM and CPU once the RDP session is over
          systemctl stop docker-windows.service
          exit "$status"
        '';
      };
    in {
      home.packages = [windows-vm];

      xdg.desktopEntries.windows = {
        name = "Windows 11";
        genericName = "Virtual Machine";
        exec = "${windows-vm}/bin/windows-vm";
        terminal = false;
        categories = ["System"];
        startupNotify = false;
      };
    };
  };
}
