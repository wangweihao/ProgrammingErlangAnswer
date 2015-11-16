% 编写一个函数来反转某个二进制型里的字节顺序

-module(reverse_byte).
-export([reverse_byte/1]).

%reverse_byte(Obj) ->
%    reverse_byte(term_to_binary(Obj), <<>>,1).

reverse_byte(Bin) ->
    reverse_byte(Bin, <<>>, 1).

reverse_byte(Bin, RetBin, Pos) when Pos =< byte_size(Bin) ->
    {Bin1, Bin2} = split_binary(Bin, Pos),
    reverse_byte(Bin2, list_to_binary([Bin1, RetBin]),Pos);
reverse_byte(Bin, RetBin, Pos) when Pos > byte_size(Bin) ->
    RetBin.
