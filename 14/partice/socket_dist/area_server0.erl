-module(area_server0).
-export([loop/0]).

loop() ->
    receive 
        {rectangle, Width, Ht} ->
            io:format("Area of rectangle is ~p~n", [Width * Ht]),
            loop();
        {square, Side} ->
            io:format("Area of square is ~p~n", [Side * Side]),
            loop()
    end.
