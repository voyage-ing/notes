# Hadoop

学习参考：https://www.zhihu.com/question/333417513/answer/742465814

简单总结：Hadoop就是存储海量数据和分析海量数据的工具。

Hadoop是由java语言编写的，在分布式服务器集群上存储海量数据并运行分布式分析应用的开源框架，其核心部件是HDFS与MapReduce。

- 存储海量数据->HDFS(Hadoop Distributed File System：分布式文件系统);
- 分布式分析应用->MapReduce是一个计算框架：MapReduce的核心思想是把计算任务分配给集群内的服务器里执行。通过对计算任务的拆分（Map计算/Reduce计算）再根据任务调度器（JobTracker）对任务进行分布式计算。

简而言之：Hadoop的框架最核心的设计就是：HDFS和MapReduce。HDFS为海量的数据提供了存储，则MapReduce为海量的数据提供了计算。

把HDFS理解为一个分布式的，有冗余备份的，可以动态扩展的用来存储大规模数据的大硬盘。

把MapReduce理解成为一个计算引擎，按照MapReduce的规则编写Map计算/Reduce计算的程序，可以完成计算任务。

**yarn**基本思想；一个全局的资源管理器resourcemanager和与每个应用对用的ApplicationMaster，Resourcemanager和NodeManager组成全新的通用系统，以分布式的方式管理应用程序。

HDFS、Hbase、Hive区别与联系：

Hbase是一个可以运行在Hadoop集群上的NoSQL数据库。

HBase作为面向列的数据库（NoSQL）运行在HDFS之上，HDFS缺乏随即读写操作，HBase正是为此而出现。以键值对的形式存储，快速在主机内数十亿行数据中定位所需的数据并访问它。

**Hive**是基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库表，并提供简单的sql查询功能，可以将sql语句转换为MapReduce任务进行运行。而**HBase**是Hadoop的数据库。



Spark，是分布式计算平台，是一个用scala语言编写的计算框架，基于内存的快速、通用、可扩展的大数据分析引擎；

Spark对标的是Hadoop中计算模块的MapReduce。

## CDH

**CDH：全称Cloudera’s Distribution Including Apache Hadoop。**

> hadoop是一个开源项目，所以很多公司在这个基础进行商业化，Cloudera对hadoop做了相应的改变。Cloudera公司的发行版，我们将该版本称为CDH(Cloudera Distribution Hadoop)。

 