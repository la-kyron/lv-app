defmodule LvApp.Repo do
  use Ecto.Repo,
    otp_app: :lv_app,
    adapter: Ecto.Adapters.Postgres
end
