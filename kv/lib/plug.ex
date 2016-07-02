defmodule MyPlug do
  use GenServer
  import Plug.Conn

  def init(options) do
    # initialize options
    GenServer.start_link(__MODULE__, :ok, [])
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world")
  end
end