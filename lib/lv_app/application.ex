defmodule LvApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LvAppWeb.Telemetry,
      # Start the Ecto repository
      LvApp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LvApp.PubSub},
      # Start Finch
      {Finch, name: LvApp.Finch},
      # Start the Endpoint (http/https)
      LvAppWeb.Endpoint
      # Start a worker by calling: LvApp.Worker.start_link(arg)
      # {LvApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LvApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LvAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
