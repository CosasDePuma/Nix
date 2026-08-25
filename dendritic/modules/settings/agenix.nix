{inputs, ...}: {
  flake.homeManagerModules.settings-agenix = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.agenix.homeManagerModules.default];

    # Upstream stages decrypted secrets in DARWIN_USER_TEMP_DIR on macOS,
    # which periodic cleanup empties -- the symlinks dangle until the
    # launchd agent happens to run again, so ssh silently loses its keys.
    # Pin a persistent location there. Linux keeps XDG_RUNTIME_DIR: tmpfs
    # plus a systemd unit re-decrypting at boot is the safer default.
    age.secretsDir =
      lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      (lib.mkDefault "${config.home.homeDirectory}/.local/state/agenix");
    age.secretsMountPoint =
      lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      (lib.mkDefault "${config.home.homeDirectory}/.local/state/agenix.d");
  };
}
