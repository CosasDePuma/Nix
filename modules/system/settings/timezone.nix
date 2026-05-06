{
  flake.modules.nixos.timezone = {
    time.timeZone = "Europe/Madrid";
  };

  flake.modules.darwin.timezone = {
    time.timeZone = "Europe/Madrid";
  };
}
