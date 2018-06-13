{ config, lib, pkgs, ... }:
let 
  port = 3000;

in 
{
  environment.systemPackages = with pkgs; [ grafana ];
  networking.firewall.allowedTCPPorts = [ port ];
  services.grafana = {
    enable = true; 
    addr = "localhost";
    port = port;
    protocol = "http";
    security.adminUser = "testuser";
    security.adminPassword = "supersecret";
    auth.anonymous.enable = true;
  };
}

