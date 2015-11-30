-module(client).

-import(gen_server, [call/2]).
-export([new_account/1, deposit/2, withdarw/2]).


new_account(Who) ->
    gen_server:call(my_bank, {new, Who}).
deposit(Who, Amount) ->
    gen_server:call(my_bank, {add, Who, Amount}).
withdarw(Who, Amount) ->
    gen_server:call(my_bank, {remove, Who, Amount}).
