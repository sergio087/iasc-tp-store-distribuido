defmodule KVClient.Client do
use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :client)
  end

  def getcurrentserver(server) do   
      GenServer.call server, {:getcurrentserver}
  end

  def set(server, key, value) do
      GenServer.call server, {:set, key, value}
  end

  def get(server, key) do
      GenServer.call server, {:get, key}
  end

  def findGreater(server, value) do
      GenServer.call server, {:find, "gt", value}
  end

  def findSmaller(server, value) do
      GenServer.call server, {:find, "lt", value}
  end


  ## Server Callback

  def init(:ok) do 
      IO.puts ">>>> inicializa :client"
      [currentserver | otherServers] = Application.get_env(:kv_client, :servers)
      {:ok, [currentserver | otherServers]}
  end
  
  def handle_call({:getcurrentserver}, _from, [currentserver | _otherServers] = state) do
    {:reply, {:ok, currentserver}, state}
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

   #FIND
   def handle_call({:find, operator, value}, _from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/find"
    options = [query: %{operator: operator, value: value}]
    
    response = HTTPotion.get(url, options)
    #TODO verificar errores de conexion
    {:reply, Map.get(response, :body), state}
   end
end
