% 编写一个 my_spawn(Mod, Func, Args, Time) 函数。它的行为类似spawn(Mod, Func, Args)，
% 但有一点区别。如果分裂出的进程存货超过了Time秒，就应当被摧毁。

-module(myspawn).
-export([my_spawn/4, start/0, func/1]).


-spec my_spawn(Mod, Func, Args, Time) -> pid() when
      Mod   :: atom(),
      Func  :: atom(),
      Args  :: [T],
      T     :: term(),
      Time  :: term().


start() ->
    my_spawn(myspawn, func, [], 5000).

my_spawn(Mod, Fun, Args, Time) ->
    Pid = spawn(Mod, Fun, [Time]),
    io:format("Pid:~p~n", [Pid]),
    spawn(fun() -> 
            Ref = monitor(process, Pid),
            receive 
                {'DOWN', Ref, process, Pid, Why} ->
                    io:format("Pid:~p process quit~n", Pid),
                    io:format("Why Quit:~p~n", [Why])
            end  
        end),
    Pid.

func(Time) ->
    io:format("Time:~p~n", [Time]),
    receive 
        {ok, Message} ->
            io:format("Message:~p~n", Message)
    after Time ->
            exit("timeout")
    end.

