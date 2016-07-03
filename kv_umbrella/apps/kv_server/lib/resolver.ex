defmodule KVServer.Resolver do
  use GenServer

  ## Client API

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: :resolver])
  end


  ##Private functions
  def readOnStore(dataStore, key) do
  	:rpc.call dataStore, KVData.Store, :select, [key]
  end

  def writeOnStore(dataStore, key, value) do
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
  	tasks = 
			for i <- 0..(length dataStores) - 1 do
				Task.async(fn -> readOnStore(Enum.at(dataStores, i), key) end)
			end

		tasks_with_results = Task.yield_many(tasks, 10000)

		results = Enum.map(tasks_with_results, fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)

	 	for {:ok, value} <- results do
	  	IO.inspect value
	 	end

  	{:reply, results, state}
  end

  def handle_call({:resolveFind, condition}, _from, {dataStores, _index} = state) do
  	
  	{:reply, "resolveFind", state}
  end

  def handle_call({:resolveSet, key, value}, _from, {dataStores, index} = state) do
  	#TODO contemplar que este caido el store e intentar en el siguiente o dada cierta cantidad abortar
  	new_index = nextStore(dataStores, index)
  	result = writeOnStore(Enum.at(dataStores, new_index), key, value)
  	{:reply, result, {dataStores, new_index}}
  end



  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end
end