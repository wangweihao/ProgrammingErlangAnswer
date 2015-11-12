% 对 hello.erl 做一些小小的改动。
% 在 shell 里编译并运行它们。
% 如果有错，中止 Erlang shell 并重启 shell。

-module(hello).
-export([start/1]).

start(X) -> 
    io:format("~s~n", [X]).

