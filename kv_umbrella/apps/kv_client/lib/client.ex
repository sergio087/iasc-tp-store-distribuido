defmodule KVClient.Client do
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
      GenServer.call(server, {:set, key, value})
  end

  def get(server, key) do
      GenServer.call(server, {:get, key})
  end


  ##Server Callback

  def init(:ok) do 
      IO.puts "init"
      [currentserver | otherServers] = Application.get_env(:kv_client, :servers)
      {:ok, [currentserver | otherServers]}
  end

  def handle_call({:getcurrentserver}, _from, [currentserver | _otherServers] = state) do
    {:reply, {:ok, currentserver}, state}
  end

  def changeServer({currentserver, tail}) do
    tail = List.insert_at(tail, -1, currentserver)
    [currentserver | tail ] = tail
    {currentserver, tail}
  end

  #SET
  def handle_call({:set, key, value},_from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/set"
    options =
      [
        body: ("{\"key\":\"" <> key <> "\", \"value\":\"" <> value <> "\"}"),
        headers: ["User-Agent": "My App", "Content-Type": "application/json"]
      ]

    response = HTTPotion.post url, options
    #TODO verificar errores de conexion
    {:reply, Map.get(response, :body), state}
  end

  #GET
  def handle_call({:get, key}, _from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/get"
    options = [query: %{key: key}]
    
    response = HTTPotion.get(url, options)
    #TODO verificar errores de conexion
    {:reply, Map.get(response, :body), state}
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
