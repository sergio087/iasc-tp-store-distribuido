defmodule KVServer.Resolver do
  use GenServer

  ## Client API

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: :resolver])
  end


  ##Private functions
  defp readOnStore(dataStore, :get, key) do
  	:rpc.call dataStore, KVData.Store, :get, [key]
  end

  defp readOnStore(dataStore, :find, operator, value) do
    :rpc.call dataStore, KVData.Store, :find, [operator, value]
  end

  defp writeOnStore(dataStore, key, value) do
  	:rpc.call dataStore, KVData.Store, :insert, [key, value]
  end

  defp nextStore(dataStores, currentIndex) do
  	if currentIndex < length dataStores do
			currentIndex + 1 
		else
			0
  	end
  end


  ## Server Callbacks

  def init(:ok) do
    {:ok, {Application.get_env(:kv_server, :dataStores), 0} }
  end

  def handle_call({:resolveGet, key}, _from, {dataStores, _index} = state) do
    #TODO aplicar hash para saber donde buscar
    dataStore = Enum.at dataStores, 0
    response =
      case readOnStore(dataStore, :get, key) do
        {:found, result} -> 
          %{:status => "ok", :detail => result}
        :not_found ->
          %{:status => "error", :detail => "key not found"}
      end
    {:reply, response, state}
  end

  def handle_call({:resolveFind, operator, value}, _from, {dataStores, _index} = state) do
  	tasks = 
			for i <- 0..(length dataStores) - 1 do
				Task.async(fn -> readOnStore(Enum.at(dataStores, i), :find, operator, value) end)
			end

		tasks_with_results = Task.yield_many(tasks, 10000)

		results = Enum.map(tasks_with_results, fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)

  	{:reply, (List.flatten results), state}
  end

  def handle_call({:resolveSet, key, value}, _from, {dataStores, index} = state) do
  	#TODO aplicar hash para saber donde guardar
  	#new_index = nextStore(dataStores, index)
    new_index = 0
    response =
    	case writeOnStore(Enum.at(dataStores, new_index), key, value) do
        :ok ->
          %{:status => "ok"}
        :full_store ->
          %{:status => "error", :detail => "the store is full"}
      end
  	
    {:reply, response, {dataStores, new_index}}
  end

  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end
end