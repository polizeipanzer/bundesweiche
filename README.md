bundesweiche
============

> "Die guten ins Töpfchen, die schlechten ins Kröpfchen" - Aschenputtel 

`bundesweiche` adds a mapping to your Nginx config for serving the IP address ranges of Bundesrepublik Deutschland's Öffentliche Verwaltung different contents, thus denying access.

## Background

This software was developed for two main reasons:

1. The Bundesregierung and their authorities ain't liking transparency and freedom of information, as can be seen [by looking up denied FOIA requests](https://fragdenstaat.de/anfragen/?q=&status=abgelehnt&jurisdiction=&campaign=&category=&publicbody=&tag=&user=&first_after=&first_before=&sort=).
2. The Öffentliche Verwaltung regulary blocks IP address ranges of the Tor network on their webservers.

Let's turn the tables.

## Usage

To deploy `bundesweiche`, add the package to your NixOS configuration and include it in your Nginx config like this:

```nix

{ config, pkgs, ... }:
let
  bundesweiche-nginx = pkgs.callPackage ./bundesweiche.nix {};
in {
  services.nginx = {
    commonHttpConfig = ''
      map $remote_addr $bundes_skip {
        default              0;
        include ${bundesweiche-nginx};
      }
    '';
    virtualHosts = {
      "polizeipanzer.info" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = { root = "/var/www/polizeipanzer.info"; };
        };

        extraConfig = ''
          # Bundesweiche
          set $bundes_access 1;

          if ($bundes_skip = 0) {
            set $bundes_access 0;
          }

          if ($bundes_access = 1) {
            return 401;
          }
        '';
      };
    };
  };
}

```

## Credits

- Thanks to codemonauts for [providing the IP address ranges](https://github.com/codemonauts/bundesedit)! 
- Thanks to two anonymous hackers, helping me with this shitpost cast in Nix and Bash!
