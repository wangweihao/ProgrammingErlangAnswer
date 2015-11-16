% 编写一个反转函数 packet_to_term(Packet) -> Term，
% 使它成为前一个函数的逆向函数

-module(packettoterm).
-export([packet_to_term/1]).

packet_to_term(<<Head:4, Info:>>) ->
    <<Head:4/bits, _/bits>> = Packet,
    <<Size:4>> = Head,
    <<Head:4/bits, Info:Size/bits>> = Packet,
    binary_to_term(Info).
