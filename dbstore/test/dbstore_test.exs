defmodule DbStoreTest do
  use ExUnit.Case
  doctest Dbstore

  test "greets the world" do
    assert Dbstore.hello() == :world
  end
end
