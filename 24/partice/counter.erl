-module(counter).
-export([bump/2, read/1]).

bump(N, {counter, K}) ->
    {counter, N + K}.

read({counter, N}) ->
    N.
