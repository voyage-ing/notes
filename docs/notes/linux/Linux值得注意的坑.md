# Linux必须注意的坑

## tar

可以这样理解tar的解压缩过程，将压缩包打开把里面的所有内容**强制复制**到对应文件夹下，文件夹不受影响。如下：

初始化，所有的file目前都是空的：

![image-20200812093825421](https://tva1.sinaimg.cn/large/007S8ZIlly1ghns3kczw4j30cw06et8p.jpg)

现在压缩aaa：`tar zcvf aaa.tar aaa`，结果aaa和aaa.tar目前在同一级目录下

在aaa中修改：

1. vi 111：随便加点什么
2. add aaa/456，也可以顺便添加点什么
3. vi aaa/bbb/a1：随便加点什么
4. add aaa/bbb/a3

解压aaa.tar：`tar zxvf aaa.tar`，因为aaa.tar压缩的是修改aaa之前的，但他们两个统一路径解压名字相同，就会出现问题。

再次查看aaa中，修改文件情况，便能恍然大悟。

结论：

1. 压缩后修改文件夹的文件，解压后修改会被覆盖，也就是恢复到解压时候的状态，文件夹不受影响。
2. 压缩后新增加的文件或文件夹，解压后不受影响。