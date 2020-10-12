# Go routine & Channel

1. 天然并发
2. 从语言层面支持并发，非常简单
3.  goroute，轻量级线程，创建成千上万个goroute成为可能
4. 基于CSP（Communicating Sequential Process）模型实现

goroutine 执行一个任务，他的结果怎么返回给调用方：

Goroute + channel 就构成CSP模型；

## Channel

3.  channel

管道，类似unix/linux中的pipe	

b. 多个goroute之间通过channel进行通信

c. 支持任何类型



pipe ：= Make(chan int,3) 放3个int之后，会被阻塞；

pipe <- 1  把1扔到管道里

pipe <- 2 把2扔到管道里

Aaa = <- pipe    管道往外取数据







## 思考：make(chan int)和make(chan int, 1)的区别

Learning from：

- 作者：lesliefang
- 链接：https://www.jianshu.com/p/f12e1766c19f

```go
package main

import "fmt"

func main() {
    var c = make(chan int)
  
    var a string
    go func() {
        a = "hello world"
        <-c
    }()
  
    c <- 0
    fmt.Println(a)
} // learning from ：https://www.jianshu.com/p/f12e1766c19f
```

这个例子会正常打印出 "hello world";

如果把`var c = make(chan int)` 替换为`var c = make(chan int, 1)`，那么最后输出的a可能是"hello world"，也可能为空；

先看：`var c = make(chan int)`

`var c = make(chan int)`这个是unbuffered channel，send之后send语句会阻塞执行，直到有人 receive 之后 send 解除阻塞，后面的语句接着执行；所以执行 c <- 0 时会阻塞，直到 <-c, 这时 a 已赋值。

再看：`var c = make(chan int, 1)`

`var c = make(chan int, 1)`是 buffered channel, 容量为 1。在 buffer 未满时往里面 send 值并不会阻塞， 只有 buffer 满时再 send 才会阻塞，所以执行到  c <- 0 时并不会阻塞 fmt.Println(a) 的执行，这时 a 可能是 "hello world" 也可能是空， 主要就是看两个 goroutine 谁执行的更快。

