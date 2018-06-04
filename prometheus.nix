{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ prometheus prometheus-node-exporter ];
  services.prometheus.enable = true; 
}

