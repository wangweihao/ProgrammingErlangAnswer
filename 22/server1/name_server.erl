-module(name_server).
-export([init/0, add/2, find/1, handle/2]).
-import(server1, [rpc/2]).

%% 客户端方法
add(Name, Place) ->
    rpc(name_server, {add, Name, Place}).

find(Name) ->
    rpc(name_server, {find, Name}).


%% 回调方法
init() ->
    dict:new().

handle({add, Name, Place}, Dict) ->
    {ok, dict:store(Name, Place, Dict)};
handle({find, Name}, Dict) ->
    {dict:find(Name, Dict), Dict}.
