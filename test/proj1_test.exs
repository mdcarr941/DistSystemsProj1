defmodule Proj1Test do
  use ExUnit.Case
  doctest Proj1

  def solve(limit, k) do
    Proj1.work(k, {1, limit})
  end

  @doc """
  Verify that the sum of the squares of the integers from n to n + k - 1 is a square.
  """
  def verify(n, k, epsilon \\ 1.0e-32) do
    #root = :math.sqrt(Enum.reduce(Enum.map(Proj1.consecutive(k, [n]), &(&1 * &1)), &(&1 + &2)))
    root = Proj1.consecutive(k, [n])
      |> Enum.map(&(&1 * &1)) |> Enum.reduce(&(&1 + &2)) |> :math.sqrt
    root - trunc(root) < epsilon
  end

  test "test verify" do
    assert verify(3, 2)
    assert verify(1, 24)
  end

  test "solve the problem with N = 3 and k = 2" do
    output = solve(3, 2)
    assert length(output) == 1
    assert List.first(output) == 3
  end

  test "solve the problem with N = 20 and k = 24" do
    solve(20, 24) |> Enum.each(&(verify(&1, 24)))
  end

  test "test the make_blocks function" do
    blocks = Proj1.make_blocks(100, 10)
    assert length(blocks) == 10
    Enum.each(blocks,
      fn({block_start, block_limit}) -> assert block_limit - block_start == 9 end
    )
  end

  test "test run with N = 3 and k = 2" do
    output = Proj1.run(3, 2)
    assert length(output) == 1
    assert List.first(output) == 3
  end

  test "test run with N = 20 and k = 24" do
    Proj1.run(20, 24) |> Enum.each(&(verify(&1, 24)))
  end
end
