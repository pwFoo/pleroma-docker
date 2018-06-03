changequote(`<', `>')

define(<upcase>, <translit($1, <a-z>, <A-Z>)>)
define(<env>, <upcase($1)=${upcase($1):?upcase($1)}>)
define(<env_fb>, <upcase($1)=${upcase($1):-$2}>)
define(<env_inline>, <${upcase($1):?upcase($1)}>)
define(<env_inline_fb>, <${upcase($1):-$2}>)

{
  "version": "3",

  ifdef(__DOCKER_NETWORK, <
    "networks": {
      "default": {
        "external": {
          "name": "DOCKER_NETWORK"
        }
      }
    },
  >)

  "services": {
    ifelse(__SCRIPT_DEPLOY_POSTGRES, true, <
      "db": {
        "image": "postgres:10.3-alpine",
        "restart": "unless-stopped",
        "environment": [
          "env(<postgres_db>)",
          "env(<postgres_user>)",
          "env(<postgres_password>)"
        ],
        "volumes": [
          "env_inline(<docker_datadir>)/db:/var/lib/postgresql/data",
          "./initdb.sql:/docker-entrypoint-initdb.d/pleroma.sql"
        ]
      },
    >)

    ifdef(<__SCRIPT_USE_PROXY>, <
      ifelse(
        __SCRIPT_USE_PROXY, traefik, <>,
        __SCRIPT_USE_PROXY, manual, <>,
        __SCRIPT_USE_PROXY, nginx, <
          "proxy": {
            "image": "nginx:alpine",
            "ports": [
              "__SCRIPT_BIND_IP:__SCRIPT_PORT_HTTP:__SCRIPT_PORT_HTTP"ifdef(__SCRIPT_ENABLE_SSL, <,>)
              ifdef(__SCRIPT_ENABLE_SSL, <"__SCRIPT_BIND_IP:__SCRIPT_PORT_HTTPS:__SCRIPT_PORT_HTTPS">)
            ],
            "links": [
              "server:pleroma"
            ],
            "volumes": [
              "./custom.d/server.nginx:/etc/nginx/nginx.conf:ro",
              "./custom.d/vhost.nginx:/etc/nginx/conf.d/pleroma.conf:ro"ifdef(__SCRIPT_ENABLE_SSL, <,>)
              ifdef(__SCRIPT_ENABLE_SSL, <"./custom.d/ssl.crt:/ssl/ssl.crt:ro",>)
              ifdef(__SCRIPT_ENABLE_SSL, <"./custom.d/ssl.key:/ssl/ssl.key:ro">)
            ]
          },
        >, __SCRIPT_USE_PROXY, apache, <
          "proxy": {
            "image": "amd64/apache:alpine",
            "ports": [
              "__SCRIPT_BIND_IP:__SCRIPT_PORT_HTTP:__SCRIPT_PORT_HTTP"ifdef(__SCRIPT_ENABLE_SSL, <,>)
              ifdef(__SCRIPT_ENABLE_SSL, <"__SCRIPT_BIND_IP:__SCRIPT_PORT_HTTPS:__SCRIPT_PORT_HTTPS">)
            ],
            "links": [
              "server:pleroma"
            ],
            "volumes": [
              "./custom.d/server.httpd:/usr/local/apache2/conf/httpd.conf:ro",
              "./custom.d/vhost.httpd:/usr/local/apache2/conf/extra/httpd-vhosts.conf:ro"ifdef(__SCRIPT_ENABLE_SSL, <,>)
              ifdef(__SCRIPT_ENABLE_SSL, <"./custom.d/ssl.crt:/ssl/ssl.crt:ro",>)
              ifdef(__SCRIPT_ENABLE_SSL, <"./custom.d/ssl.key:/ssl/ssl.key:ro">)
            ]
          },
        >, <
          errprint(Invalid option __SCRIPT_USE_PROXY for <SCRIPT_USE_PROXY>)
          m4exit(<1>)
        >
      )
    >)

    "server": {
      "build": {
        "context": ".",
        "args": [
          "env(<pleroma_version>)"
        ]
      },
      "restart": "unless-stopped",
      "links": [
        ifelse(__SCRIPT_DEPLOY_POSTGRES, true, <"db">)
      ],
      "environment": [
        "env_fb(<mix_env>, <prod>)",

        "env_fb(<postgres_ip>, <db>)",
        "env(<postgres_db>)",
        "env(<postgres_user>)",
        "env(<postgres_password>)",

        "env(<pleroma_url>)",
        "env(<pleroma_scheme>)",
        "env(<pleroma_secret_key_base>)",
        "env(<pleroma_name>)",
        "env(<pleroma_admin_email>)",
        "env(<pleroma_max_notice_chars>)",
        "env(<pleroma_registrations_open>)",
        "env(<pleroma_media_proxy_enabled>)",
        "env(<pleroma_media_proxy_redirect_on_failure>)",
        "env(<pleroma_media_proxy_url>)",
        "env(<pleroma_db_pool_size>)",
        "env(<pleroma_chat_enabled>)",
        "env_fb(<pleroma_uploads_path>, </uploads>)"
      ],
      "volumes": [
        "./custom.d:/custom.d",
        "env_inline(<docker_datadir>)/uploads:env_inline_fb(<pleroma_uploads_path>, </uploads>)"
      ],
      "labels": [
        ifelse(SCRIPT_USE_PROXY, traefik, <
          "traefik.enable=true",
          "traefik.fe.port=4000",
          "traefik.fe.protocol=http",
          "traefik.fe.entryPoints=http,https",
          "traefik.fe.frontend.rule=Host:env_inline(<pleroma_url>)",
          "traefik.cache.port=4000",
          "traefik.cache.protocol=http",
          "traefik.cache.entryPoints=http,https",
          "traefik.cache.frontend.rule=Host:env_inline(<pleroma_media_proxy_url>)"
        >)
      ]
    }
  }
}
