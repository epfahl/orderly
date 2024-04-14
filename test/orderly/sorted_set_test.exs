defmodule Orderly.SortedSetTest do
  use ExUnit.Case
  doctest Orderly.SortedSet

  alias Orderly.SortedSet

  test "basic collection operations" do
    set = SortedSet.new([2, 3, 1])

    assert [1, 2, 3] == SortedSet.to_list(set)
    assert [1, 2, 3, 4] == SortedSet.put(set, 4) |> SortedSet.to_list()
    assert [1, 3] == SortedSet.delete(set, 2) |> SortedSet.to_list()
    assert [1, 2, 3] == SortedSet.delete(set, 4) |> SortedSet.to_list()
    assert 3 == SortedSet.size(set)
    assert SortedSet.member?(set, 3)
    assert SortedSet.equal?(set, SortedSet.new([1, 2, 3]))
  end

  test "smallest value of empty set" do
    assert :error == SortedSet.new() |> SortedSet.smallest()
  end

  test "smallest value of non-empty set" do
    assert {:ok, 1} == SortedSet.new([2, 3, 1]) |> SortedSet.smallest()
  end

  test "set operations" do
    set1 = SortedSet.new([3, 1, 5])
    set2 = SortedSet.new([1, 4])
    set3 = SortedSet.new([1, 5])

    assert [1, 3, 4, 5] == SortedSet.union(set1, set2) |> SortedSet.to_list()
    assert [3, 5] == SortedSet.difference(set1, set2) |> SortedSet.to_list()
    assert [1] == SortedSet.intersection(set1, set2) |> SortedSet.to_list()
    assert SortedSet.subset?(set3, set1)
    assert not SortedSet.subset?(set2, set1)
  end

  test "enumerable" do
    set = SortedSet.new([3, 1, 2])

    assert 3 == Enum.count(set)
    assert [2, 3, 4] == Enum.map(set, &(&1 + 1))
    assert [2] == Enum.filter(set, &(rem(&1, 2) == 0))
    assert 6 = Enum.reduce(set, 0, &(&1 + &2))
    assert Enum.member?(set, 2)
  end

  test "collectable" do
    assert [1, 2, 3] == SortedSet.new([3, 1, 2]) |> Enum.into([])
  end
end
