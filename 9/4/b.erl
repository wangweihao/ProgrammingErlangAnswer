-module(b).
-export([func/1]).

-spec func(tuple()) -> a:mylist().

func(Tuple) ->
    L = tuple_to_list(Tuple),
    [X*2 || X <- L].

