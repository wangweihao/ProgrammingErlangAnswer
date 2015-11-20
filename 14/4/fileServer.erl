-module(fileServer).
-export([start/0]).


start() ->
    io:format("file server start~n"),
    loop().

loop() ->
    receive
        {chan, MM, {putfile, Bin, Newname}} ->
            Ret = file:write_file(Newname, Bin),
            MM ! {ok, Newname};
        {chan, MM, {getfile, Bin, Name}} ->
            MM ! {self(), file:read_file(Name)};
        {chan, MM, _} ->
            MM ! {error, "try again"};
        _ ->
            io:format("recv error~n")
    end,
    loop().
            
