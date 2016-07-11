defmodule KVServer.Resolver do
  use GenServer

  defstruct dataStores: [], max_key_length: 0 

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def set_rpc(key, value) do 
    GenServer.call(:resolver, {:resolveSet, key, value})
  end

  def get_rpc(key) do 
    GenServer.call(:resolver, {:resolveGet, key})
  end

  def findGreater_rpc(value) do 
    GenServer.call(:resolver, {:resolveFind, :gt, value})
  end

  def findSmaller_rpc(value) do 
    GenServer.call(:resolver, {:resolveFind, :lt, value})
  end

  def remove_rpc(key) do 
    GenServer.call(:resolver, {:resolveRemove, key})
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

  defp removeOnStore(dataStore, key) do
    :rpc.call dataStore, KVData.Store, :remove, [key]
  end

  defp nextStore(state, key) do
    index = rem (Integer.undigits (:binary.bin_to_list key), 2), length state.dataStores
    Enum.at state.dataStores, index
  end

  defp checkKeyLength(state,key) do
    (byte_size key) <= state.max_key_length
  end


  ## Server Callbacks

  def init(:ok) do
    IO.puts ">>>> inicializa :resolver"
    state = %__MODULE__{dataStores: Application.get_env(:kv_server, :dataStores), max_key_length: Application.get_env(:kv_server, :max_key_length)}
    IO.puts inspect state
    {:ok, state }
  end

  def handle_call({:resolveGet, key}, _from, state) do
    response =
      if checkKeyLength(state,key) do 
        dataStore = nextStore state, key
        case readOnStore(dataStore, :get, key) do
          {:found, result} -> 
            %{:status => "ok", :detail => result}
          :not_found ->
            %{:status => "error", :detail => "key not found"}
        end
      else
        %{:status => "error", :detail => "key too long"}
      end 
    {:reply, response, state}
  end

  def handle_call({:resolveFind, operator, value}, _from, state) do
  	tasks = 
			for i <- 0..(length state.dataStores) - 1 do
				Task.async(fn -> readOnStore(Enum.at(state.dataStores, i), :find, operator, value) end)
			end

		tasks_with_results = Task.yield_many(tasks, 10000)

		results = Enum.map(tasks_with_results, fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    IO.puts "\n#{inspect results}"
  	{:reply, (List.flatten(Enum.flat_map results, fn({x, y}) -> y end)), state}
  end

  def handle_call({:resolveSet, key, value}, _from, state) do
    response =
      if checkKeyLength(state,key) do
        dataStore = nextStore state, key
        	case writeOnStore(dataStore, key, value) do
            :ok ->
              %{:status => "ok"}
            :not_enough_space ->
              %{:status => "error", :detail => "the store is full"}
          end    	
      else
         %{:status => "error", :detail => "key too long"}
      end

    {:reply, response, state}
  end

  def handle_call({:resolveRemove, key}, _from, state) do
    response =
      if checkKeyLength(state,key) do 
        dataStore = nextStore state, key
        case removeOnStore(dataStore, key) do
          :ok -> 
            %{:status => "ok"}
          :not_found ->
            %{:status => "error", :detail => "key not found"}
        end
      else
        %{:status => "error", :detail => "Unexpected error"}
      end 
    {:reply, response, state}
  end

  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end
end