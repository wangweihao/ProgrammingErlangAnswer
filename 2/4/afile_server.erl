-module(afile_server).
-export([start/1, loop/1]).

% 创建一个 Erlang 进程去执行 start
start(Dir) -> 
    spawn(afile_server, loop, [Dir]).

% 接受请求 1.目录 2.文件
% 回复请求
loop(Dir) ->
    receive
        {Client, list_dir} ->
            Client ! {self(), file:list_dir(Dir)};
        {Client, {get_file, File}} ->
            Full = filename:join(Dir, File),
            Client ! {self(), file:read_file(Full)};
        {Client, {put_file, Content, NewName}} ->
            Content,
            %{Ret, FileFd}  = file:open(NewName, [write, raw]),
            %file:write(FileFd, Content),
            %file:close(FileFd),
            FullTwo = filename:join(Dir, NewName),
            Ret = file:write_file(FullTwo, Content),
            Client ! {self(), {Ret, FullTwo, Content}}
    end,
    loop(Dir).
