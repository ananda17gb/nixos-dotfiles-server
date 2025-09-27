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
    extraGroups = [ "wheel" "noodledrive" ]; 
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
    php83
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
  networking.firewall.allowedTCPPorts = [ 3000 80 3030 8080 ];
  networking.firewall.allowedUDPPorts = [ 53 4164 ];
  services.resolved.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.mtr.enable = true;

  services.openssh.enable = true;

  users.users.noodledrive.isSystemUser = true;
  users.users.noodledrive.group = "noodledrive";
  users.groups.noodledrive = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/noodledrive 0770 noodledrive noodledrive"
  ];

  systemd.services.noodledrive = {
    after = [ "network.target" "mnt-harddisk.mount"];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "noodledrive";
      Restart = "on-failure";
      # The ExecStart command now points to the new paths.
      ExecStart = ''
        ${pkgs.filebrowser}/bin/filebrowser \
	  --address 0.0.0.0 \
          --port 3030 \
          --database /var/lib/noodledrive/filebrowser.db \
          --root /mnt/harddisk
      '';
    };
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;

    services = [
      { "Data & Storage" = [
	    { "Filebrowser" = {
	      href = "http://192.168.0.3:3030";
	      description = "Access Server Files";
	      icon = "filebrowser";
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
    ];
    allowedHosts = "192.168.0.3:${toString config.services.homepage-dashboard.listenPort}, 127.0.0.1:${toString config.services.homepage-dashboard.listenPort}, localhost:${toString config.services.homepage-dashboard.listenPort}";
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}

