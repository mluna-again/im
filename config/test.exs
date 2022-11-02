import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :im, Im.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "im_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :im, ImWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "9rEtI5H2GN6OwVPXMQ3TS/uBZF6gP1sWXk9n8JGqh7P8T2sO2rGuZZR9AvM+xkll",
  server: false

# In test we don't send emails.
config :im, Im.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :bcrypt_elixir, :log_rounds, 4
