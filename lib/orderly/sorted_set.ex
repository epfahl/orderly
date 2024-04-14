defmodule Orderly.SortedSet do
  alias __MODULE__

  defstruct [:set]

  @type value() :: any()
  @type set(value) :: :gb_sets.set(value)
  @type t(value) :: %SortedSet{set: set(value)}
  @type t() :: t(any())

  @doc """
  Create an empty set.

  ## Examples

      iex> Orderly.SortedSet.new()
      Orderly.SortedSet.new([])
  """
  @spec new() :: t()
  def new(), do: %SortedSet{set: :gb_sets.new()}

  @doc """
  Create a new set from the given `enumerable`.

  ## Examples

      iex> Orderly.SortedSet.new([3, 1, 2])
      Orderly.SortedSet.new([1, 2, 3])

      iex> Orderly.SortedSet.new([{1, 2}, {2, 4}, {1, 3}])
      Orderly.SortedSet.new([{1, 2}, {1, 3}, {2, 4}])
  """
  @spec new(Enumerable.t()) :: t()
  def new(%SortedSet{} = sorted_set), do: sorted_set

  def new(enumerable) do
    set =
      enumerable
      |> Enum.to_list()
      |> :gb_sets.from_list()

    %SortedSet{set: set}
  end

  @doc """
  Insert `value` into `sorted_set`.

  ## Examples

      iex> Orderly.SortedSet.new([]) |> Orderly.SortedSet.put(1)
      Orderly.SortedSet.new([1])
  """
  @spec put(t(), value()) :: t()
  def put(%SortedSet{set: set} = sorted_set, value) do
    %{sorted_set | set: :gb_sets.add_element(value, set)}
  end

  @doc """
  Delete `value` from `sorted_set`.

  This returns a set without `value`. If `value` is not present, the original
  set is returned unchanged.

  ## Examples

      iex> set = Orderly.SortedSet.new([2, 1, 3])
      iex> Orderly.SortedSet.delete(set, 2)
      Orderly.SortedSet.new([1, 3])
      iex> Orderly.SortedSet.delete(set, 4)
      Orderly.SortedSet.new([1, 2, 3])
  """
  @spec delete(t(), value()) :: t()
  def delete(%SortedSet{set: set} = sorted_set, value) do
    %{sorted_set | set: :gb_sets.delete_any(value, set)}
  end

  @doc """
  Check if `value` is contained in `sorted_set`.

  ## Examples

      iex> set = Orderly.SortedSet.new([2, 1, 3])
      iex> Orderly.SortedSet.member?(set, 2)
      true
      iex> Orderly.SortedSet.member?(set, 4)
      false
  """
  @spec member?(t(), value()) :: boolean()
  def member?(%SortedSet{set: set} = _sorted_set, element), do: :gb_sets.is_element(element, set)

  @doc """
  Get the number of elements in `sorted_set`.

  ## Examples

      iex> Orderly.SortedSet.new([2, 1, 3]) |> Orderly.SortedSet.size()
      3
  """
  @spec size(t()) :: non_neg_integer()
  def size(%SortedSet{set: set} = _sorted_set), do: :gb_sets.size(set)

  @doc """
  Check if two sorted sets are equal.

  This checks the equality of the list representations.

  ## Examples

      iex> set1 = Orderly.SortedSet.new([2, 1, 3])
      iex> set2 = Orderly.SortedSet.new([3, 2, 1])
      iex> Orderly.SortedSet.equal?(set1, set2)
  """
  @spec equal?(t(), t()) :: boolean()
  def equal?(%SortedSet{} = sorted_set1, %SortedSet{} = sorted_set2) do
    to_list(sorted_set1) == to_list(sorted_set2)
  end

  @doc """
  Convert `sorted_set` into a sorted list of elements.

  ## Examples

      iex> Orderly.SortedSet.new([2, 1, 3]) |> Orderly.SortedSet.to_list()
      [1, 2, 3]
  """
  @spec to_list(t(value)) :: [value]
  def to_list(%SortedSet{set: set} = _sorted_set), do: :gb_sets.to_list(set)

  @doc """
  Obtain a set that contains all elements of `sorted_set1` and `sorted_set2`.

  ## Examples

      iex> set1 = Orderly.SortedSet.new([2, 1, 3])
      iex> set2 = Orderly.SortedSet.new([4, 5])
      iex> Orderly.SortedSet.union(set1, set2) |> Orderly.SortedSet.to_list()
      [1, 2, 3, 4, 5]
  """
  @spec union(t(), t()) :: t()
  def union(%SortedSet{set: set1} = _sorted_set1, %SortedSet{set: set2} = _sorted_set2) do
    %SortedSet{set: :gb_sets.union(set1, set2)}
  end

  @doc """
  Obtain a set with the elements of `sorted_set` that are not contained in `sorted_set2`.

  ## Examples

      iex> set1 = Orderly.SortedSet.new([2, 1, 3])
      iex> set2 = Orderly.SortedSet.new([1, 2])
      iex> Orderly.SortedSet.difference(set1, set2) |> Orderly.SortedSet.to_list()
      [3]
  """
  @spec difference(t(), t()) :: t()
  def difference(%SortedSet{set: set1} = _sorted_set1, %SortedSet{set: set2} = _sorted_set2) do
    %SortedSet{set: :gb_sets.difference(set1, set2)}
  end

  @doc """
  Obtain a set with elements in both `sorted_set1` and `sorted_set2`.

  ## Examples

      iex> set1 = Orderly.SortedSet.new([2, 1, 3])
      iex> set2 = Orderly.SortedSet.new([1, 2])
      iex> Orderly.SortedSet.intersection(set1, set2) |> Orderly.SortedSet.to_list()
      [1, 2]
  """
  @spec intersection(t(), t()) :: t()
  def intersection(%SortedSet{set: set1}, %SortedSet{set: set2}) do
    %SortedSet{set: :gb_sets.intersection(set1, set2)}
  end

  @doc """
  Checks if all of the elements in `sorted_set1` are contained in `sorted_set2`.

  ## Examples

      iex> set1 = Orderly.SortedSet.new([2, 1, 3])
      iex> set2 = Orderly.SortedSet.new([1, 2])
      iex> Orderly.SortedSet.subset?(set2, set1)
      true
  """
  @spec subset?(t(), t()) :: boolean()
  def subset?(%SortedSet{set: set1}, %SortedSet{set: set2}), do: :gb_sets.is_subset(set1, set2)

  @doc """
  Get the element with the smallest value in `sorted_set`.

  This returns `{:ok, value}` if the set is non-empty, and `:error` otherwise.

  ## Examples

      iex> Orderly.SortedSet.new([2, 1, 3]) |> Orderly.SortedSet.smallest()
      {:ok, 1}

      iex> Orderly.SortedSet.new([]) |> Orderly.SortedSet.smallest()
      :error
  """
  @spec smallest(t()) :: {:ok, value()} | :error
  def smallest(%SortedSet{set: set} = sorted_set) do
    if size(sorted_set) > 0 do
      {:ok, :gb_sets.smallest(set)}
    else
      :error
    end
  end

  defimpl Enumerable do
    def count(sorted_set) do
      {:ok, SortedSet.size(sorted_set)}
    end

    def member?(sorted_set, value) do
      {:ok, SortedSet.member?(sorted_set, value)}
    end

    def slice(sorted_set) do
      size = SortedSet.size(sorted_set)
      {:ok, size, &SortedSet.to_list/1}
    end

    def reduce(sorted_set, acc, fun) do
      Enumerable.List.reduce(SortedSet.to_list(sorted_set), acc, fun)
    end
  end

  defimpl Collectable do
    def into(sorted_set) do
      fun = fn
        acc, {:cont, x} -> SortedSet.put(acc, x)
        acc, :done -> acc
        _, :halt -> :ok
      end

      {sorted_set, fun}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(sorted_set, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}
      concat(["SortedSet.new(", Inspect.List.inspect(SortedSet.to_list(sorted_set), opts), ")"])
    end
  end
end
