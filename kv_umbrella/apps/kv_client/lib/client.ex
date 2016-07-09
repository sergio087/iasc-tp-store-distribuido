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
      GenServer.call server, {:set_rpc, key, value}
  end

  def get(server, key) do
      GenServer.call server, {:get_rpc, key}
  end

  def findGreater(server, key, value) do
      GenServer.call server, {:findgreater_rpc, value}
  end

  def findSmaller(server, key, value) do
      GenServer.call server, {:findsmaller_rpc, value}
  end
  
  def remove(server, key) do
      GenServer.call server, {:remove_rpc, key}
  end

  #### HTTP API

  def get_HTTP(server, key) do
      GenServer.call server, {:get, key}
  end

  def findGreater_HTTP(server, value) do
      GenServer.call server, {:find, "gt", value}
  end

  def findSmaller_HTTP(server, value) do
      GenServer.call server, {:find, "lt", value}
  end

  defp changeserver([ currentServer | otherservers] = state) do
    List.flatten( otherservers, [currentServer])
  end

  ## Server Callback

  def init(:ok) do 
      IO.puts ">>>> inicializa :client"
      [currentserver | otherServers] = Application.get_env(:kv_client, :servers)
      {:ok, [currentserver | otherServers]}
  end


     
  #Set
  def handle_call({:set_rpc, key, value},_from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :set_rpc, [key, value] do
      {:badrpc, _} ->
          {:reply, :error_no_master,  changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end
  
 
   #Get
  def handle_call({:get_rpc, key, value}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :get_rpc, [key] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end

  #Find Greater
  def handle_call({:findgreater_rpc, value}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :findgreater_rpc, [value] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end

   #Find Smaller
  def handle_call({:findsmaller_rpc, value}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :findsmaller_rpc, [value] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end

   #Remove
   def handle_call({:remove_rpc, key}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :remove_rpc, [key] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end
  
 
  ##################################################################################



  #OLD HTTP
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
