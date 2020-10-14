import Config

defmodule RuntimeEnvironment do
  def get_cors_origins do
    case Environment.get("CORS_ALLOWED_ORIGINS") do
      origins when is_bitstring(origins) ->
        origins
        |> String.split(",")
        |> case do
          [origin] -> origin
          origins -> origins
        end

      _ ->
        nil
    end
  end

  def get_endpoint_static_url_config do
    case Environment.get("STATIC_URL_HOST") do
      host when is_bitstring(host) ->
        [
          host: host,
          scheme: Environment.get("STATIC_URL_SCHEME"),
          port: Environment.get("STATIC_URL_PORT")
        ]

      _ ->
        nil
    end
  end
end

force_ssl = Environment.get_boolean("FORCE_SSL")
scheme = if force_ssl, do: "https", else: "http"
host = Environment.get("CANONICAL_HOST")
port = Environment.get("PORT")

config :elixir_boilerplate,
  canonical_host: host,
  force_ssl: force_ssl

config :elixir_boilerplate, ElixirBoilerplate.Repo,
  pool_size: Environment.get_integer("DATABASE_POOL_SIZE"),
  ssl: Environment.get_boolean("DATABASE_SSL"),
  url: Environment.get("DATABASE_URL")

config :elixir_boilerplate, ElixirBoilerplateWeb.Endpoint,
  debug_errors: Environment.get_boolean("DEBUG_ERRORS"),
  http: [port: port],
  secret_key_base: Environment.get("SECRET_KEY_BASE"),
  static_url: RuntimeEnvironment.get_endpoint_static_url_config(),
  url: [host: host, scheme: scheme, port: port]

config :elixir_boilerplate, ElixirBoilerplateWeb.Router,
  session_key: Environment.get("SESSION_KEY"),
  session_signing_salt: Environment.get("SESSION_SIGNING_SALT")

config :elixir_boilerplate, Corsica, origins: RuntimeEnvironment.get_cors_origins()

config :elixir_boilerplate,
  basic_auth: [
    username: Environment.get("BASIC_AUTH_USERNAME"),
    password: Environment.get("BASIC_AUTH_PASSWORD")
  ]

config :sentry,
  dsn: Environment.get("SENTRY_DSN"),
  environment_name: Environment.get("SENTRY_ENVIRONMENT_NAME"),
  included_environments: [Environment.get("SENTRY_ENVIRONMENT_NAME")]

config :new_relic_agent,
  app_name: System.get_env("NEW_RELIC_APP_NAME"),
  license_key: System.get_env("NEW_RELIC_LICENSE_KEY")
