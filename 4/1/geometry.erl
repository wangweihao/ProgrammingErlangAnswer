% 扩展 geometry.erl 添加一些子句来计算圆和直角三角形的面积。
% 添加一些子句来计算各种几何图形的周长

-module(geometry).
-export([area/1]).

area({rectangle, Width, Height}) ->
    Width * Height;
area({square, Side}) ->
    Side * Side;
area({round, Radius}) ->
    3.1415 * Radius * Radius.
