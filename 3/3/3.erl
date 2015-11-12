% 试着用一个元祖来表示一座房子，
% 再用一个贩子列表来表示一条街道。
% 请确保你能向这些结构中加入数据结构或从中取出数据。

1> BigHouse = {bigHouse, piano, cat, dog}.
{bigHouse,piano,cat,dog}
2> SmallHouse = {smallHouse, tortoise}.
{smallHouse,tortoise}
3> Street = {street, BigHouse, SmallHouse}.
{street,{bigHouse,piano,cat,dog},{smallHouse,tortoise}}
4> {street, B, S} = Street. 
{street,{bigHouse,piano,cat,dog},{smallHouse,tortoise}}
5> B.
{bigHouse,piano,cat,dog}
6> S.
{smallHouse,tortoise}
7> 

