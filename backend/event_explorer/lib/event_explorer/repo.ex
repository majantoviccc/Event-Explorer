defmodule EventExplorer.Repo do
  use Ecto.Repo,
    otp_app: :event_explorer,
    adapter: Ecto.Adapters.Postgres
end
