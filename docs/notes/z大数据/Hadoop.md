# Hadoop生态

学习参考：https://www.zhihu.com/question/333417513/answer/742465814

简单总结：Hadoop就是存储海量数据和分析海量数据的工具。

Hadoop是由java语言编写的，在分布式服务器集群上存储海量数据并运行分布式分析应用的开源框架，其核心部件是HDFS与MapReduce。

- 存储海量数据->HDFS(Hadoop Distributed File System：分布式文件系统);
- 分布式分析应用->MapReduce是一个计算框架：MapReduce的核心思想是把计算任务分配给集群内的服务器里执行。通过对计算任务的拆分（Map计算/Reduce计算）再根据任务调度器（JobTracker）对任务进行分布式计算。

简而言之：Hadoop的框架最核心的设计就是：HDFS和MapReduce。HDFS为海量的数据提供了存储，则MapReduce为海量的数据提供了计算。

## Hadoop生态中常见组件及作用

### HDFS

把HDFS理解为一个分布式的，有冗余备份的，可以动态扩展的用来存储大规模数据的大硬盘。

### MapReduce

把MapReduce理解成为一个计算引擎，按照MapReduce的规则编写Map计算/Reduce计算的程序，可以完成计算任务。

### Hbase

Hbase是一个可以运行在Hadoop集群上的NoSQL数据库。

HBase作为面向列的数据库（NoSQL）运行在HDFS之上，HDFS缺乏随即读写操作，HBase正是为此而出现。以键值对的形式存储，快速在主机内数十亿行数据中定位所需的数据并访问它。

### Hive

基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库表，并提供简单的sql查询功能，可以将sql语句转换为MapReduce任务进行运行。而**HBase**是Hadoop的数据库。

### yarn

一个全局的资源管理器resourcemanager和与每个应用对用的ApplicationMaster，Resourcemanager和NodeManager组成全新的通用系统，以分布式的方式管理应用程序。

### Spark

是分布式计算平台，是一个用scala语言编写的计算框架，基于内存的快速、通用、可扩展的大数据分析引擎；

Spark对标的是Hadoop中计算模块的MapReduce。

### Zookeeper

https://zhuanlan.zhihu.com/p/69114539

分布式协调系统。谁能把这个数据同步的时间压缩的更短，谁的请求响应就更快，谁就更出色，Zookeeper就是其中的佼佼者。

它用起来像单机一样，能够提供数据强一致性，但是其实背后是多台机器构成的集群，不会有SPOF。