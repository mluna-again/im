defmodule Im.Repo do
  use Ecto.Repo,
    otp_app: :im,
    adapter: Ecto.Adapters.Postgres
end
