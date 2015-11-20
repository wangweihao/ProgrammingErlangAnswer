-module(fileServer).
-export([run/3]).

run(MM, ArgC, ArgS) ->
    io:format("Ready go!~n" 
              "ArgC = ~p ArgS = ~p~n", [ArgC, ArgS]),
    loop(MM).

loop(MM) ->
    receive
        {chan, MM, {putfile, Bin, Newname}} ->
            Ret = file:write_file(Newname, Bin),
            MM ! {send, Newname},
            loop(MM);
        {chan, MM, {getfile, Name}} ->
            io:format("hahahaha"),
            MM ! {send, "hahahahaha"},
            loop(MM);
        {chan_close, MM} ->
            io:format("file stopping!n"),
            exit(normal)
    end.
            
