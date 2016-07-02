defmodule KV.DataStore do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
    Get value from key.
  """
  def getValue(server, key) do
    GenServer.call(server, {:getValue, key})
  end

  @doc """
    Set value from key. Return
  """
  def setValue(server, key, value) do
    GenServer.call(server, {:setValue, key, value})
  end

  ## Server Callbacks

  def init(:ok) do
    accumKeys = 0
    {:ok, pid} = KV.Bucket.start_link
    bucketMonitor = Process.monitor(pid)
    bucketPid = pid
    {:ok, {accumKeys, bucketPid, bucketMonitor}}
  end

  def handle_call({:getValue, key}, _from, {accumKeys, bucketPid, _} = state) do
    {:reply, KV.Bucket.get(bucketPid, key) , state}
  end


  def handle_call({:setValue, key, value}, _from, {accumKeys, bucketPid, bucketMonitor}) do
    KV.Bucket.put(bucketPid, key, value)
    newAccumKey = accumKeys + 1
    {:reply, newAccumKey, {newAccumKey, bucketPid, bucketMonitor}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {accumKeys, bucketPid, _}) do
    {:ok, newBucketPid} = KV.Bucket.start_link
    newBucketMonitorPid = Process.monitor(newBucketPid)
    {:noreply, {accumKeys, newBucketPid, newBucketMonitorPid}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
