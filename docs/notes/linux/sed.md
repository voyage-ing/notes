

Sed 一些高级用法。https://www.cnblogs.com/xia-dong/p/11988770.html

```
sed s/MEM_MB/MEM/g oldvms.yaml > newvms.yaml
```

- s：替换，可使用正则表达式
- [s// 和 s//g 的区别](https://blog.csdn.net/m0_37664906/article/details/78082209)
- 没加g说明在这一行只替换第一个匹配到的字符串，有g表示这一行所有匹配到的字符串都替换



```
sed -i s/VLANS/NICS/g newvms.yaml
```

- sed -i：直接对文本进行操作



```
sed -i '/creationTimestamp/d' newvms.yaml
```

- 在每一行匹配`creationTimestamp`，匹配成功后删除整行
- d：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
- 其他删除技巧：https://www.quwenqing.com/read-167.html

