defmodule Orderly.SortedMap do
  alias __MODULE__

  def new()

  def new(enumerable)

  def put(sorted_map, key, value)

  def get(sorted_map, key)

  def fetch(sorted_map, key)

  def delete(sorted_map, key)

  def update(sorted_map, key, fun)

  def equal?(sorted_map1, sorted_map2)

  def pop(sorted_map, key)

  def to_list(sorted_map)

  def keys(sorted_map)

  def values(sorted_map)

  def smallest()

  def to_stream()
end
