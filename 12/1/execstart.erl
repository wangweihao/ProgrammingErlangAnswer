% 编写一个start(AnAtom, Fun)函数来把spawn(Fun)注册为AnAtom。
% 确保当两个并行的进程同时执行start/2时你的程序也能正确工作。
% 在这种情况下，必须保证其中一个进程会成功执行而另一个会失败。


-module(execstart).
-export([create/2]).

start(AnAtom, Fun) ->
    case whereis(AnAtom) of
        undefined -> register(AnAtom, spawn(Fun)),
                     io:format("this is process name:~p~n", [AnAtom]);
        Pid -> io:format("this AnAtom have registered~n")
    end.

create(AnAtom, Fun) ->
    start(AnAtom, Fun),
    start(AnAtom, Fun).
