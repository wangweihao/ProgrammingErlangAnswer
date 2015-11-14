-module(parseFile).
-export([parse_file/1]).
-import(rfc4627, [decode/1, encode/1]).

parse_file(File) ->
    case file:open(File, read) of
        {ok, FileFd} -> parse_file(FileFd, io:get_line(FileFd, "Read a line"), #{});
        {error, Reason} -> io:format("parse_file/1 error:~p~n", [Reason])
    end.

parse_file(FileFd, Line, X) when Line =/= eof ->
    case rfc4627:decode(Line) of
        {ok, {obj, [{Key, Value}]}, []} -> parse_file(FileFd, io:get_line(FileFd, "Read a line"), X#{Key => Value});
        {error, Reason} -> io:format("parse_file/3 error:~p~n", [Reason])
    end;
parse_file(FileFd, Line, X) when Line =:= eof ->
    file:close(FileFd),
    X.
