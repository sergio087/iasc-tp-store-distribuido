defmodule KVServer.BucketTest do
  use ExUnit.Case, async: true
  doctest KVServer


  setup do
    {:ok, bucket} = KVServer.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KVServer.Bucket.get(bucket, "milk") == nil

    KVServer.Bucket.put(bucket, "milk", 3)
    assert KVServer.Bucket.get(bucket, "milk") == 3
  end
end
