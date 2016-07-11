defmodule KVClient.Client do
use GenServer

  ## Client API

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

  def findGreater(server, value) do
      GenServer.call server, {:findGreater_rpc, value}
  end

  def findSmaller(server, value) do
      GenServer.call server, {:findSmaller_rpc, value}
  end
  
  def remove(server, key) do
      GenServer.call server, {:remove_rpc, key}
  end

  #TODO Remove

  #### HTTP API

  def set_HTTP(server, key, value) do
      GenServer.call server, {:set, key, value}
  end

  def get_HTTP(server, key) do
      GenServer.call server, {:get, key}
  end

  def findGreater_HTTP(server, value) do
      GenServer.call server, {:find, "gt", value}
  end

  def findSmaller_HTTP(server, value) do
      GenServer.call server, {:find, "lt", value}
  end

  #TODO Remove

  defp changeserver([ currentServer | otherservers] = state) do
    List.flatten( otherservers, [currentServer])
  end

  ## Server Callback

  def init(:ok) do 
      IO.puts ">>>> inicializa :client"
      [currentserver | otherServers] = Application.get_env(:kv_client, :servers)
      {:ok, [currentserver | otherServers]}
  end


  ################################      RPC       #######################################
     
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
  def handle_call({:get_rpc, key}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :get_rpc, [key] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end

  #Find Greater
  def handle_call({:findGreater_rpc, value}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :findGreater_rpc, [value] do
      {:badrpc, _} ->
          {:reply, :error_no_master, changeserver(state)}
       response  ->
          {:reply,  response , state}
     end
    
  end

   #Find Smaller
  def handle_call({:findSmaller_rpc, value}, _from, [currentserver | _otherServers] = state) do
    IO.puts currentserver
    case :rpc.call currentserver, KVServer.Resolver, :findSmaller_rpc, [value] do
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
  
  #TODO Remove
 
  ################################      HTTP       #######################################

  def handle_call({:getcurrentserver}, _from, [currentserver | _otherServers] = state) do
    {:reply, {:ok, currentserver}, state}
  end

  #SET
  def handle_call({:set, key, value}, _from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/set"
    options =
      [
        body: ("{\"key\":\"" <> key <> "\", \"value\":\"" <> value <> "\"}"),
        headers: ["User-Agent": "My App", "Content-Type": "application/json"]
      ]

    response = HTTPotion.post url, options

    if HTTPotion.Response.success? response do
      {:reply, Map.get(response, :body), state}
    else
      {:reply, response, changeserver(state)}
    end
  end

  #GET
  def handle_call({:get, key}, _from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/get"
    options = [query: %{key: key}]
    
    response = HTTPotion.get(url, options)

    if HTTPotion.Response.success? response do
      {:reply, Map.get(response, :body), state}
    else
      {:reply, response, changeserver(state)}
    end
   end

   #FIND
   def handle_call({:find, operator, value}, _from, [currentserver | _otherServers] = state) do
    url = currentserver <>"/find"
    options = [query: %{operator: operator, value: value}]
    
        response = HTTPotion.get(url, options)

    if HTTPotion.Response.success? response do
      {:reply, Map.get(response, :body), state}
    else
      {:reply, response, changeserver(state)}
    end
   end

   #TODO Remove
end
