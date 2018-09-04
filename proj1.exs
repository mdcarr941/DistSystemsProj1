limit = Integer.parse(hd System.argv)
k = Integer.parse(Enum.at(System.argv, 1))
if limit == :error or k == :error do
    IO.puts("This script's first and second arguments must be numbers.")
    exit(-1)
end
{limit, _} = limit
{k, _} = k

Proj1.run(limit, k)
# Enum.each(Proj1.make_blocks(limit, div(limit, 16)), fn(block) ->
#     with {block_start, block_limit} <- block,
#     do: IO.puts("start = #{block_start}, end = #{block_limit}")
# end)
#Proj1.work(k, {7, 76})