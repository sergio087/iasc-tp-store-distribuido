defmodule MyRouter do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/get" do
    IO.puts inspect conn
    send_resp(conn, 200, "get")
  end

  match "/set", via: :post do
    IO.puts inspect conn
    send_resp(conn, 200, "find")
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