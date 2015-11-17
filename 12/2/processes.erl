% 用12.3节里的程序在你的机器上测量一下进程分裂所需要的时间。
% 在一张进程数量对进程创建时间的图上进行标绘。
% 你能从中得到什么结论。

-module(processes).
-export([max/1]).

max(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n", [Max]),
    % statistics 返回跟指定类型 Type 相关的系统信息
    % runtime 是cpu耗时，wall_clock 是代码运行时间
    statistics(runtime),
    statistics(wall_clock),
    L = for(1, N, fun() -> spawn(fun() -> wait() end) end),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    lists:foreach(fun(Pid) -> Pid ! die end, L),
    U1 = Time1 * 1000 / N,
    U2 = Time2 * 1000 / N,
    io:format("cpu:~p, time:~p~n", [U1, U2]).

wait() ->
    receive 
        die -> void
    end.


for(N, N, F) -> [F()];
for(I, N, F) -> [F() | for(I+1, N, F)].
