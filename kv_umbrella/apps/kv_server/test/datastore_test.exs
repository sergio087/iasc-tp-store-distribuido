defmodule KServer.DataStoreTest do
  use ExUnit.Case, async: true


  setup do
    {:ok, ds} = KVServer.DataStore.start_link
    {:ok, ds: ds}
  end

  test "test get without data", %{ds: ds} do
    assert KVServer.DataStore.getValue(ds, "Lionel") == nil

  end

  test "test set/get data", %{ds: ds} do

    KVServer.DataStore.setValue(ds, "Lionel", "Messi")
    assert KVServer.DataStore.getValue(ds, "Lionel") == "Messi"

  end

  test "test many sets", %{ds: ds} do

    KVServer.DataStore.setValue(ds, "Lionel", "Messi")
    KVServer.DataStore.setValue(ds, "Angel", "DiMaria")
    KVServer.DataStore.setValue(ds, "Gonzalo", "Higuain")
    KVServer.DataStore.setValue(ds, "Ever", "Banega")

    assert KVServer.DataStore.setValue(ds, "Javier", "Mascherano") == 5

  end

end
