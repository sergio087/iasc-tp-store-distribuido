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
    IO.puts "\n#{conn.query_string}\n"
    send_resp(conn, 200, "get")
  end

  match "/set", via: :post do
    IO.puts inspect conn
    IO.puts inspect conn.body_params
    send_resp(conn, 200, "set")

  end

  match "/find", via: :get do
    IO.puts inspect conn
    send_resp(conn, 200, "find")
  end

  match _ do
    IO.puts inspect conn
    send_resp(conn, 404, "oops")
  end
end