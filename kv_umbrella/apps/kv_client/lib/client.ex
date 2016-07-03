defmodule Client do
use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def getcurrentserver(server) do   
      GenServer.call(server, {:getcurrentserver})
  end

  def set(server, key, value) do
      GenServer.cast(server, {:set, key, value})
  end

  def get(server, key) do
      GenServer.cast(server, {:get, key})
  end

    def init(:ok) do 
        IO.puts "init"
        [currentserver | tail] = Application.get_env(:kv_client, :server1)
        {:ok, {currentserver, tail}}
    end


 

    ########################

  def handle_call({:getcurrentserver}, _from, state) do
    {currentserver, tail } = state
    {:reply, {:ok, currentserver}, changeServer({currentserver, tail})}
  end

  def changeServer({currentserver, tail}) do
    tail = List.insert_at(tail, -1, currentserver)
    [currentserver | tail ] = tail
    {currentserver, tail}
  end

  #SET
  def handle_cast({:set, _, _},{currentserver, tail}) do
      IO.puts "hola"
       HTTPotion.post "http://localhost:4000/set", [body: "key=" <> URI.encode_www_form("hola"),
        headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]
    |> Map.get(:body)
    if :body do
        {:noreply, {currentserver, tail}}
       else
      {:noreply, {currentserver, tail}}
    end
    
  end

  #GET
  def handle_cast({:get, key},{currentserver, tail}) do
        HTTPotion.get(currentserver <> "/get", query: %{key: key})
        |> Map.get(:body)
        |> ok
   end
























    def set(key, val) do
        HTTPotion.post "http://localhost:4000/set", [body: "key=" <> URI.encode_www_form("clave") <> ", val=" <> URI.encode_www_form("valor"),
        headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]
    end

    def hola do 
        IO.put :currentServer
    end

    def get(key) do
        [currentserver | tail] = Application.get_env(:kv, :server1)
        HTTPotion.get("http://localhost:4000/", query: %{key: key})
        |> Map.get(:body)
        |> ok
   end

    def findGreater(minVal) do
        HTTPotion.get("http://localhost:4000/find", query: %{min: minVal})
    end
    def findSmaller(maxVal) do
        HTTPotion.get("http://localhost:4000/find", query: %{max: maxVal})
    end

    defp ok({:ok, result}), do: result
    
end
