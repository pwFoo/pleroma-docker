divert(-1)
define(`upcase', `translit($1, `a-z', `A-Z')')
define(`env', `upcase($1): ${upcase($1):?upcase($1)}')
define(`env_fb', `upcase($1): ${upcase($1):-$2}')
define(`env_inline', `${upcase($1):?upcase($1)}')
define(`env_inline_fb', `${upcase($1):-$2}')
divert(1)dnl

version: "3"

networks:
  default:
    external:
      name: env_inline_fb(`docker_network', `pleroma_docker_1')

services:
  db:
    image: postgres:10.3-alpine
    restart: unless-stopped
    environment:
      env(`postgres_db')
      env(`postgres_user')
      env(`postgres_password')
    volumes:
      - env_inline(`docker_datadir')/db:/var/lib/postgresql/data
      - ./initdb.sql:/docker-entrypoint-initdb.d/pleroma.sql

  server:
    build:
      context: .
      dockerfile: ./pleroma.dockerfile
      args:
        env(`pleroma_version')
    restart: unless-stopped
    links:
      - db
    environment:
      env_fb(`mix_env', `prod')

      env_fb(`postgres_ip', `db')
      env(`postgres_db')
      env(`postgres_user')
      env(`postgres_password')

      env(`pleroma_url')
      env(`pleroma_scheme')
      env(`pleroma_port')
      env(`pleroma_secret_key_base')
      env(`pleroma_name')
      env(`pleroma_admin_email')
      env(`pleroma_max_toot_chars')
      env(`pleroma_registrations_open')
      env(`pleroma_media_proxy_enabled')
      env(`pleroma_media_proxy_redirect_on_failure')
      env(`pleroma_media_proxy_url')
      env(`pleroma_db_pool_size')
      env_fb(`pleroma_uploads_path', `/uploads')
      env(`pleroma_chat_enabled')
    volumes:
      - ./custom.d:/custom.d
      - env_inline(`docker_datadir')/uploads:env_inline_fb(`pleroma_uploads_path', `/uploads')
    labels:
      traefik.enable: "true"
      traefik.fe.port: "4000"
      traefik.fe.protocol: "http"
      traefik.fe.entryPoints: "http,https"
      traefik.fe.frontend.rule: "Host:env_inline(`pleroma_url')"
      traefik.cache.port: "4000"
      traefik.cache.protocol: "http"
      traefik.cache.entryPoints: "http,https"
      traefik.cache.frontend.rule: "Host:env_inline(`pleroma_media_proxy_url')"

