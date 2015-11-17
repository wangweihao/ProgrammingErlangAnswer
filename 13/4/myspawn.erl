% 编写一个函数，让它创建一个每隔5秒就打印一次“我还在运行”的注册进程。
% 编写一个函数来监视这个进程，如果进程挂了就重启它。启动公共进程和监视进程。
% 然后摧毁公共进程，检查它是否会被监视进程重启。

-module(myspawn).
-export([start/0, my_spawn/3, func/0]).


start() ->
    my_spawn(myspawn, func, []).

my_spawn(Mod, Func, Args) ->
    Pid = spawn(Mod, Func, Args),
    spawn(fun() -> 
            Ref = monitor(process, Pid),
            receive 
                {'DOWN', Ref, process, Pid, Why} ->
                    io:format("接受到消息:~p，正在重启进程~n", [Why]),
                    spawn(Mod, Func, Args),
                    io:format("重启完毕...~n"),
                    monitor(process, Pid)
            end
          end),
    Pid.

func() ->
    receive
        {ok, Message} ->
              exit(Message)
    after 5000 ->
              io:format("我还在运行~n"),
              func()
    end.

