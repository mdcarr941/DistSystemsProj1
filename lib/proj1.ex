defmodule Proj1 do
  @moduledoc """
  
  """

  @doc """
  Get the next {status, sq_sum, list} tuple.
  """
  def next(sq_sum, list, limit) do
    [{first, first_sq} | tail] = list
    if first >= limit do
      {:halt, sq_sum, list}
    else
      {last, _} = List.last(tail)
      last = last + 1
      last_sq = last * last
      sq_sum = sq_sum - first_sq + last_sq
      list = tail ++ [{last, last_sq}]
      {:ok, sq_sum, list}
    end
  end

  def check(limit, tup, epsilon \\ 1.0e-32) do
    {status, sq_sum, list} = tup
    if status != :halt do
      root = :math.sqrt(sq_sum)
      if root - trunc(root) < epsilon do
        {first, _} = hd list
        IO.puts(first)
      end
      check(limit, next(sq_sum, list, limit), epsilon)
    end
  end

  def consecutive(k, list \\ [1]) do
    if length(list) >= k do
      list
    else
      consecutive(k, list ++ [List.last(list) + 1])
    end
  end

  def begin(k, start \\ 1) do
    list = consecutive(k, [start])
    squares = Enum.map(list, &(&1 * &1))
    {
      :ok,
      Enum.reduce(squares, &(&1 + &2)),
      Enum.zip(list, squares)
    }
  end

  def work(k, block) do
    {start, limit} = block
    check(limit, begin(k, start))
  end

  def make_blocks(limit, block_size, blocks \\ [])
  when is_number(limit) and is_number(block_size) do
    block_size = max(block_size, 1)
    blocks =
      if length(blocks) > 0 do
        blocks
      else
        [{1, block_size}]
      end
    {_, last_limit} = List.last(blocks)
    block_start = last_limit + 1
    block_limit = block_start + block_size - 1
    if block_limit >= limit do
      blocks ++ [{block_start, limit}]
    else
      make_blocks(limit, block_size, blocks ++ [{block_start, block_limit}])
    end
  end

  def num_workers do
    16
  end

  def run(limit, k, num_workers \\ num_workers()) do
    make_blocks(limit, div(limit, num_workers))
      |> Enum.map( &(Task.async(Proj1, :work, [k, &1])) )
      |> Enum.each( &(Task.await(&1)) )
  end
end

defmodule Proj1.Utility do
  @moduledoc """
  Utility functions for Proj1.
  """

  @doc """
  Verify that the sum of the squares of the integers from n to n + k - 1 is a square.
  """
  def verify(n, k, epsilon \\ 1.0e-32) do
    root = :math.sqrt(Enum.reduce(Enum.map(Proj1.consecutive(k, [n]), &(&1 * &1)), &(&1 + &2)))
    root - trunc(root) < epsilon
  end
end