defmodule MyRouter do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass:  ["text/*"],
                   json_decoder: Poison
  plug :match
  plug :dispatch

  get "/get" do
    IO.puts inspect conn
    IO.puts "\n#{conn.query_string}\n"
    send_resp(conn, 200, "get")
  end

  match "/set", via: :post do
    IO.puts inspect conn
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    IO.puts inspect conn.body_params
    send_resp(conn, 200, "set")

  end

  get "/find" do
    IO.puts inspect conn
    send_resp(conn, 200, "world")
  end

  match _ do
    IO.puts inspect conn
    send_resp(conn, 404, "oops")
  end
end