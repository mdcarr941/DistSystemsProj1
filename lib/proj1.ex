defmodule Proj1 do
  use GenServer
  @moduledoc """
  This module contains code which solves the following problem:
  Find all numbers b <= N such that \sum_{i=0}^{k-1} (b + i) is a square.
  To use this module from the command line call "mix run proj1.exs <N> <k>"
  from the project directory. If you wish to call this module from elixir you
  can invoke Proj1.run(N, k).
  """

  ### Server functions (used by workers).

  @doc """
  Get the next {status, sq_sum, list} tuple but return :halt when the first
  entry in list is greater than or equal to limit.
  """
  @spec next(integer, [{integer, integer}], integer) :: {:halt | :ok, integer, [{integer, integer}]}
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

  @doc """
  Recursively check if sq_sum is a perfect square until next returns :halt. Returns a list
  of solutions found.
  """
  @spec check(integer, {atom, integer, [{integer, integer}]}, number) :: [integer]
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

  @doc """
  Create a list of consecutive integers of length k starting at the last entry in list.
  """
  @spec consecutive(integer, [integer]) :: [integer]
  def consecutive(k, list \\ [1]) do
    if length(list) >= k do
      list
    else
      consecutive(k, list ++ [List.last(list) + 1])
    end
  end

  @doc """
  Create a {status, sq_sum, list} tuple to be used as the base case for the next function.
  """
  @spec begin(integer, integer) :: {:ok, number, [{integer, integer}]}
  def begin(k, start \\ 1) do
    list = consecutive(k, [start])
    squares = Enum.map(list, &(&1 * &1))
    {
      :ok,
      Enum.reduce(squares, &(&1 + &2)),
      Enum.zip(list, squares)
    }
  end

  @doc """
  Solve the problem of length k where the starting number b is such that start <= b <= limit.
  """
  @spec work(integer, {integer, integer}) :: [integer]
  def work(k, {start, limit}) do
    check(limit, begin(k, start))
  end

  @doc """
  Split up the integers {1, ..., limit} into disjoint blocks {block_start, ..., block_limit} such that
  block_limit - block_start + 1 <= block_size, where we have equality for all but perhaps
  the last entry.
  """
  @spec make_blocks(integer, integer, [{integer, integer}]) :: [{integer, integer}]
  def make_blocks(limit, block_size, blocks \\ []) do
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

  @doc """
  Initialize this GenServer with parameter k.
  """
  @spec init(integer) :: {:ok, {integer, [integer]}}
  def init(k) do
    {:ok, {k, []}}
  end

  @doc """
  Start a worker as an async task for the block {block_start, block_limit}. The workers
  pid is added to the task_pids list in the state.
  """
  @spec handle_cast({:start, integer, integer}, {integer, [integer]}) :: {:noreply, {integer, [integer]}}
  def handle_cast({:start, block_start, block_limit}, {k, task_pids}) do
    task_pid = Task.async(Proj1, :work, [k, {block_start, block_limit}])
    task_pids = [task_pid] ++ task_pids
    {:noreply, {k, task_pids}}
  end

  @doc """
  Wait for all the running workers to finish then return the concatenation of their output.
  """
  @spec handle_call(:yield, {pid, term}, {integer, [integer]}) :: {:reply, [integer], {integer, [integer]}}
  def handle_call(:yield, _from, {k, task_pids}) do
    solutions = Enum.map(task_pids, &(Task.yield(&1, :infinity)))
      |> Enum.map(fn({_, task_output}) -> task_output end)
      |> Enum.reduce(&(&1 ++ &2))
    {:reply, solutions, {k, []}}
  end

  ### Client functions.

  @doc """
  Tell the GenServer to start a worker to work from block_start to block_limit.
  """
  @spec start({integer, integer}) :: :ok
  def start({block_start, block_limit}) do
    GenServer.cast(__MODULE__, {:start, block_start, block_limit})
  end

  @doc """
  Get the output of all the workers from the GenServer.
  """
  @spec yield() :: [integer]
  def yield() do
    GenServer.call(__MODULE__, :yield, :infinity)
  end

  @doc """
  Split the problem with N = limit and k = k into num_workers blocks and solve
  each one concurrently.
  """
  @spec run(integer, integer, integer) :: [integer]
  def run(limit, k, num_workers \\ 8) do
    {:ok, _} = GenServer.start_link(__MODULE__, k, name: __MODULE__)
    make_blocks(limit, div(limit, num_workers)) |> Enum.map( &(Proj1.start(&1)) )
    yield()
  end
end
