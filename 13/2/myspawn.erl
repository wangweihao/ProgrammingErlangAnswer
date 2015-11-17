% 用本章前面展示的 on_exit 函数来完成上一个练习。

-module(myspawn).
-export([my_spawn/3]).

my_spawn(Mod, Func, Args) ->
    {Hour1, Minute1, Second1} = time(),
    on_exit(spawn(Mod, Func, Args), fun() -> io:format("error......~n") end),
    {Hour2, Minute2, Second2} = time(),
    io:format("time:~p~n", [(Hour2-Hour1)*60*60 + (Minute2-Minute1)*60 + (Second2-Second1)]).


on_exit(Pid, Fun) ->
    spawn(fun() -> 
          Ref = monitor(process, Pid),
          receive
              {'DOWN', Ref, process, Pid, Why} ->
                  Fun(Why)
          end  
    end).
