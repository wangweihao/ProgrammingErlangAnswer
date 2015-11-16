% code:all_loaded() 命令会返回一个由{Mod, File}对构成的列表，
% 内含所有Erlang系统载入的模块。编写一些函数来找出
% 哪个模块导出的函数最多？
% 哪个函数名最常见。
% 不带歧义的函数名（只出现过一次）。

-module(getInfo).
-export([get_info/0, list_size/1, count_function/2, find_max/1, find_one/1, for/4]).


list_size(L) ->
    list_size(L, 0).

list_size([H|T], Size) ->
    list_size(T, Size+1);
list_size([], Size) ->
    Size.

%get_info() ->
%    Info = code:all_loaded(),
%    get_info(Info, -1).
%
% 找出哪个模块导出的函数最多
%get_info([H|T], Max) ->
%    {Name, _} = H,
%    [_, {exports, L}, _, _, _] = Name:module_info(),
%    case (list_size(L) >= Max) of
%        true -> get_info(T, list_size(L));
%        false -> get_info(T, Max)
%    end;
%get_info([], Max) ->
%    Max.

% 哪个函数名最常见
get_info() ->
    Info = code:all_loaded(),
    get_info(Info, #{}).

get_info([H|T], X) ->
    {Name, _} = H,
    [_, {exports, L}, _, _, _] = Name:module_info(),
    get_info(T, count_function(L, X));
get_info([], X) ->
    %X.
    %问题2,找出出现次数最多的
    %find_max(X).
    %问题3,找出出现一次的
    %find_one(X).

count_function([H|T], X) ->
    {FuncName, _} = H,
    case maps:is_key(FuncName, X) of
        false -> count_function(T, X#{FuncName => 1});
        true  -> #{FuncName := Count} = X,
                count_function(T, X#{FuncName := Count+1})
    end;
count_function([], X) ->
    X.

find_max(X) ->
    L = maps:keys(X),
    for(L, X, "", -1).


% 问题3 找出只在模块中出现过一次的函数。
find_one(X) ->
    L = maps:keys(X),
    lists:filter(fun(E) -> {ok, Value} = maps:find(E, X),
                           Value == 1 end, L).

for([H|T], X, MaxKey, MaxValue) ->
    {ok, Value} = maps:find(H, X),
    case (Value > MaxValue) of
        true  -> for(T, X, H, Value);
        false -> for(T, X, MaxKey, MaxValue)
    end;
for([], X, MaxKey, MaxValue) ->
    {MaxKey, MaxValue}.







