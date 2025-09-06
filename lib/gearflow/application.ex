defmodule Gearflow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GearflowWeb.Telemetry,
      Gearflow.Repo,
      {DNSCluster, query: Application.get_env(:gearflow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gearflow.PubSub},
      # Start a worker by calling: Gearflow.Worker.start_link(arg)
      # {Gearflow.Worker, arg},
      # Start to serve requests, typically the last entry
      GearflowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gearflow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GearflowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
