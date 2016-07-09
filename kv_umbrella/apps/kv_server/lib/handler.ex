defmodule KVServer.Initializer do

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts )
  end

   def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  def stop do
    IO.puts "STOPINGGGGG"

  end

    def stop(server) do
      GenServer.call server, :stop
    end



  ## Callbacks

  def init(:ok) do
    [currentport | tail] = Application.get_env(:kv_server, :ports)
    IO.puts "INICIALIZANDO"
    startServer({currentport, tail})
   # receive do
  end

  def handle_cast(:stop, _from, state) do
    IO.puts "LLAMO STOP"
    Plug.Adapters.Cowboy.shutdown KVServer.Handler.HTTP
    {:stop, :normal, state}
  end

  def terminate(_,_) do
    IO.puts "TERMINATE" 
  end

  def startServer({currentport, tail}) do 
    case Plug.Adapters.Cowboy.http KVServer.Handler, [], [port: currentport] do
        {:ok, pid} ->
            IO.puts "Inicializado orchestrator en puerto: #{currentport}"
            Process.link(pid)
            {:ok, pid}
        {:error, _} ->
            IO.puts "ERROR"
          startServer(changePort({currentport, tail}))
    end
      
  end

  def changePort({currentport, tail}) do
    tail = List.insert_at(tail, -1, currentport)
    [currentport | tail ] = tail
    {currentport, tail}
  end

end


defmodule KVServer.Handler do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass:  ["text/*"],
                   json_decoder: Poison
  plug :match
  plug :dispatch


  def init(options) do
    IO.puts inspect options
    options
  end

  match "/get", via: :get do
    IO.puts inspect conn
    IO.puts inspect conn.query_params

    result = GenServer.call(:resolver, {:resolveGet, conn.query_params["key"]})
    IO.puts inspect result
    send_resp(conn, 200, Poison.encode! result)
  end

  match "/set", via: :post do
    IO.puts inspect conn
    IO.puts inspect conn.body_params

    result = 
      GenServer.call(
        :resolver, 
        {
          :resolveSet, 
          conn.body_params["key"], 
          conn.body_params["value"]
        }
      )
    IO.puts inspect result
    send_resp(conn, 200, Poison.encode! result)
  end

  match "/find", via: :get do
    IO.puts inspect conn
    result = 
      GenServer.call(
        :resolver, 
        {
          :resolveFind, 
          String.to_atom(conn.query_params["operator"]), 
          conn.query_params["value"]
        }
      )

    IO.puts inspect result
    send_resp(conn, 200, Poison.encode! result)
  end

  match _ do
    IO.puts "hola"
    send_resp(conn, 404, "oops")
  end
end