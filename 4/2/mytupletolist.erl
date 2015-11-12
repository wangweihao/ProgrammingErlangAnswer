% 内置函数 tuple_to_list(T) 能将元组T里的元素转换成一个列表。
% 请编写一个名为 my_tuple_to_list() 的函数来做同样的事。
% 不要使用内置函数

-module(mytupletolist).
%-export([my_tuple_to_list/1, my_tuple_to_list/4]). 注意不能这么写
-export([my_tuple_to_list/1]).

my_tuple_to_list(T) ->
    my_tuple_to_list(T, tuple_size(T), 0, []).
my_tuple_to_list(T, Index, F, L) when Index > F ->
    my_tuple_to_list(T, Index-1, F, [element(Index, T) | L]);
my_tuple_to_list(T, Index, F, L) when Index =:= F ->
    L.
