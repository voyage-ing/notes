此yaml文件只创建一个Pod，用来测试`kubectl expose`命令。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd-manual
spec:
  containers:
  - image: docker.mirrors.ustc.edu.cn/library/httpd:2
    name: httpd
    ports:
    - containerPort: 80
      protocol: TCP
```

