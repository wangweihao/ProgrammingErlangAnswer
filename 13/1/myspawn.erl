% 编写一个 my_spawn(Mod, Func, Args) 函数。它的行为类似 spawn(Mod, Func, Args)，
% 但有一点区别。如果分裂出的进程挂了，就应打印出一个消息，说明进程挂掉的原因以及
% 在此之前存货了多长时间。

-module(myspawn).
-export([my_spawn/3]).

-spec my_spawn(Mod, Func, Args) -> pid() when
    Mod  :: atom(),
    Func :: atom(),
    Args :: [T],
    T    :: term().


my_spawn(Mod, Func, Args) ->
    {Hour1, Minute1, Second1} = time(),
    Pid = spawn(Mod, Func, Args),
    spawn(fun() ->
            Ref = monitor(process, Pid),
            receive 
                {'DOWN', Ref, process, Pid, Why} ->
                    {Hour2, Minute2, Second2} = time(),
                    io:format("error:~p, time:~pS~n", [Why, (Hour2-Hour1)*60*60+(Minute2-Minute1)*60+(Second2-Second1)])
            end
    end),
    Pid.
