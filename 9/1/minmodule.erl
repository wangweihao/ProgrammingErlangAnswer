% (1).编写一些导出单个函数的小模块，以及被导出函数的类型规范。
% 在函数里制造一些类型错误，然后对这些程序运行 dialyzer 并试着理解错误消息。
% 有时候你制造的错误无法被 dialyzer 发现，请仔细观察程序，找出没有得到预期错误的原因。

-module(minmodule).
-export([func1/3]).

%-spec func1(number(), number(), number()) -> number().

func1(X, Y, Z) when is_list(X) ->
    X+Y+Z.
