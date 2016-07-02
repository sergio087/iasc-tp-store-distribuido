defmodule KV.DataStoreTest do
  use ExUnit.Case, async: true


  setup do
    {:ok, ds} = KV.DataStore.start_link
    {:ok, ds: ds}
  end

  test "test get without data", %{ds: ds} do
    assert KV.DataStore.getValue(ds, "Lionel") == nil

  end

  test "test set/get data", %{ds: ds} do

    KV.DataStore.setValue(ds, "Lionel", "Messi")
    assert KV.DataStore.getValue(ds, "Lionel") == "Messi"

  end

  test "test many sets", %{ds: ds} do

    KV.DataStore.setValue(ds, "Lionel", "Messi")
    KV.DataStore.setValue(ds, "Angel", "DiMaria")
    KV.DataStore.setValue(ds, "Gonzalo", "Higuain")
    KV.DataStore.setValue(ds, "Ever", "Banega")

    assert KV.DataStore.setValue(ds, "Javier", "Mascherano") == 5

  end

end
