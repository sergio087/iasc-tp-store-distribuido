defmodule KVServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(type, args) do
    import Supervisor.Spec, warn: false
    IO.puts "Inicializando Orchestrator en modo #{inspect type} y args #{inspect args}"

    {:ok, ip_tuple} = :application.get_env :orchestrator, :ip
    {:ok, port} = :application.get_env :orchestrator, :port
    IO.puts "#{inspect ip_tuple} : #{inspect port}"

    children =
    #Define workers and child supervisors to be supervised
    # worker(KVServer.Worker, [arg1, arg2, arg3]),
         [
              Plug.Adapters.Cowboy.child_spec(:http, __MODULE__.Handler, [], [ip: ip_tuple, port: port]),
              worker(__MODULE__.Resolver, [[name: :resolver]], restart: :transient)
          ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [name: __MODULE__.Supervisor, strategy: :one_for_one, max_restarts: 10, max_seconds: 2]
    Supervisor.start_link(children, opts)
  end

  def stop(app) do
    IO.puts ">>>>>> #{app} stoped"
    Plug.Adapters.Cowboy.shutdown __MODULE__.Handler
  end
  
end
