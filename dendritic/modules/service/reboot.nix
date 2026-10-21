{lib, ...}: {
  # Scheduled reboot at noon and midnight. Not Persistent: a host that was
  # down at the scheduled time must not reboot again as soon as it boots.
  flake.nixosModules.service-reboot = {config, ...}: {
    systemd.timers.scheduled-reboot = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = lib.mkDefault ["*-*-* 00:00:00" "*-*-* 12:00:00"];
        Persistent = false;
      };
    };

    systemd.services.scheduled-reboot = {
      description = "Scheduled reboot";
      serviceConfig.Type = "oneshot";
      script = "${config.systemd.package}/bin/systemctl reboot";
    };
  };
}
