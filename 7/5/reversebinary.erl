% 编写一个函数来反转某个二进制型所包含的位。

-module(reversebinary).
-export([reverse_binary/1]).

reverse_binary(B) ->
    lists:reverse([X || <<X:1>> <= B]).

