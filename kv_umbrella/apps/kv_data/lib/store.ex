defmodule KVData.Store do
	use GenServer

  defstruct dictionary: %{}, max_size: 0  

	def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :store)
  end

  def get(key) do
		GenServer.call :store, {:get, key}
	end

  def find(:gt, value) do
    GenServer.call :store, {:find, fn x -> value > x end}
  end

  def find(:lt, value) do
    GenServer.call :store, {:find, fn x -> value < x end}
  end

	def insert(key, value) do
		GenServer.call :store, {:insert, key, value}
	end

  defp checkFreeSpace(state) do
    (length (Map.keys state.dictionary)) < state.max_size
  end

  ## Server Callbacks

  def init(:ok) do
  	IO.puts ">>>> inicializa :store"
    state = %__MODULE__{dictionary: %{}, max_size: Application.get_env(:kv_data, :max_size)}
  	IO.puts inspect state
    {:ok, state}
  end

  def handle_call({:state}, _from, state) do
  	{:reply, state, state}
  end

  def handle_call({:get, key}, _from, state) do
    result = Map.get(state.dictionary, key, nil)
    if result != nil do
      {:reply, {:found, result}, state}
    else
      {:reply, :not_found, state}
    end
  end

  def handle_call({:find, fun}, _from, state) do
    result = Enum.filter (Map.values state.dictionary), fun 

    {:reply, result, state}
  end

  def handle_call({:insert, key, value}, _from, state) do
    #TODO validar capacidad maxima de claves a guardar
    if checkFreeSpace(state) do
  	  {:reply, :ok, %__MODULE__{dictionary: Map.put(state.dictionary, key, value), max_size: state.max_size}}
    else
      {:reply, :not_enough_space, state}
    end
  end

  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end

end