use Mix.Config

defmodule Docker do
    def env(shortname, verbatim \\ false) do
        # Get var
        name = ((if verbatim, do: "", else: "pleroma_") <> Atom.to_string(shortname)) |> String.upcase()
        raw_var = System.get_env(name)

        if raw_var == nil do
            raise "Could not find #{name} in environment. Please define it and try again."
        end

        # Match type and cast if needed
        if String.contains?(raw_var, ":") do
            var_parts = String.split(raw_var, ":", parts: 2)

            type = Enum.at(var_parts, 0)
            var = Enum.at(var_parts, 1)

            func = case type do
                "int" -> fn(x) -> Integer.parse(x) |> elem(0) end
                "bool" -> fn(x) -> x == "true" end
                "string" -> fn(x) -> x end
                _ -> if verbatim do
                        fn(x) -> x end
                     else
                        raise "Unknown type #{type} used in variable #{raw_var}."
                     end
            end

            func.(var)
        else
            raw_var
        end
    end
end

config :logger, level: String.to_atom(Docker.env(:loglevel) || "info")

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
