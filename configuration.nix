{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-server"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Asia/Jakarta";

  users.users.ananda = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; 
    packages = with pkgs; [
      tree
    ];
  };

  users.extraUsers.ananda = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    neovim 
    lazygit
    neofetch
    wget
    git
    adguardhome
    ntfs3g
    tailscale
    filebrowser
    docker-compose
  ];

 services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true;
    settings = {
	    http = {
	      address = "0.0.0.0:3000";
	    };
    };
  };

  services.tailscale.enable = true;
  networking.firewall.enable = true; 
  networking.firewall.allowedTCPPorts = [ 3000 80 8080 2080 2443 7080];
  networking.firewall.allowedUDPPorts = [ 53 4164 ];
  services.resolved.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.mtr.enable = true;

  services.openssh.enable = true;

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;

    services = [
      { "Data & Storage" = [
	    { "Filebrowser Quantum" = {
	      href = "http://192.168.0.3:7080";
	      description = "Access Server Files";
	      icon = "filebrowser-quantum";
	      };
	    }
        ];
      }

      { "Network Tools" = [
	    { "AdGuard Home" = {
	      href = "http://192.168.0.3:3000";
	      description = "DNS Ad Blocker Admin";
	      icon = "adguard-home";
	      };
	    }
        ];
      }

      { "Moodle & MariaDB" = [
	    { "Moodle" = {
	      href = "http://192.168.0.3:2080";
	      description = "Moodle LMS";
	      icon = "moodle";
	      };
	    }
        ];
      }
    ];
    allowedHosts = "192.168.0.3:${toString config.services.homepage-dashboard.listenPort}, 127.0.0.1:${toString config.services.homepage-dashboard.listenPort}, localhost:${toString config.services.homepage-dashboard.listenPort}";
  };

  virtualisation.docker = {
    enable = true;
  };

  systemd.services.moodle-compose = {
    description = "Moodle Docker Compose Service";
    after = ["docker.service"];
    requires = ["docker.service"];

    path = [ pkgs.docker pkgs.docker-compose ];
    script = '' 
      docker compose -f "/etc/my-moodle-service/docker-compose.yml" up -d
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = ''
        ${pkgs.docker}/bin/docker compose -f "/etc/my-moodle-service/docker-compose.yml"  down
      '';
      User = "root"; 
      WorkingDirectory = "/etc/my-moodle-service"; # Important for relative paths in compose file
    };
    wantedBy = [ "multi-user.target" ];
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}

