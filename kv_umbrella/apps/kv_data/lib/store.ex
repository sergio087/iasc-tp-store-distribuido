defmodule KVData.Store do
	use GenServer

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

  ## Server Callbacks

  def init(:ok) do
  	IO.puts ">>>> inicializa :store"
  	{:ok, %{}}
  end

  def handle_call({:state}, _from, state) do
  	{:reply, state, state}
  end

  def handle_call({:get, key}, _from, state) do
    IO.puts inspect state
    result = Map.get(state, key, nil)
    IO.puts "#{key} => #{result}" 
    if result != nil do
      {:reply, {:found, result}, state}
    else
      {:reply, :not_found, state}
    end
  end

  def handle_call({:find, fun}, _from, state) do
    result = Enum.filter (Map.values state), fun 

    {:reply, result, state}
  end

  def handle_call({:insert, key, value}, _from, state) do
    #TODO validar capacidad maxima de claves a guardar
  	{:reply, :ok, Map.put(state, key, value)}
  end

  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end

end