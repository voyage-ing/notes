# Dockerfile

最好的参考文档：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

![image-20201009174617636](https://tva1.sinaimg.cn/large/007S8ZIlly1gjj852c79jj30iq0f3n3t.jpg)



## Dockerfile语法结构

### FROM

```dockerfile
FROM centos
```

- FROM：定制的镜像是基于FROM指定的镜像，这里的nginx就是定制需要的基础镜像，后续的操作都是基于 nginx。

### ENV

设置容器的环境变量；

```dockerfile
# 设置实例
ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8
ENV TERM xterm
ENV PYTHON_VERSION 3.5.3
ENV name1=ping name2=on_ip
CMD $name1 $name2
```

类UNIX中，系统自带的常用的环境变量：

- HOME：当前用户的主目录；

- PATH： Shell查找命令的目录列表，由冒号分隔；

  `ENV PATH /usr/local/bin:$PATH`：在默认的PATH中把/usr/local/bin也加入查找目录；

- HOSTNAME：主机名；

### RUN & CMD & ENTRYPOINT

**RUN**：执行后面跟着的命令并创建新的镜像层，通常用于安装软件包；RUN命令支持[Shell和Exec两种格式](#shellexec);

RUN命令是在制作镜像时运行的；

```dockerfile
FROM centos
RUN yum install wget
RUN wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz"
RUN tar -xvf redis.tar.gz
# 以上执行会创建3层（layer）镜像。可简化为以下格式：
FROM centos
RUN yum install wget \
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" \
    && tar -xvf redis.tar.gz
```

> **注意**：Dockerfile 的指令每执行一次都会在 docker 上新建一层。所以过多无意义的层，会造成镜像膨胀过大。例如上面这种情况；

**CMD**：命令设置容器启动后默认执行的命令及其参数，

> CMD设置的命令能够被`docker run`命令后面的命令行参数替换；

CMD有三种用法

1. 为ENTRYPOINT提供默认参数：`CMD ["param1","param2"]`，在下面ENTRYPOINT中解释；
2. shell格式：`CMD command param1 param2`；[Shell和Exec两种格式](#shellexec);
3. exec格式（推荐）：`CMD ["executable","param1","param2"]`；[Shell和Exec两种格式](#shellexec);

**ENTRYPOINT**：指令的目的也是为容器指定默认执行的任务；

当指定了 ENTRYPOINT （exec格式）后，CMD 的含义就发生了改变，不再是直接运行的命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为：<ENTRYPOINT> "<CMD>"

```dockerfile
# ENTRYPOINT中的内容一般情况下并不能被docker run 指定的参数所替换
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
```

```dockerfile
docker run xxx
# 实际执行为 top -b -c

docker run xx -a
# 实际执行为 top -b -a
```

> 想要覆盖或者更改ENTRYPOINT的命令可以使用 --entrypoint 
>
> ```bash
> $ docker run --rm --entrypoint ps -aux
> ```

我们大概可以总结出下面几条规律，参考：https://www.jb51.net/article/136264.htm

- 如果 ENTRYPOINT 使用了 shell 模式，CMD 指令会被忽略。
-  如果 ENTRYPOINT 使用了 exec 模式，CMD 指定的内容被追加为 ENTRYPOINT 指定命令的参数。
-  如果 ENTRYPOINT 使用了 exec 模式，CMD 也应该使用 exec 模式。

![image-20201010104050208](https://tva1.sinaimg.cn/large/007S8ZIlly1gjk1gn7kowj314o0h00w3.jpg)

### COPY & ADD

COPY：复制指令，从上下文目录中复制文件或者目录到容器里指定路径。

```dockerfile
COPY [--chown=<user>:<group>] <源路径1>...  <目标路径>
COPY [--chown=<user>:<group>] ["<源路径1>",...  "<目标路径>"]
COPY hom* /mydir/
COPY hom?.txt /mydir/
```

- **[--chown=<user>:<group>]**：可选参数，用户改变复制到容器内文件的拥有者和属组。
- 源文件或者源目录，这里可以是通配符表达式，其通配符规则要满足 Go 的 filepath.Match 规则。
- **<目标路径>**：容器内的指定路径，该路径不用事先建好，路径不存在的话，会自动创建。
- 关于源路径，目标路径的是文件还是目录的区别：https://www.cnblogs.com/yaohuimo/p/13154488.html

ADD：ADD 指令和 COPY 的使用格式一致（同样需求下，官方推荐使用 COPY）。功能也类似，不同之处如下：

```dockerfile
ADD test1.txt test1.txt
```

- ADD 的优点：在执行 <源文件> 为 tar 压缩文件的话，压缩格式为 gzip, bzip2 以及 xz 的情况下，会自动复制并解压到 <目标路径>。
- ADD 的缺点：在不解压的前提下，无法复制 tar 压缩文件。会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。具体是否使用，可以根据是否需要自动解压来决定。

### <span id="shellexec">Shell和Exec格式的区别</span>

Dockerfile中支持Shell和Exec两种格式的命令：RUN、CMD、ENTRYPOINT；

```dockerfile
# shell格式
RUN apt-get install -y vim
CMD echo "docker so easy"
ENTRYPOINT echo "docker so easy"

# Exec格式
RUN ["apt-get","install","-y","vim"]
CMD ["echo","docker so easy"]
ENTRYPOINT ["echo","docker so easy"]
```

两者的区别在于制定的命令是否在shell中被调用；

使用exec方式，会用command进程替换当前shell进程，并且保持PID不变。执行完毕，直接退出，不回到之前的shell环境。

