% 查看 erlang:now/0、erlang:data/0 和 erlang:time/0 的定义。
% 编写一个名为 my_time_func(F) 的函数，让它执行 fun F 并记下执行时间。
% 编写一个名为 my_date_string() 的函数，用它把当前的日期和时间改成整齐的格式

-module(mytimefunc).
-export([my_time_func/1, my_date_string/0]).

my_time_func(F) ->
    %{MegaSecs1, Secs1, MicroSecs1} = erlang:now(),
    {Hour1, Minute1, Second1} = erlang:time(),
    F,
    %{MegaSecs2, Secs2, MicroSecs2} = erlang:now(),
    {Hour2, Minute2, Second2} = erlang:time(),
    io:format("runtime:~f~n", [((Hour2-Hour1)/3600+(Minute2-Minute1)/60+(Second2-Second1))/1000]).

my_date_string() ->
    {Year, Month, Day} = erlang:date(),
    {Hour, Minute, Second} = erlang:time(),
    io:format("~p年~p月~p日:~p时~p分~p秒~n", [Year, Month, Day, Hour, Minute, Second]).
