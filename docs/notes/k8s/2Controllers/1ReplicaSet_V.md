# ReplicaSet：副本控制器

## 用ReplicaSet代替ReplicationController

ReplicaSet 是比 ReplicationController 更有用的控制器，他们工作和原理几乎一样，只有一点不同的是ReplicaSet有功能更强大的标签选择器。

所以依旧从RC开始学习。

## ReplicationController原理

通过label selector匹配到pods，比较数量和副本数（replica）是否一直，少了就根据template来新建一个，多了就删掉一个。

![image-20200804171843339](https://tva1.sinaimg.cn/large/007S8ZIlly1ghewg14o0aj30fk0aut9g.jpg)

> 需要注意的是通过controller创建的pod删掉pod后，会自动创建一个新的，如果像删掉这个pod，需要删除对应的控制器。



## ReplicationController结构

一个RC有三个主要部分：

- selector：label selector，用于确定RC的作用域中有哪些Pod
- replicas：副本个数
- template：用于创建Pod的模版

具体一个学习案例：

> `kubectl explain rc.spec`：学习命令

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: kubia
  namespace: controller-test
spec:
  replicas: 3                     # 备份数
  selector:                       # 决定RC的操作对象
    app: kubia
  template:                       # 创建pod所用的模版
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
        ports:
        - containerPort: 8080
```

## 删除一个ReplicationController

删除一个RC，那么对应的Pod也会被删除，如果想要删除RC保留Pod，可以：

```bash
kubectl delete rc -n controller-test kubia --cascade=false
```

也可以重新管控这些Pod，只需要创建RC用label selector选择他们。

## ReplicaSet标签选择器

和Deployment，DaemonSet等一样，仅支持下面两种来接收label，无法使用这种：

```yaml
spec:                              # 无法使用这种方式
  selector:		
    label1: xxx1
  template:
    metadata:
      labels:
        label1: xxx1
```



```bash
kubectl explain rs.spec.selector.matchLabels
kubectl explain rs.spec.selector.matchExpressions
```

1. matchLabes：

```yaml
spec:
  selector:
    matchLabels:				# 匹配多标签
      label1: xxx1
      label2: xxx2
      label3: xxx3
  template:
    metadata:
      labels:
        label1: xxx1
        label2: xxx2
        label3: xxx3
```

2. matchExpressions：

```yaml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 2
  selector:
    matchExpressions:
      - key: app
        operator: In	# In NotIn  Exists DoesNotExist
        values:
         - kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
```

> Operator 是 In or NotIn values要有值，来判断是不是要选择的
>
> Operator 是 Exists or DoesNotExist values一定要为空，判断label存不存在

​	