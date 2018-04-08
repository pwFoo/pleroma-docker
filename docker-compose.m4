divert(-1)
define(`upcase', `translit($1, `a-z', `A-Z')')
define(`env', `upcase($1): ${upcase($1):?upcase($1)}')
define(`env_fb', `upcase($1): ${upcase($1):-$2}')
define(`env_inline', `${upcase($1):?upcase($1)}')
divert(1)dnl

version: "3"

networks:
  default:
    external:
      name: env_inline(`docker_network')

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

  server:
    build:
      context: .
      dockerfile: ./pleroma.dockerfile
    restart: unless-stopped
    links:
      - db
    environment:
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
      env(`pleroma_user_limit')
      env(`pleroma_registrations_open')
      env(`pleroma_media_proxy_enabled')
      env(`pleroma_media_proxy_redirect_on_failure')
      env(`pleroma_media_proxy_url')
      env(`pleroma_db_pool_size')

      env_fb(`pleroma_workspace', `/pleroma')
      env_fb(`mix_archives', `/mix/archives')
      env_fb(`mix_home', `/mix/home')
      env_fb(`mix_env', `prod')
    volumes:
      - ./pleroma:/pleroma
      - env_inline(`docker_datadir')/pleroma:/data
      - env_inline(`docker_datadir')/mix:/mix
      - env_inline(`docker_datadir')/misc/cache:/root/.cache
      - env_inline(`docker_datadir')/misc/meta:/meta
    labels:
      traefik.enable: "true"
      traefik.fe.port: "4000"
      traefik.fe.protocol: "http"
      traefik.fe.entryPoints: "http,https"
      traefik.fe.frontend.rule: "Host:env_inline(`pleroma_url')"
      traefik.cache.port: "80"
      traefik.cache.protocol: "http"
      traefik.cache.entryPoints: "http,https"
      traefik.cache.frontend.rule: "Host:env_inline(`pleroma_media_proxy_url')"

