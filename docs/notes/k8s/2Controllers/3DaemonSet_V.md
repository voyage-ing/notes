# DaemonSet：每个节点都运行一个Pod

依旧从这里开始：

```bash
kubectl explain daemonset.spec
```

一个基础daemonset yaml，

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor
  namespace: controller-test
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      containers:
      - name: main
        image: luksa/ssd-monitor
```

指定`.spec.selector`来确定这个DaemonSet对象管理的Pod，通常与`.spec.template.metadata.labels`中定义的Pod的label一致。

## 在每个节点上运行一个pod

在节点没有特殊调度的情况下，一个pod对应一个节点

- 节点丢失，该节点对应的pod不会在其他节点上重建
- 新加入的节点，会自动在改节点上部署一个pod

## 使用DaemonSet只在特定节点上起pod

### 使用高级调度限制pod在节点上运行

待学习

### 使用nodeSelector来限制pod可以运行的节点

如，只在node标签有 daemonset=true 的节点上运行pod：

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor-nodelabel
  namespace: controller-test
spec:
  selector:
    matchLabels:
      app: ssd-monitor-nodelabel
  template:
    metadata:
      labels:
        app: ssd-monitor-nodelabel
    spec:
      nodeSelector:
        daemonset: "true"         # 有一些特殊的需要加""
      containers:
      - name: main
        image: luksa/ssd-monitor
```

### 思考：高级调度和nodeSelector的优先级？

也就是说如果高级调度不让在改node上运行pod，但改node上打标签了