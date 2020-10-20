# CDH

**CDH：全称Cloudera’s Distribution Including Apache Hadoop。**

> hadoop是一个开源项目，所以很多公司在这个基础进行商业化，Cloudera对hadoop做了相应的改变。Cloudera公司的发行版，我们将该版本称为CDH(Cloudera Distribution Hadoop)。

 

## CDH集群布局

感谢：https://blog.csdn.net/selectgoodboy/article/details/86747525?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~all~sobaiduend~default-1-86747525.nonecase&utm_term=cdh%E9%9B%86%E7%BE%A4%E5%A4%9A%E5%B0%91%E4%B8%AA%E8%8A%82%E7%82%B9&spm=1000.2123.3001.4430

## CDH部署

https://blog.csdn.net/swj9099/article/details/102836161

- cdh0: 172.24.1.165
- cdh1: 172.24.1.135
- Cdh2: 172.24.1.106

```yaml
172.24.1.165 cdh0
172.24.1.135 cdh1
172.24.1.106 cdh2
```

CDH离线安装包：https://archive.cloudera.com/cm6/6.3.0/redhat7/yum/RPMS/x86_64

CDH6.3.0相关包：

cloudera-manager-daemons-6.3.0-2117683.el7.x86_64.rpm

parcels对应版本：6.3.2-1.cdh6.3.2.p0.1605554 https://archive.cloudera.com/cdh6/6.3.2/parcels/



![image-20201014093633570](https://tva1.sinaimg.cn/large/007S8ZIlly1gjom3bu1hcj31ih0u07an.jpg)

收费规则详情：https://xiyoulaoyuanjia.cn/?p=135

![image-20201015092126288](https://tva1.sinaimg.cn/large/007S8ZIlly1gjpr9kjpeej31d70u0n3n.jpg)

![image-20201015092204422](https://tva1.sinaimg.cn/large/007S8ZIlly1gjpra9i0ywj31590u04a5.jpg)

