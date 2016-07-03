defmodule KVServer.Handler do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass:  ["text/*"],
                   json_decoder: Poison
  plug :match
  plug :dispatch


  def start_link do
    { :ok, _ } = Plug.Adapters.Cowboy.http KVServer.Handler, [], [ip: {127,0,0,1}, port: 4000]
  end


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
    IO.puts inspect conn
    send_resp(conn, 404, "oops")
  end
end