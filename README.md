# Group Info

 - Matthew Carr 9129-9208

# Instructions
Invoke the solver from the command line by calling
`mix run proj1.exs N k`
from the project's directory, where N and k are non-negative integers
whose semantics are described in the problem statement.

You may also invoke the solver from elixir by calling
`Proj1.run(N, k)`

There is a suite of tests included with the project which you can run with
`mix test` from the project's directory.

# Results
The result of running `mix run proj1.exs 1000000 4` is nothing, it produces no output.

Running `time run proj1 10000000 4` (where time is the Born Shell's built-in time command)
produced the output
```
real    0m1.015s
user    0m4.259s
sys     0m4.169s
```
which has a utilization ratio of 8.30. This was run on a Ryzen 2700X with 16GB of RAM using
16 workers. One can run the solver with a different number of
workers by calling `mix run proj1.exs N k num_workers`. The default number of workers is 8.

I used GNU time with the `-f%P` (which shows utilization percentage) and experimented with 
the number of workers to determine how many worked best. Note that the 2700X
is an 8 core superscalar processor, so 16 is the maximum number of concurrent threads of execution.
I also did some experimenting on my Athlon II X4 640 machine, which is a 4 core non-superscalar
processor, and found that 4 workers produced the optimum utilization ratio (which was about 3). So
it seems that the number of workers should equal the number of concurrent threads of execution to
produce optimal results. What a surprise!