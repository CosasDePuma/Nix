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
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--stop-timeout=120"
        ];
        ports = [
          "127.0.0.1:3389:3389/tcp"
          "127.0.0.1:3389:3389/udp"
          "127.0.0.1:8006:8006"
        ];
        volumes = [
          "${sharedDir}:/storage"
          "${sharedDir}/shared:/data"
        ];
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
          mkdir -p "$HOME/Windows/shared"

          check_rdp() {
            { exec 3<>/dev/tcp/127.0.0.1/3389; } 2>/dev/null || return 1
            printf '\x03\x00\x00\x13\x0e\xe0\x00\x00\x00\x00\x00\x01\x00\x08\x00\x03\x00\x00\x00' >&3 2>/dev/null || { exec 3>&-; return 1; }
            if read -r -n 2 -t 2 <&3 2>/dev/null; then
              exec 3>&-
              return 0
            fi
            exec 3>&-
            return 1
          }

          if ! systemctl start docker-windows.service; then
            notify-send "Windows VM" "Failed to start Windows container"
            exit 1
          fi

          notify-send "Windows VM" "Starting Windows VM... (First boot may take a few minutes; view progress at http://localhost:8006)"

          # Wait for the guest RDP server to complete boot/install and respond to handshake
          ready=""
          for _ in $(seq 1 1800); do
            if ! systemctl is-active --quiet docker-windows.service; then
              notify-send "Windows VM" "Windows service stopped unexpectedly"
              exit 1
            fi

            if check_rdp; then
              ready=1
              break
            fi
            sleep 2
          done

          if [ -z "$ready" ]; then
            notify-send "Windows VM" "Windows did not expose RDP in time"
            systemctl stop docker-windows.service
            exit 1
          fi

          client=$(command -v sdl-freerdp || command -v wlfreerdp || command -v wl-freerdp || command -v xfreerdp)
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
