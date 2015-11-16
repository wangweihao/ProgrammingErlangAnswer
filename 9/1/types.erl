-module(types).
-export([bug1/2]).

myand1(true, true) -> true;
myand1(false, _) -> false;
myand1(_, false) -> false.

bug1(X, Y) ->
    case myand1(X, Y) of 
        true -> 
            X + Y
    end.
