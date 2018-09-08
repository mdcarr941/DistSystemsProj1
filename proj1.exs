limit = Integer.parse(hd System.argv)
k = Integer.parse(Enum.at(System.argv, 1))
if limit == :error or k == :error do
    IO.puts("This script's first and second arguments must be numbers.")
    exit(-1)
end
{limit, _} = limit
{k, _} = k

Proj1.run(limit, k) |> Enum.each(&(IO.puts(&1)))
