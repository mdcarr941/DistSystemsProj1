limit = Integer.parse(hd System.argv)
k = Integer.parse(Enum.at(System.argv, 1))
num_workers = Integer.parse(Enum.at(System.argv, 2, ""))
if limit == :error or k == :error do
    IO.puts("This script's first and second arguments must be numbers.")
    exit(-1)
end
num_workers =
    if num_workers == :error do
        {8, ""}
    else
        num_workers
    end
{limit, _} = limit
{k, _} = k
{num_workers, _} = num_workers

Proj1.run(limit, k, num_workers) |> Enum.each(&(IO.puts(&1)))
