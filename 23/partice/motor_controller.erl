-module(motor_controller).
-export([add_event_handler/0]).

add_event_handler() ->
    event_handler:add_handler(error, fun controller/1).
controller(too_hot) ->
    io:format("Trun off the motor~n");
controller(X) ->
    io:format("~w ignored event: ~p~n", [?MODULE, X]).
