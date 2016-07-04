defmodule KVServer.Initializer do

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts )
  end

   def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  
  def init(:ok) do
    [currentport | tail] = Application.get_env(:kv_server, :ports)
    IO.puts "INICIALIZANDO"
    startServer({currentport, tail})
  end

  def startServer({currentport, tail}) do 
    case Plug.Adapters.Cowboy.http KVServer.Handler, [], [ip: {127,0,0,1}, port: currentport] do
        {:ok, pid} ->
            IO.puts "OK"
            IO.puts currentport
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

    result = GenServer.call(:resolver, {:resolveSet, conn.body_params["key"], conn.body_params["value"]})
    IO.puts inspect result
    send_resp(conn, 200, Poison.encode! result)
  end

  match "/find", via: :get do
    IO.puts inspect conn
    IO.puts inspect conn.query_params

    send_resp(conn, 200, "find")
  end

  match _ do
    IO.puts "hola"
    send_resp(conn, 404, "oops")
  end
end