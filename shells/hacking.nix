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

    # passive scan
    whois

    # recon
    amass
    dnsenum
    feroxbuster
    ffuf
    fping
    hping
    nikto
    nmap
    rustscan
    wafw00f

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
