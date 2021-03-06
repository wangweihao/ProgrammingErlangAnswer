% 编写一个 term_to_packet(Term) -> Packet 的函数，
% 通过调用 term_to_binary(Term) 来生成并返回一个二进制型，
% 它内含长度为 4 个字节的包头 N，后跟 N 个字节的数据

-module(termtopacket).
-export([term_to_packet/1]).

term_to_packet(Term) ->
    Bin = term_to_binary(Term),
    Length = bit_size(Bin),
    Size = <<Length:1/unit:32>>,
    <<Size/binary, Bin/binary>>.
