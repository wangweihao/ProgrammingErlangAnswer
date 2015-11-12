% 向 math_functions.erl 添加一个名为 filter(F, L) 的高阶函数，
% 它返回 L 里所有符合条件的元素 X (条件是F(X)为true)

-module(mathfunctions).
-export([filter/2]).

filter(F, L) ->
    [X || X <- L, F(X) =:= true].
