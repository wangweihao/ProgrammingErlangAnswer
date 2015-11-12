% 向 math_functions.erl 添加一个返回{Even，Odd}的split(L)函数，
% 其中 Even 是一个包含 L 里所有偶数的列表，Odd是一个包含L里所有技术的列表。
% 请用两种不同的方式编写这个函数，一种使用归集器，另一种使用在联系6中编写的filter函数。

-module(mathfunctions).
-export([split/1]).

%split(L) ->
%    split(L, [], []).
%split([H|L], Odd, Even) ->
%    case (H rem 2 =:= 0) of
%        true -> split(L, Odd, [H|Even]);
%        false -> split(L, [H|Odd], Even)
%    end;
%split([], Odd, Even) ->
%    {Even, Odd}.

split(L) ->
    Odd = [X || X <- L, (X rem 2) =/= 0],
    Even = [X || X <- L, (X rem 2) =:= 0],
    {Even, Odd}.
