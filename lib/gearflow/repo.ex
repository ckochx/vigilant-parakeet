defmodule Gearflow.Repo do
  use Ecto.Repo,
    otp_app: :gearflow,
    adapter: Ecto.Adapters.Postgres
end
