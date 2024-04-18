defmodule Orderly.SortedMap do
  @moduledoc """
  Implementation of a sorted map based on Erlang's
  [`gb_trees`](https://www.erlang.org/doc/man/gb_trees).

  `SortedMap` has many of the core functions found in
  [`Map`](https://hexdocs.pm/elixir/1.16.2/Map.html). The important difference
  between `SortedMap` and `Map` is that the keys in an instance of a sorted
  map have a defined order, specifically the
  [Erlang term order](https://www.erlang.org/doc/reference_manual/expressions#term-comparisons).
  For example:

      map =
        [b: 2, a: 1, c: 3, a: 4]
        |> SortedMap.new()
        |> SortedMap.to_list()
      #=> [a: 4, b: 2, c: 3]

  Unlike `Map`, `SortedMap` is an opaque data structure that does not support
  pattern matching.

  `SortedMap` implements the `Enumerable` protocol, and so `Enum`
  functions can be applied to sorted maps. When applying `Stream` functions
  to a sorted map, it is recommended to first create a stream using
  `SortedMap.to_stream/1` or `SortedMap.to_stream/2`, which adapts the effecient
  lazy iterator pattern provided by `gb_trees`.
  """

  alias __MODULE__

  defstruct [:map]

  @type key() :: any()
  @type value() :: any()
  @type map(key, value) :: :gb_trees.tree(key, value)
  @type t(key, value) :: %SortedMap{map: map(key, value)}
  @type t() :: t(any(), any())
  @type iter() :: :gb_trees.iter()

  @doc """
  Create an empty map.

  ## Examples

      iex> Orderly.SortedMap.new()
      Orderly.SortedMap.new([])
  """
  @spec new() :: t()
  def new(), do: %SortedMap{map: :gb_trees.empty()}

  @doc """
  Create a new map from the given `enumerable`.

  ## Examples

      iex> Orderly.SortedMap.new([a: 1, b: 2])
      Orderly.SortedMap.new([a: 1, b: 2])

      iex> Orderly.SortedMap.new(%{a: 1, b: 2})
      Orderly.SortedMap.new([a: 1, b: 2])
  """
  @spec new(Enumerable.t()) :: t()
  def new(%SortedMap{} = sorted_map), do: sorted_map

  def new(enumerable) do
    map =
      Enum.reduce(enumerable, :gb_trees.empty(), fn {k, v}, m ->
        :gb_trees.enter(k, v, m)
      end)

    %SortedMap{map: map}
  end

  @doc """
  Insert `value` under `key` into `sorted_map`.

  If `key` is present, its value is updated to the given `value`. If `key`
  is absent, `key` and `value` are added to `sorted_map`.

  ## Examples

      iex> Orderly.SortedMap.new() |> Orderly.SortedMap.put(:a, 1)
      Orderly.SortedMap.new([a: 1])
  """
  @spec put(t(), key(), value()) :: t()
  def put(%SortedMap{map: map} = sorted_map, key, value) do
    %{sorted_map | map: :gb_trees.enter(key, value, map)}
  end

  @doc """
  Check if `sorted_map` has the given `key`.

  ## Examples

      iex> [a: 1] |> Orderly.SortedMap.new() |> Orderly.SortedMap.has_key?(:a)
      true
  """
  @spec has_key?(t(), key()) :: boolean()
  def has_key?(%SortedMap{map: map} = _sorted_map, key), do: :gb_trees.is_defined(key, map)

  @doc """
  Get the value for the given `key` in `sorted_map.

  If `key` is present, the corresponding value is returned. Otherwise,
  `default` is returned. If `default` is not provided, `nil` is returned.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1])
      iex> Orderly.SortedMap.get(map, :a)
      1
      iex> Orderly.SortedMap.get(map, :b, 2)
      2
  """
  @spec get(t(), key(), value()) :: value()
  def get(%SortedMap{map: map} = sorted_map, key, default \\ nil) do
    if has_key?(sorted_map, key) do
      :gb_trees.get(key, map)
    else
      default
    end
  end

  @doc """
  Fetch the value for the given `key` in `sorted_map`.

  This returns `{:ok, value}` if the `key` is present, and `:error` otherwise.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1])
      iex> Orderly.SortedMap.fetch(map, :a)
      {:ok, 1}
      iex> Orderly.SortedMap.fetch(map, :b)
      :error
  """
  @spec fetch(t(), key()) :: {:ok, value()} | :error
  def fetch(%SortedMap{map: map} = sorted_map, key) do
    if has_key?(sorted_map, key) do
      {:ok, :gb_trees.get(key, map)}
    else
      :error
    end
  end

  @doc """
  Delete the key-value pair for the given `key` in `sorted_map`.

  If `key` is not present, the map is returned unchanged.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1])
      iex> Orderly.SortedMap.delete(map, :a)
      Orderly.SortedMap.new([])
      iex> Orderly.SortedMap.delete(map, :b)
      Orderly.SortedMap.new([a: 1])
  """
  @spec delete(t(), key()) :: t()
  def delete(%SortedMap{map: map} = sorted_map, key) do
    %{sorted_map | map: :gb_trees.delete_any(key, map)}
  end

  @doc """
  Return the number of key-value pairs in `sorted_map`.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1])
      iex> Orderly.SortedMap.size(map)
      1
  """
  @spec size(t()) :: non_neg_integer()
  def size(%SortedMap{map: map} = _sorted_map), do: :gb_trees.size(map)

  @doc """
  Update the value under the given `key` in `sorted_map` with given function
  `fun`.

  If `key` is present, `fun` is applied to the existing value to obtain the
  updated value. If `key` is not present, `default` is inserted under `key`.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1])
      iex> Orderly.SortedMap.update(map, :a, nil, & &1 + 1)
      Orderly.SortedMap.new([a: 2])
      iex> Orderly.SortedMap.update(map, :b, 2, & &1 + 1)
      Orderly.SortedMap.new([a: 1, b: 2])
  """
  @spec update(t(), key(), value(), (value() -> value())) :: t()
  def update(%SortedMap{} = sorted_map, key, default, fun) do
    case fetch(sorted_map, key) do
      {:ok, value} ->
        put(sorted_map, key, fun.(value))

      :error ->
        put(sorted_map, key, default)
    end
  end

  @doc """
  Convert `sorted_map` into a sorted list of elements.

  ## Examples

      iex> Orderly.SortedMap.new([a: 1, b: 2]) |> Orderly.SortedMap.to_list()
      [a: 1, b: 2]
  """
  @spec to_list(t(key(), value())) :: [{key(), value()}]
  def to_list(%SortedMap{map: map} = _sorted_map), do: :gb_trees.to_list(map)

  @spec equal?(t(), t()) :: boolean()
  def equal?(%SortedMap{} = sorted_map1, %SortedMap{} = sorted_map2) do
    to_list(sorted_map1) == to_list(sorted_map2)
  end

  @doc """
  Removs the value associated with `key` in `sorted_map` and return the value
  and the updated map.

  If `key` is present in `sorted_map`, it returns `{value, updated_map}` where
  `value` is the value associated with `key` and `updated_map` is the result of
  removing `key` from `sorted_map`. If key is not present in map,
  `{default, sorted_map}` is returned.

  ## Examples

      iex> map = Orderly.SortedMap.new([a: 1, b: 2])
      iex> Orderly.SortedMap.pop(map, :a)
      {1, Orderly.SortedMap.new([b: 2])}
      iex> Orderly.SortedMap.pop(map, :c, 3)
      {3, map}
  """
  @spec pop(t(), key(), value()) :: {value(), t()}
  def pop(%SortedMap{} = sorted_map, key, default \\ nil) do
    case fetch(sorted_map, key) do
      {:ok, value} -> {value, delete(sorted_map, key)}
      :error -> {default, sorted_map}
    end
  end

  @doc """
  Return the list of keys in `sorted_map`.

  The keys are returned in key-order.

  ## Examples

      iex> [b: 2, a: 1] |> Orderly.SortedMap.new() |> Orderly.SortedMap.keys()
      [:a, :b]

      iex> Orderly.SortedMap.new() |> Orderly.SortedMap.keys()
      []
  """
  @spec keys(t()) :: [key()]
  def keys(%SortedMap{map: map} = _sorted_map), do: :gb_trees.keys(map)

  @doc """
  Return the list of values in `sorted_map`.

  The values are returned in key-order.

  ## Examples

      iex> [b: 2, a: 1] |> Orderly.SortedMap.new() |> Orderly.SortedMap.values()
      [1, 2]

      iex> Orderly.SortedMap.new() |> Orderly.SortedMap.values()
      []
  """
  @spec values(t()) :: [value()]
  def values(%SortedMap{map: map} = _sorted_map), do: :gb_trees.values(map)

  @doc """
  Return the key-value pair with the smallest key in `sorted_set`.

  This returns `{:ok, {key, value}}` if the set is non-empty, and `:error` otherwise.

  ## Examples

      iex> [b: 2, a: 1] |> Orderly.SortedMap.new() |> Orderly.SortedMap.smallest()
      {:ok, {:a, 1}}

      iex> Orderly.SortedMap.new([]) |> Orderly.SortedMap.smallest()
      :error
  """
  @spec smallest(t()) :: {:ok, {key(), value()}} | :error
  def smallest(%SortedMap{map: map} = sorted_map) do
    if size(sorted_map) > 0 do
      {:ok, :gb_trees.smallest(map)}
    else
      :error
    end
  end

  @doc """
  Create a [`Stream`](https://hexdocs.pm/elixir/Stream.html) from `sorted_map`
  that emits key-value pairs in key-order starting from the smallest key in
  the map.

  To generate values lazily, this uses
  [`:gb_trees.iterator/1`](https://www.erlang.org/doc/man/gb_trees#iterator-1) and
  [`:gb_trees.next/1`](https://www.erlang.org/doc/man/gb_trees#next-1).

  ## Examples

      iex> map = Orderly.SortedMap.new([b: 2, a: 1, c: 3])
      iex> stream = Orderly.SortedMap.to_stream(map)
      iex> stream |> Enum.take(2)
      [a: 1, b: 2]
      iex> stream |> Enum.filter(fn {_k, v} -> rem(v, 2) == 0 end)
      [b: 2]
  """
  @spec to_stream(t()) :: Enumerable.t()
  def to_stream(sorted_map) do
    sorted_map |> to_iterator() |> stream_from_iter()
  end

  @doc """
  Create a [`Stream`](https://hexdocs.pm/elixir/Stream.html) from `sorted_map`
  that emits key-value pairs in key-order starting from the first key in the
  map greater than or equal to `start_key`.

  To generate values lazily, this uses
  [`:gb_trees.iterator_from/2`](https://www.erlang.org/doc/man/gb_trees#iterator_from-2) and
  [`:gb_trees.next/1`](https://www.erlang.org/doc/man/gb_trees#next-1).

  ## Examples

      iex> map = Orderly.SortedMap.new([b: 2, a: 1, c: 3])
      iex> stream = Orderly.SortedMap.to_stream(map, :b)
      iex> stream |> Enum.take(2)
      [b: 2, c: 3]
      iex> stream |> Enum.filter(fn {_k, v} -> rem(v, 2) != 0 end)
      [c: 3]
  """
  @spec to_stream(t(), value()) :: Enumerable.t()
  def to_stream(sorted_map, start_key) do
    sorted_map |> to_iterator(start_key) |> stream_from_iter()
  end

  # Creata a stream from a sorted map iterator
  @spec stream_from_iter(iter()) :: Enumerable.t()
  defp stream_from_iter(iter) do
    Stream.resource(
      fn -> iter end,
      fn iter ->
        case next(iter) do
          {:ok, {key, value}, iter} -> {[{key, value}], iter}
          :error -> {:halt, iter}
        end
      end,
      fn items -> items end
    )
  end

  @spec to_iterator(t()) :: iter()
  defp to_iterator(%SortedMap{map: map} = _sorted_map), do: :gb_trees.iterator(map)

  @spec to_iterator(t(), key()) :: iter()
  defp to_iterator(%SortedMap{map: map} = _sorted_map, start_key),
    do: :gb_trees.iterator_from(start_key, map)

  @spec next(iter()) :: {:ok, {key(), value()}, iter()} | :error
  defp next(iter) do
    case :gb_trees.next(iter) do
      {key, value, iter} -> {:ok, {key, value}, iter}
      :none -> :error
    end
  end

  defimpl Enumerable do
    def count(sorted_map) do
      {:ok, SortedMap.size(sorted_map)}
    end

    def member?(sorted_map, {key, value}) do
      case SortedMap.fetch(sorted_map, key) do
        {:ok, v} ->
          if v == value do
            {:ok, true}
          else
            false
          end

        :error ->
          false
      end
    end

    def slice(sorted_map) do
      size = SortedMap.size(sorted_map)
      {:ok, size, &SortedMap.to_list/1}
    end

    def reduce(sorted_map, acc, fun) do
      Enumerable.List.reduce(SortedMap.to_list(sorted_map), acc, fun)
    end
  end

  defimpl Collectable do
    def into(sorted_map) do
      fun = fn
        acc, {:cont, {key, value}} -> SortedMap.put(acc, key, value)
        acc, :done -> acc
        _, :halt -> :ok
      end

      {sorted_map, fun}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(sorted_map, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}
      concat(["SortedMap.new(", Inspect.List.inspect(SortedMap.to_list(sorted_map), opts), ")"])
    end
  end
end
