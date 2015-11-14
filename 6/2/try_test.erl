% 重写 try_test.erl 里的代码，让它生成两条错误消息;
% 一条明文消息给用户，另一条详细的消息给开发者。

-module(try_test).
-export([generate_exception/1, demo1/0, catcher/1]).

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> error(a).

demo1() ->
    [catcher(I) || I <- [1,2,3,4,5]].

catcher(N) ->
    try generate_exception(N) of
        Val -> {N, normal, Val}
    catch
        throw:X -> {user, N, caught, thrown, X},
                   {developer, X, erlang:get_stacktrace()};
        exit:X  -> {user, N, caught, exited, X},
                   {developer, X, erlang:get_stacktrace()};
        error:X -> {user, N, caught, error, X},
                   {developer, X, erlang:get_stacktrace()}
    end.
