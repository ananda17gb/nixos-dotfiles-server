{ config, pkgs, ...}:

{
	home.username = "ananda";
	home.homeDirectory = "/home/ananda";
	programs.git.enable = true;
	home.stateVersion = "25.05";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo Hello from server";
		};
	};
}
