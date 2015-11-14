% 编写一个 map_search_pred(Map, Pred) 函数，
% 让它返回映射组里第一个符合条件的 {Key, Value} 元素
% （条件是 Pred(Key, Vaule) 为 true）。

-module(mapsearchpred).
-export([map_search_pred/2, pred/2]).

map_search_pred(Map, Pred) ->
    map_search_pred(Map, maps:keys(Map), Pred).

map_search_pred(Map, [Key|T], Pred) ->
    case pred(Key, maps:get(Key, Map)) of
        true -> {Key, maps:get(Key, Map)};
        false -> map_search_pred(Map, T, Pred)
    end;
map_search_pred(Map, [], Pred) ->
    io:format("not found~n").


pred(Key, Value) ->
    case (Key =:= Value) of
        true -> true;
        false -> false
    end.
