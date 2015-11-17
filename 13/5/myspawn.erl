% 编写一个函数来启动和监视多个进程。
% 如果任何一个工作进程非正常中止，就重启它

-module(myspawn).
-export([my_spawn/4, start/1, for/3, spawn_func/0, func/0, list_func/3]).


start(N) ->
    my_spawn(myspawn, spawn_func, [], N).

my_spawn(Mod, Func, Args, N) ->
    % 创建 N 个进程。 
    % 创建监视进程
    Monitor = spawn(fun() ->
                        io:format("-------------1~n"),
                        for(1, N, spawn_link),
                        %Fs = list_func(N, [], spawn_func),
                        %io:format("Fs:~p~n", [Fs]),
                        %[spawn_link(myspawn, F, []) || F <- Fs],
                        %Id = spawn_link(myspawn, spawn_func, []),
                        io:format("-------------2~n"),
                        receive
                            {'DOWN', _, process, Pid, Why} ->
                                io:format("Pid:~p quit, Reason:~p~n", [Pid, Why]),
                                io:format("正在重启进程~n"),
                                spawn_link(Func),
                                io:format("重启完毕~n")
                        end
                    end),
    io:format("Monitor:~p~n", [Monitor]).

func() ->
    spawn_link(myspawn, spawn_func, []).

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
list_func(N, H, F) when N =:= 1 ->
    H.


for(Max, Max, Func) -> [Func(myspawn, spawn_func, [])];
for(I, Max, Func)   -> [Func(myspawn, spawn_func, []) | for(I+1, Max, Func)].
