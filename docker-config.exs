use Mix.Config

env = fn name ->
    env_name = "pleroma_" <> Atom.to_string(name) |> String.upcase
    System.get_env(env_name) || raise "Could not find #{env_name} in environment. Please define it and try again."
end

config :pleroma, Pleroma.Web.Endpoint,
    url: [
        host: env.(:url),
        scheme: env.(:scheme),
        port: env.(:port)
    ],
    secret_key_base: env.(:secret_key_base)

config :pleroma, :instance,
  name: env.(:name),
  email: env.(:admin_email),
  limit: env.(:user_limit),
  registrations_open: env.(:registrations_open)

config :pleroma, :media_proxy,
  enabled: env.(:media_proxy_enabled),
  redirect_on_failure: env.(:media_proxy_redirect_on_failure),
  base_url: env.(:media_proxy_url)

config :pleroma, Pleroma.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: env.(:db_user),
  password: env.(:db_pass),
  database: env.(:db_name),
  hostname: env.(:db_host),
  pool_size: env.(:db_pool_size)
