{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gitlab-runner ];
  services.gitlab-runner.enable = true;


#  systemd.services.gitlab-runner = {
#    description = "A service which runs gitlab ci jobs.";
#    preStart =
#    ''
#    mkdir -p /run/uwsgi
#    chown metrics:nginx /run/uwsgi'
#    '';
#    script =
#    ''
#    cd /home/metrics
#    git clone
#    source myappenv/bin/activate
#    uwsgi --ini myapp.ini'";
#    '';
#    wantedBy = ["multi-user.target"];
#  };
}
