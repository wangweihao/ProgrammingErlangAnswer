% 编写一个名为 math_functions.erl 的模块，并导出函数 even/1 和 odd/1。
% even(X) 函数应当是偶整数时返回 true，否则返回false。odd(X)应当在 X 是奇整数时返回 flase

-module(mathfunctions).
-export([even/1, odd/1]).

even(X) when is_integer(X) ->
    case (X rem 2 =:= 0) of
        true -> true;
        false -> false
    end.

odd(X) when is_integer(X) ->
    case (X rem 2 =/= 0) of
        true -> true;
        false ->false
    end.
