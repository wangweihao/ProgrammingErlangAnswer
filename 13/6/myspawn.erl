% 编写一个函数来启动和监视多个工作进程，如果任何一个进程非正常终止，
% 就摧毁所有进程，然后重启它们。

-module(myspawn).
-export([my_spawn/4, start/1, spawn_func/0, list_func/3]).


start(N) ->
    my_spawn(myspawn, spawn_func, [], N).

my_spawn(_, _, _, N) ->
    Monitor = spawn(fun() ->
                        % 创建 N 个进程
                        Fs = list_func(N, [], spawn_func),
                        Id = [spawn_link(myspawn, F, []) || F <- Fs],
                        io:format("Id:~p~n", [Id]),
                        receive
                            {'DOWN', _, process, Pid, normal} ->
                                Pid;
                            {'DOWN', _, process, Pid, Why} ->
                                io:format("Pid:~p quit, Reason:~p~n", [Pid, Why]),
                                % 杀死所有进程。
                                [exit(Cpid, normal) || Cpid <- Id],
                                io:format("正在重启所有进程~n"),
                                [spawn_link(myspawn, F, []) || F <- Fs],
                                io:format("重启完毕~n")
                        end
                    end),
    io:format("Monitor:~p~n", [Monitor]).

spawn_func() ->
    io:format("hello world:~p~n", [self()]),
    receive 
        {ok, Message} -> 
            exit(Message);
        other ->
            spawn_func()
    end.

list_func(N, H, F) when N =/= 1 ->
    list_func(N-1, [F|H], F);
list_func(N, H, _) when N =:= 1 ->
    H.
