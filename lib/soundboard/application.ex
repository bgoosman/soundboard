defmodule Soundboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SoundboardWeb.Telemetry,
      Soundboard.Repo,
      {DNSCluster, query: Application.get_env(:soundboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Soundboard.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Soundboard.Finch},
      # Start a worker by calling: Soundboard.Worker.start_link(arg)
      # {Soundboard.Worker, arg},
      # Start to serve requests, typically the last entry
      SoundboardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Soundboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SoundboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
