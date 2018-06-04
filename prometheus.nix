{ config, lib, pkgs, ... }:
let 
 prom_config = builtins.toFile "prometheus.yml" ''
# Sample config for Prometheus.

global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.
  evaluation_interval: 15s # By default, scrape targets every 15 seconds.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'example'

# Load and evaluate rules in this file every 'evaluation_interval' seconds.
rule_files:
  # - "first.rules"
  # - "second.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    scrape_timeout: 5s

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    # If prometheus-node-exporter is installed, grab stats about the local
    # machine by default.
    static_configs:
      - targets: ['localhost:9100']
'';
in 
{
  environment.systemPackages = with pkgs; [ prometheus prometheus-node-exporter ];
  
 systemd.services.prometheus = {
   enable = true;
   description = "Monitoring system and time series database";
   documentation = ["https://prometheus.io/docs/introduction/overview/"];
#   user = "prometheus";
   serviceConfig = {
       ExecStart="${pkgs.prometheus}/bin/prometheus --config.file=${prom_config}";
   };
   wantedBy = [ "multi-user.target" ];
 };
}

