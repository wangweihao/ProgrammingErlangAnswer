% 对不同名类型做些试验。创建两个模块，第一个模块导出一个不同名类型，
% 第二个模块以能导致抽象违规的方式使用该不透明类型的内部数据结构。
% 在这两个模块上运行 dialyzer 并确保理解了错误消息。


-module(a).
-export_type([mylist/0]).

-type mylist()::list().
%-opaque mylist() :: list().

