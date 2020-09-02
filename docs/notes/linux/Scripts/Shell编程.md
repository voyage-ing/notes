## shell编程

[TOC]



BASH_SOURCE[0] BASH_SOURCE[0] 等价于 BASH_SOURCE， 取得当前执行的shell文件所在的路径及文件名。

BASH_SOURCE[0]  似乎是第一个脚本的路径，如果脚本中调用脚本的话

### 脚本接收参数：

#### 1：参数传给制定变量，eg：

run：`XXX="default" CN=".cn" MAC=y ./test.sh`

script：

```shell
: ${XXX:="默认值，也可以不写"}
: ${CN:=""}
: ${MAC:=""}
# 之后使用变量对应的值，如下
$XXX,$CN,$MAC
```

#### 2：末尾获取变量，eg：

run：`./test.sh arg1 arg2`

script中与其对应的$1<-arg1, $2<-arg2

### 判断：

#### if-else格式

```shell
if [ command ];then
     符合该条件执行的语句
     可以有多条
elif [ command ];then
     符合该条件执行的语句
else
     符合该条件执行的语句
fi
```

#### 常用判断条件

pass





