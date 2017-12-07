{ config, lib, pkgs, ... }:

let
 acmeChallengesDir = "/var/www/challenges";
 domain = "metrics2.megacrit.com";
in {
  imports = [];
  services.xinetd = {
    enable = true;
    services = [{
      name = "distinct";
      port = 9999;
      server = "/etc/admin/git-pull";
      user = "nobody";
      extraConfig = ''
        only_from   = 0.0.0.0/0
        instances   = 1
      '';
    }];
  };
  environment.systemPackages = with pkgs; [ git ];

  environment.etc =
  {
    "admin/git-pull" =
    {
      text =
      ''
        #!/run/current-system/sw/bin/bash
        set -eu
        echo -en "HTTP/1.1 200 OK\r\n" 
        sleep 0.1
        echo -en "Content-Length: 100\r\n" 
        sleep 0.1
        echo -en "Content-Type: text/plain\r\n" 
        sleep 0.1
        echo -en "\r\n" 
        GITDIR=/home/metricsapp/app
        VENVDIR=/home/metricsapp/venv
        runuser -l metricsapp -c "cd $GITDIR && \
                                  git pull && \
                                  $VENVDIR/bin/pip install -r requirements.txt && \
                                  npm install && \
                                  node_modules/bower/bin/bower install"
        sleep 0.1
        systemctl restart gunicorn.service
        sleep 0.1
        systemctl restart gunicorn.socket
        sleep 0.1
        echo "hi"
        sleep 0.1
        echo -en "                                                                         "
        echo -en "\r\n" 
        exit 0
      '';
      mode = "0774";
      group = "nobody";
    };
  };


  users.extraUsers.metricsapp = {
    isNormalUser = true;
    home = "/home/metricsapp";
    #extraGroups = [ ];
  };

  services.nginx = {
    enable = true;
    config = import ./nginx.nix {
      inherit config pkgs acmeChallengesDir domain;
    };
  };
  
  security.acme.certs = {
    ${domain} = {
      webroot = acmeChallengesDir;
      email = "admin@megacrit.com";
      postRun = "systemctl reload nginx.service";
    };
  };

#  systemd.services.uwsgi_metrics = {
#    description = "uWSGI instance to serve the megacrit metrics app";
#    preStart = 
#    ''
#      mkdir -p /run/uwsgi
#      chown metrics:nginx /run/uwsgi'
#    '';
#    script = 
#    ''
#      cd /home/metrics
#      git clone 
#      source myappenv/bin/activate
#      uwsgi --ini myapp.ini'";
#    '';
#    wantedBy = ["multi-user.target"];
#  };
}
