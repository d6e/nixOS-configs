{ config, lib, pkgs, ... }:

{
  imports = [];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.dates = "weekly";
    autoPrune.enable = true;
  }; 

  environment.systemPackages = with pkgs; [ docker docker_compose ];
}
