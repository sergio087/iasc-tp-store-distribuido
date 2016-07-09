defmodule KVServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    IO.puts "Inicializando Orchestrator en modo #{inspect _type}"
    
    children = [
      
      # Define workers and child supervisors to be supervised
      # worker(KVServer.Worker, [arg1, arg2, arg3]),
      worker(__MODULE__.Initializer, [[name: :orchestrator]], restart: :transient),
      worker(__MODULE__.Resolver, [[name: :resolver]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, max_restarts: 10, max_seconds: 2]
    Supervisor.start_link(children, opts)
  end

  
end
