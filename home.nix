{ config, pkgs, ...}:

{
	home.username = "ananda";
	home.homeDirectory = "/home/ananda";
	programs.git.enable = true;
	home.stateVersion = "25.05";
}
