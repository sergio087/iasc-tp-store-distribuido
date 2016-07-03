defmodule KVData.Store do
	use GenServer

	def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :store)
  end

  def select(key \\ nil) do
		{:ok, result} = GenServer.call(:store, {:select, key})
		result
	end

	def insert(key, value) do
		{:ok, result} = GenServer.call(:store, {:insert, key, value})
		result
	end

  ## Server Callbacks

  def init(:ok) do
  	IO.puts "******** inicializa store *********"
  	{:ok, %{}}
  end

  def handle_call({:state}, _from, state) do
  	{:reply,state, state}
  end

  def handle_call({:select, condition}, _from, state) do
  	{:reply, Map.get(state, condition, nil), state}
  end

  def handle_call({:insert, key, value}, _from, state) do
  	{:reply, :ok, Map.put(state, key, value)}
  end

  def handle_info(_unknownmsg, state) do
    {:noreply, state}
  end

end