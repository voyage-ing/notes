# Taints & tolerations

Taints（节点污点）和 tolerations（Pod对于污点的容忍度），只有当pod容忍某个节点的污点，这个pod才能被调度到该节点；

> 污点和容忍度是一个对应的关系，如果一个集群里的pod只设置了容忍度，没有任何污点，相当于什么也没有设置，因为容忍度要容忍污点；

原理：http://blog.itpub.net/69908804/viewspace-2640966/

## 使用taints&tolerations

### 给node设置taints

```bash
kubectl taint node [node] key=value:[effect]
# 示例：
kubectl taint node testnode test=aaa:NoSchedule
kubectl taint node testnode test=aaa:NoExecute
```

[effect]可以是， [ NoSchedule | PreferNoSchedule | NoExecute ]：

- **NoSchedule** ：一定不能被调度；
- **PreferNoSchedule**：尽量不要调度；
- **NoExecute**：不仅不会调度，还会驱逐Node上已有的Pod；

### 去除taints

```bash
#去除指定key的effect：
kubectl taint nodes node_name key:[effect]-    # (这里的key不用指定value)

#去除指定key及其所有的effect:
kubectl taint nodes node_name key-

#示例：
kubectl taint node test test:NoSchedule-
kubectl taint node test test:NoExecute-
kubectl taint node test test-
```

简单taints和tolerations示例，承上启下：

```yaml
kubectl taint nodes node1  key=value:NoSchedule
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-taints
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
# 或者
spec:
  tolerations:
  - key: "key"
    operator: "Exists"
    effect: "NoSchedule"
```

### 设置容忍度tolerations

tolerations中的设置和污点匹配时，pod才能调度到节点上；

- operator是**Exists**（在这种情况下不应指定value）；
- operator是**Equal**，value需要相等；
- operator默认情况下是**Equal**；

两种特殊情况：

- 带有**operator Exists**的空键匹配所有**key**，**value**和**effect**，这意味着它将容忍所有内容；

  ```
  tolerations:
  - operator: "Exists"
  ```

- 匹配所有**effect**；

  ```
  tolerations:
  - key: "value"
    operator: "Exists"
  ```

