% 观察标准库代码里的类型注解。找到lists.erl模块的源代码，
% 阅读里面所有的类型注解
% 随便粘几个注解

-spec keyfind(Key, N, TupleList) -> Tuple | false when
      Key :: term(),
      N :: pos_integer(),
      TupleList :: [Tuple],
      Tuple :: tuple().


-spec reverse(List1, Tail) -> List2 when
      List1 :: [T],
      Tail :: term(),
      List2 :: [T],
      T :: term().

-spec append(List1, List2) -> List3 when
      List1 :: [T],
      List2 :: [T],
      List3 :: [T],
      T :: term().
