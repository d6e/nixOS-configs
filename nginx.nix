{ config              # machine configuration
, pkgs
, acmeChallengesDir
, domain
}:
let
  
  fullNginxConfig = 
    ''
      worker_processes 1;

      #user nobody nogroup;
      # 'user nobody nobody;' for systems with 'nobody' as a group instead
      pid /tmp/nginx.pid;
      error_log /tmp/nginx.error.log;

      events {
        worker_connections 1024; # increase if you have lots of clients
        accept_mutex off; # set to 'on' if nginx worker_processes > 1
        # 'use epoll;' to enable for Linux 2.6+
        # 'use kqueue;' to enable for FreeBSD, OSX
      }

      http {
        # fallback in case we can't determine a type
        default_type application/octet-stream;
        access_log /tmp/nginx.access.log combined;
        sendfile on;
        upstream app_server {
          # fail_timeout=0 means we always retry an upstream even if it failed
          # to return a good HTTP response

          # for UNIX domain socket setups
          server unix:/run/gunicorn/socket fail_timeout=0;

          # for a TCP configuration
          # server 192.168.0.7:8000 fail_timeout=0;
        }
        
        server {
            listen 443 ssl default_server;
            listen [::]:443 ssl default_server;
            server_name ${domain};

            #ssl_certificate /etc/letsencrypt/live/metrics.megacrit.com/fullchain.pem;
            #ssl_certificate_key /etc/letsencrypt/live/metrics.megacrit.com/privkey.pem;
            
	    location /.well-known/acme-challenge {
              root "${acmeChallengesDir}";
            }


            location / {
              # checks for static file, if not found proxy to app
              root /home/metricsapp/app/static;
              try_files $uri @proxy_to_app;
            }

            location @proxy_to_app {
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              # enable this if and only if you use HTTPS
              # proxy_set_header X-Forwarded-Proto https;
              proxy_set_header Host $http_host;
              # we don't want nginx trying to do something clever with
              # redirects, we set the Host: header above already.
              proxy_redirect off;
              proxy_pass http://app_server;
            }
        }

        server {
            listen 80 default_server;
            listen [::]:80 default_server;
            server_name ${domain};
            keepalive_timeout 5;
            client_max_body_size 4G;

            location /.well-known/acme-challenge {
              root "${acmeChallengesDir}";
	    }

            location / {
              return 301 https://$host$request_uri;
            }
        }
      }
    '';
in fullNginxConfig 
