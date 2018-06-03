use Mix.Config

defmodule Docker do
    def env(name, verbatim \\ false) do
        env_name = (if verbatim, do: "", else: "pleroma_") <> Atom.to_string(name) |> String.upcase
        env_var = System.get_env(env_name)

        if env_var == nil do
            raise "Could not find #{env_name} in environment. Please define it and try again."
        end

        System.put_env(env_name, "")
        env_var
    end
end

config :pleroma, Pleroma.Web.Endpoint,
    url: [
        host: Docker.env(:url),
        scheme: Docker.env(:scheme),
        port: Docker.env(:port)
    ],
    secret_key_base: Docker.env(:secret_key_base)

config :pleroma, Pleroma.Upload,
    uploads: Docker.env(:uploads_path)

config :pleroma, :chat,
    enabled: Docker.env(:chat_enabled)

config :pleroma, :instance,
    name: Docker.env(:name),
    email: Docker.env(:admin_email),
    limit: Docker.env(:max_notice_chars),
    registrations_open: Docker.env(:registrations_open)

config :pleroma, :media_proxy,
    enabled: Docker.env(:media_proxy_enabled),
    redirect_on_failure: Docker.env(:media_proxy_redirect_on_failure),
    base_url: Docker.env(:media_proxy_url)

config :pleroma, Pleroma.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: Docker.env(:postgres_user, true),
    password: Docker.env(:postgres_password, true),
    database: Docker.env(:postgres_db, true),
    hostname: Docker.env(:postgres_ip, true),
    pool_size: Docker.env(:db_pool_size)
