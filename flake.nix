{
	description = "NixOS home server";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		copyparty.url = "github:9001/copyparty";
	};
	
	outputs = { self, nixpkgs, home-manager, copyparty, ... }: {
		nixosConfigurations.nixos-server = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.ananda = import ./home.nix;
						backupFileExtension = "backup";
					};
				}	
				copyparty.nixosModules.default
				({ pkgs, ... }: {
				  # add the copyparty overlay to expose the package to the module
				  nixpkgs.overlays = [ copyparty.overlays.default ];
				  # (optional) install the package globally
				  environment.systemPackages = [ pkgs.copyparty ];
				  # configure the copyparty module
				  services.copyparty = {
				    enable = true;

				    settings = {
				      i = "0.0.0.0";
				      p = [ 3210 ];
				    };

				    accounts = {};

				    volumes = {
				      "/harddisk" = {
				        path = "/mnt/harddisk";

				      access = {
				        rw = "*";
				      };

				      flags = {
				        scan = 60;
					e2d = true;
				        fk = 4;
				        d2t = true;
				      };
				    };
				      };

				    openFilesLimit = 8192;
				  };
				})
			];
		};
	};
}
