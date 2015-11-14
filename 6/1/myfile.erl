% file:read_file(File) 会返回 {ok, Bin} 或者 {error, Why}，
% 其中 File 是文件名， Bin 则包含了文件的内容。请编写一个
% myfile:read(File) 函数，当文件可读取时返回 Bin，否则抛出
% 一个异常。

-module(myfile).
-export([read/1]).


read(File) ->
    try file:read_file(File) of 
        {ok, Content} -> Content;
        {error, Reason} -> Reason
    catch
        throw:X -> io:format("throw Reason is:~p~n", [X]);
        error:X -> io:format("error Reason is:~p~n", [X]);
        exit:X -> io:format("exit Reason is:~p~n", [X])
    end.
