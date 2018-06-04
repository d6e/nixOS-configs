{ config, lib, pkgs, ... }:

{
  imports = [];
  services.exim.config = ''
  ''
  environment.systemPackages = with pkgs; [ exim ];
}
