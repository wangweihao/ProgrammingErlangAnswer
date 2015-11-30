-module(event_handler).
-export([make/1, add_handler/2, event/2]).

make(Name) ->
    register(Name, spawn(fun() -> my_handler(fun no_op/1) end)).

add_handler(Name, Fun) ->
    Name ! {add, Fun}.

event(Name, X) ->
    Name ! {event, X}.

my_handler(Fun) ->
    receive
        {add, Fun1}  ->
            my_handler(Fun1);
        {event, Any} ->
            (catch Fun(Any)),
            my_handler(Fun)
    end.

no_op(_) -> void.
