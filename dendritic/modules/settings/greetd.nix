_: {
  flake.nixosModules.settings-greetd = {
    services.greetd.enable = true;
    users = {
      users.greeter = {
        isSystemUser = true;
        group = "greeter";
        description = "greetd greeter user";
      };
      groups.greeter = {};
    };
  };
}
