defmodule OrderlyTest do
  use ExUnit.Case
  doctest Orderly

  test "greets the world" do
    assert Orderly.hello() == :world
  end
end
