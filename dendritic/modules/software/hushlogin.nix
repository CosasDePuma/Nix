_: {
  flake = {
    homeManagerModules.software-hushlogin = {
      home.file.".hushlogin".text = "";
    };
  };
}
