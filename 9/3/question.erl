% 为什么在编写模块前需要先思考里面函数的类型？它是否在任何情况下都是一个好注意

% 因为 erlang 是解释型，动态的语言，它不像c/c++这种提前编译好，运行不会出错，
% 动态语言运行时没有类型检查，所以如果参数等错误会导致整个系统错误。
% 类型注解并非在任何情况下都是好注意，个人理解类型注解在运行时会进行检查，
% 这可能会导致性能速度下降。
