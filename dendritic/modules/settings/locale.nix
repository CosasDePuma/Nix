{lib, ...}: let
  timezone = {
    time.timeZone = lib.mkDefault "Europe/Madrid";
  };
  spanish_us = {
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "es_ES.UTF-8";
        LC_IDENTIFICATION = "es_ES.UTF-8";
        LC_MEASUREMENT = "es_ES.UTF-8";
        LC_MONETARY = "es_ES.UTF-8";
        LC_NAME = "es_ES.UTF-8";
        LC_NUMERIC = "es_ES.UTF-8";
        LC_PAPER = "es_ES.UTF-8";
        LC_TELEPHONE = "es_ES.UTF-8";
        LC_TIME = "es_ES.UTF-8";
      };
    };
  };
in {
  flake.modules = {
    darwin.settings-locale = timezone;
    nixos.settings-locale = spanish_us // timezone;
  };
}
