{
  pkgs,
  inputs,
  system,
  ...
}:
with pkgs;
mkShell {
  name = "hacking-infra";
  buildInputs = [
    # connection
    openvpn

    # recon
    fping
    hping
    nmap
    rustscan

    # frameworks
    metasploit
    nuclei

    # smb
    enum4linux-ng
    polenum
    samba
    smbmap

    # ssh
    ssh-audit
    terrapin-scanner
  ];
}
