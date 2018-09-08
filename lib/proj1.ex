defmodule Proj1 do
  use GenServer
  @moduledoc """
  This module contains code which solves the following problem:
  Find all numbers b <= N such that \sum_{i=0}^{k-1} (b + i) is a square.
  To use this module simply call Proj1.run(N, k) and a list of solutions
  will be returned.
  """

  ### Server functions (used by workers).

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

  def check(limit, {status, sq_sum, list}, epsilon \\ 1.0e-32) do
    if status != :halt do
      root = :math.sqrt(sq_sum)
      output =
        if root - trunc(root) < epsilon do
          {first, _} = hd list
          [first]
        else
          []
        end
      output ++ check(limit, next(sq_sum, list, limit), epsilon)
    else
      []
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

  def work(k, {start, limit}) do
    check(limit, begin(k, start))
  end

  def make_blocks(limit, block_size, blocks \\ [])
  when is_number(limit) and is_number(block_size) do
    block_size = max(block_size, 1) # prevent block_size < 1
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

  def init({callback_pid, k}) do
    {:ok, {callback_pid, k, []}}
  end

  def handle_cast({:start, block_start, block_limit}, {callback_pid, k, task_pids}) do
    task_pid = Task.async(Proj1, :work, [k, {block_start, block_limit}])
    task_pids = [task_pid] ++ task_pids
    {:noreply, {callback_pid, k, task_pids}}
  end

  def handle_call(:yield, _from, {callback_pid, k, task_pids}) do
    solutions = Enum.map(task_pids, &(Task.yield(&1, :infinity)))
      |> Enum.map(fn({_, task_output}) -> task_output end)
      |> Enum.reduce(&(&1 ++ &2))
    {:reply, solutions, {callback_pid, k, []}}
  end

  ### Client functions (used by supervisor).

  def start({block_start, block_limit}) do
    GenServer.cast(__MODULE__, {:start, block_start, block_limit})
  end

  def yield() do
    GenServer.call(__MODULE__, :yield, :infinity)
  end

  def run(limit, k, num_workers \\ 16) do
    {:ok, _} = GenServer.start_link(__MODULE__, {self(), k}, name: __MODULE__)
    make_blocks(limit, div(limit, num_workers)) |> Enum.map( &(Proj1.start(&1)) )
    yield()
  end
end
