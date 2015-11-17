% 编写一个环形计时测试。创建一个由N个进程组成的环。
% 把一个消息沿着环发送M次，这样总共发送的消息是M*N。
% 记录不同的N和M值所花费的时间
% 用你熟悉的其他编程语言编写一个类似的程序，然后比较一下结果。
% 写一篇博客，把结果在网上发表出来。

-module(sendMessage).
-export([start/2]).


% N 个进程， M 次
start(N, M) ->
    sendstart(M, createProcess(N)).

createProcess(N) ->
    % 创建 N 个进程
    L = for(1, N, fun() -> spawn(fun() -> loop() end) end),
    L.

sendstart(M, L) ->
    % 给第一个进程发送请求，开始绕环发送消息
    Pid = getPid(1, L, M),
    Pid ! {1, L, M, "hello world"}.

loop() ->
    receive 
        % {1, [1,2,3,4,5], "hello world"}
        {I, L, M, Message} -> 
            io:format("Pid:~p Recv Message:~p~n", [(I rem lists_size(L))+1,Message]),
            % 发送给下一个进程
            case getPid(I+1, L, M) of
                none -> io:format("have send...~n");
                Pid  -> Pid ! {I+1, L, M, Message},
                        loop()   
            end
    end.

getPid(I, L, M) ->
    io:format("...........I:~p~n", [I]),
    case lists_size(L) of
        Size when I =< Size ->
            lists:nth(I, L);
        Size when I > Size, I rem Size =:= 0 ->
            lists:nth(Size, L);
        Size when I > Size, I =< M ->
            lists:nth((I rem Size), L);
        Size when I > M ->
            none
    end.

for(Max, Max, F) -> [F()];
for(I, Max, F)   -> [F() | for(I+1, Max, F)].


% 计算lists大小函数
lists_size(L) ->
   lists_size(L, 0).
lists_size([_|T], Size) ->
    lists_size(T, Size+1);
lists_size([], Size) ->
    Size.
