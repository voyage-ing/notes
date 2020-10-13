# Secret

Secret和configmap类似，可以理解为Configmap中一些条目如果是敏感数据，那么就可以使用Secret；

Secret与Configmap结构类似，都是key/value映射，所以用法相同：

- 传递Secret条目到env；
- 将Secret条目暴露为volume中的文件；

