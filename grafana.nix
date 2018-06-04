{ config, lib, pkgs, ... }:
let 
  port = 3000;

in 
{
  environment.systemPackages = with pkgs; [ grafana ];
  networking.firewall.allowedTCPPorts = [ port ];
  services.grafana = {
    enable = true; 
    addr = "0.0.0.0";
    port = port;
    protocol = "http";
    security = {
      adminUser = "d6e";
      adminPassword = "asupersecret";
    };
    auth.anonymous.enable = true;
  };
}

