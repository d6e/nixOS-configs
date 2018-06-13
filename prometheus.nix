{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ prometheus prometheus-node-exporter ];
  services.prometheus = {
    enable = true; 
    listenAddress = "localhost:9090";
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "cpu" "diskstats" "boottime" "arp" "edac" "filesystem" "stat" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {targets = ["localhost:9100"];}
        ];
      } 
    ];
  };
}

