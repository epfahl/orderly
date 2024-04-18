defmodule Orderly.SortedMapTest do
  use ExUnit.Case
  doctest Orderly.SortedMap

  alias Orderly.SortedMap

  test "new and put" do
    map =
      SortedMap.new()
      |> SortedMap.put("b", 2)
      |> SortedMap.put("a", 1)
      |> SortedMap.put("c", 3)
      |> SortedMap.put("a", 4)

    assert [{"a", 4}, {"b", 2}, {"c", 3}] == SortedMap.to_list(map)
  end

  test "basic collection operations" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}, {"a", 4}])

    assert [{"a", 4}, {"b", 2}, {"c", 3}] == SortedMap.to_list(map)

    assert [{"a", 4}, {"b", 2}, {"c", 3}, {"d", 4}] ==
             map |> SortedMap.put("d", 4) |> SortedMap.to_list()

    assert [{"a", 4}, {"c", 3}] == map |> SortedMap.delete("b") |> SortedMap.to_list()
    assert [{"a", 4}, {"b", 2}, {"c", 3}] == map |> SortedMap.delete("d") |> SortedMap.to_list()
    assert 3 == SortedMap.size(map)
    assert SortedMap.has_key?(map, "b")
    assert not SortedMap.has_key?(map, "d")
    assert SortedMap.equal?(map, SortedMap.new([{"a", 4}, {"b", 2}, {"c", 3}]))
  end

  test "map to sorted map" do
    assert [{1, "a"}, {2, "b"}, {3, "c"}] ==
             %{2 => "b", 1 => "a", 3 => "c"}
             |> SortedMap.new()
             |> SortedMap.to_list()
  end

  test "error on smallest of empty map" do
    assert :error == SortedMap.new() |> SortedMap.smallest()
  end

  test "smallest key-value pair of non-empty map" do
    assert {:ok, {"a", 4}} ==
             [{"b", 2}, {"a", 1}, {"c", 3}, {"a", 4}]
             |> SortedMap.new()
             |> SortedMap.smallest()
  end

  test "get" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}])

    assert 2 == SortedMap.get(map, "b")
    assert 11 == SortedMap.get(map, "d", 11)
  end

  test "fetch" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}])

    assert {:ok, 2} == SortedMap.fetch(map, "b")
    assert :error == SortedMap.fetch(map, "d")
  end

  test "pop" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}])

    assert {2, _} = SortedMap.pop(map, "b")
    assert {11, ^map} = SortedMap.pop(map, "d", 11)
  end

  test "update" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}])

    assert 3 == map |> SortedMap.update("b", nil, &(&1 + 1)) |> SortedMap.get("b")
    assert 11 == map |> SortedMap.update("d", 11, &(&1 + 1)) |> SortedMap.get("d")
  end

  test "keys empty" do
    assert [] == SortedMap.new() |> SortedMap.keys()
  end

  test "keys non-empty" do
    assert ["a"] == SortedMap.new([{"a", 1}]) |> SortedMap.keys()
  end

  test "values empty" do
    assert [] == SortedMap.new() |> SortedMap.values()
  end

  test "values non-empty" do
    assert [1] == SortedMap.new([{"a", 1}]) |> SortedMap.values()
  end

  test "stream" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}, {"a", 4}])
    stream = map |> SortedMap.to_stream()
    stream_from = map |> SortedMap.to_stream("b")

    assert [{"a", 4}, {"b", 2}, {"c", 3}] == stream |> Enum.take(3)
    assert [{"b", 2}, {"c", 3}] == stream_from |> Enum.take(3)
    assert [{"a", 4}, {"b", 2}] == stream |> Enum.take_while(&(elem(&1, 0) <= "b"))
  end

  test "enumerable" do
    map = SortedMap.new([{"b", 2}, {"a", 1}, {"c", 3}, {"a", 4}])

    assert 3 == Enum.count(map)

    assert [{"a", 5}, {"b", 3}, {"c", 4}] ==
             Enum.map(map, fn {k, v} -> {k, v + 1} end) |> Enum.to_list()

    assert [{"a", 4}, {"b", 2}] ==
             Enum.filter(map, fn {_k, v} -> rem(v, 2) == 0 end) |> Enum.to_list()

    assert 9 == Enum.reduce(map, 0, fn {_k, v}, acc -> acc + v end)
    assert Enum.member?(map, {"b", 2})
  end

  test "collectable" do
    assert [{"a", 1}, {"b", 2}, {"c", 3}] ==
             [{"b", 2}, {"a", 1}, {"c", 3}] |> SortedMap.new() |> Enum.into([])
  end
end
