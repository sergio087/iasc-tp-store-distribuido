defmodule KVServer.Handler do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass:  ["text/*"],
                   json_decoder: Poison
  plug :match
  plug :dispatch

  # def start_link do
  #   ip_tuple = :application.get_env :orchestrator, :ip
  #   {:ok, port} = :application.get_env :orchestrator, :port
  #   IO.puts "#{inspect ip_tuple} : #{inspect port}"
  #   ##{ :ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], [ip: ip_tuple, port: port]
  #   Plug.Adapters.Cowboy.child_spec(:http, __MODULE__, [], [ip: ip_tuple, port: port])
  # end

  def init(options) do
    IO.puts ">>>> inicializa :handler"
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