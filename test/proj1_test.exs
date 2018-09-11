defmodule Proj1Test do
  use ExUnit.Case
  doctest Proj1

  @doc """
  Convenience wrapper around Proj1.work.
  """
  @spec solve(integer, integer) :: [integer]
  def solve(limit, k) do
    Proj1.work(k, {1, limit})
  end

  @doc """
  Verify that the sum of the squares of the integers from n to n + k - 1 is a square.
  """
  @spec verify(integer, integer, number) :: boolean
  def verify(n, k, epsilon \\ 1.0e-32) do
    root = Proj1.consecutive(k, [n])
      |> Enum.map(&(&1 * &1)) |> Enum.reduce(&(&1 + &2)) |> :math.sqrt
    root - trunc(root) < epsilon
  end

  test "test verify" do
    assert verify(3, 2)
    assert verify(1, 24)
  end

  test "solve the problem with N = 3 and k = 2" do
    assert solve(3, 2) == [3]
  end

  test "solve the problem with N = 20 and k = 24" do
    solve(20, 24) |> Enum.each(&(verify(&1, 24)))
  end

  test "test the make_blocks function" do
    assert Proj1.make_blocks(30, 10) == [{1, 10}, {11, 20}, {21, 30}]
  end

  test "test run with N = 3 and k = 2" do
    assert [3] == Proj1.run(3, 2)
  end

  test "test run with N = 20 and k = 24" do
    Proj1.run(20, 24) |> Enum.each(&(verify(&1, 24)))
  end

  test "test run with N = 10000000 and k = 4" do
    assert length(Proj1.run(10000000, 4)) == 0
  end
end
