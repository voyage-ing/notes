# 	Pod：Kubernetes最小执行单元

## Pod基本概念理解

### Pod是什么

*Pod* 是 Kubernetes 应用程序的基本执行单元,它是 Kubernetes 对象模型中创建或部署的最小和最简单的单元。

一个Pod可以包括一个或者多个容器。当一个pod包含多个容器时，这些容器总是运行于同一个工作节点上，一个pod绝不会跨越多个工作节点。

![image-20200723180719450](https://tva1.sinaimg.cn/large/007S8ZIlly1gh12ev9czdj30xs0dmmyp.jpg)

### 为什么需要Pod

由上面可以知道，一个Pod由一个或多个容器构成，那这里首先需要问一个问题：为何多个容器（每个容器单进程）比单个容器包含多个进程要好？

我们可以这样想，一个容器相当于一台独立的机器，而这台机器运行多个进程是利索当然的，我们现在电脑也是这样做的。容器被设计为每个容器只运行一个进程（除非进程本身产生子进程）。像上面那样一个机器里运行多个进程，记录每个进程运行的日志信息是我们必须要做的事情。这些进程的日志是记录到相同的标准输出中，此时我们很难确定每个进程分别发生了什么，所以要让每个进程运行在自己的容器中。这也是Kubernetes和Docker期望做的事情。

由于不能将多个进程聚集在一个单独的容器中，我们需要另一种更高级的结构来将单进程的多个容器绑定在一起提供服务，并将它们作为一个单元进行管理，这就是为什么需要Pod的原因。

### 通过Pod合理管理容器

**将多层应用分散到多个pod中**：

如果前端和后端都在同一个容器中，那么两者将始终在同一台节点上运行；如果你有一个双节点Kubemetes集群， 而只有一个单独的pod,那么你将始终只会用一个工作节点，而不会充分利用第二个节点上的计算资源(CPU和内存）。因此更合理的做法是将pod拆分到两个工作节点上，允许Kubemetes将前端安排到一个节点， 将后端安排到另一个节点， 从而提高基础架构的利用率。

**基于扩缩容(scaling)考虑而分割到多个pod中**：

对应K8s来说，不能横向的scale 容器，只能scale pod。此时，如果你的frontend，backend容器属于同一个Pod，k8s scale pod为2个pod，此时你就有了两个frontend，backend容器。但真实情况是，你想要两个backend，一个frontend。通常情况也是这样，frontend和backend有不同的scaling需求，就不能放在一个Pod里。

**何时在Pod中使用多个容器**：

这个Pod由，一个主进程和多个辅进程构成。

<img src="https://tva1.sinaimg.cn/large/007S8ZIlly1gh1882y20aj30em0b4mxq.jpg" alt="image-20200723212824195" style="zoom:50%;" />


***决定两个容器放入一个pod中还是两个单独的pod***，我们需要考虑以下问题：

- 它们需要一起运行还是可以在不同的主机上运行？
- 它们代表的是一个整体还是相互独立的组件？
- 它们必须一起进行扩缩容(scaling)还是可以分别进行？

## Pod 配置清单

manifest是我们经常会遇到的，特别是 config manifest ：配置清单。

在准备manifest时，这里有个非常好用的工具，以pod为例：

- `kubectl explain pod`：配置清单

  ```bash
  KIND:     Pod
  VERSION:  v1
  
  DESCRIPTION:
       Pod is a collection of containers that can run on a host. This resource is
       created by clients and scheduled onto hosts 
  FIELDS:
     apiVersion	<string>
     ...
     kind	<string>
     ...
     metadata	<Object>
     ...
     spec	<Object>
     ...
     status	<Object>
     ...
  
  ```

- `kubectl explain pod.metadata`：配置清单里每一项的明细

- `kubectl explain pod.spec.nodeSelector`：具体到某一项

### 运行中的Pod Yaml情况

一个正在运行的pod的完整描述包括三大重要部分，也几乎在所有Kubemetes资源中都可以找到的三大重要部分：

- metadata 包括名称、命名空间、标签和关于该容器的其他信息。
- spec (specification) 包含pod的明细，例如pod的容器、卷和其他数据。
- status包含运行中的pod的当前信息，Pod中包含每个容器的信息和状态。

一个正在运行的pod的完整描述，其中包含了它的状态。status部分包含只读的运行时数据，该数据展示了这个时刻的资源状态。而在创建新的pod时，并不需要提供status部分。

### 定义一个简单的Pod Yaml

这是由一个容器构成的Pod，myapp.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod            # Pod name
  namespace: myapp            
  labels:
    app: myapp
spec:
  containers:									
  - name: myapp-container		 # 容器的name
    image: busybox:latest
    ports:
    - containerPort: 8888    # 容器监听的端口
      protocol: TCP
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```

- 使用这个yaml文件

```bash
kubectl apply -f myapp.yaml
```

## 与Pod通信的两种方式

**1.**	通过Service服务发现，Service请看[这里](../Service_2.md)。

**2.** 	通过port-forward方式：

![image-20200727105317889](https://tva1.sinaimg.cn/large/007S8ZIlly1gh5cchtxvmj30yy08it9f.jpg)

具体使用方式：`kubectl port-forward -h`

```bash
  # Listen on ports 5000 and 6000 locally, forwarding data to/from ports 5000 and 6000 in the pod
  kubectl port-forward pod/mypod 5000 6000

  # Listen on ports 5000 and 6000 locally, forwarding data to/from ports 5000 and 6000 in a pod selected by the
deployment
  kubectl port-forward deployment/mydeployment 5000 6000

  # Listen on ports 5000 and 6000 locally, forwarding data to/from ports 5000 and 6000 in a pod selected by the service
  kubectl port-forward service/myservice 5000 6000

  # Listen on port 8888 locally, forwarding to 5000 in the pod
  kubectl port-forward pod/mypod 8888:5000

  # Listen on port 8888 on all addresses, forwarding to 5000 in the pod
  kubectl port-forward --address 0.0.0.0 pod/mypod 8888:5000

  # Listen on port 8888 on localhost and selected IP, forwarding to 5000 in the pod
  kubectl port-forward --address localhost,10.19.21.23 pod/mypod 8888:5000

  # Listen on a random port locally, forwarding to 5000 in the pod
  kubectl port-forward pod/mypod :5000
```

## 按需组织Pod

### 使用Label组织Pod

#### 引入Label的意义

下面这么多pod，功能上有相同有不同的：

![image-20200727173448037](https://tva1.sinaimg.cn/large/007S8ZIlly1gh5nyaem93j30py0cqac2.jpg)

使用Label标记：

1. 不同功能的横向维度
2. 不同版本的纵向维度

![image-20200727173657938](https://tva1.sinaimg.cn/large/007S8ZIlly1gh5o0ike4fj30pu0boq55.jpg)

#### 关于Label的几种应用场景

1. kube-controller进程通过资源对象RC上定义的Label Selector来筛选要监控的Pod副本的数量，从而实现Pod副本的数量始终符合预期设定的全自动控制流程。

2. kupe-proxy进程通过Service的Label Selector来选择对应的Pod，自动建立器每个Service到对应Pod的请求转发路由表，从而实现Service的智能负载均衡机制。

   ```bash
   ---
   apiVersion: v1
   kind: Pod
   metadata:        
     labels:                 # pod设置label
       app: myapp
   ......
   ---
   apiVersion: v1
   kind: Service
   metadata:
     ......
   spec:
     selector:               # service中选择这个label
       app: myapp
   ......
   ---
   ```

3. 通过对某些Node定义特定的Label,并且在Pod定义文件中使用NodeSelector这种标签调度策略，Kube-scheduler进程可以实现Pod定向调度的特性。

   ```bash
   # 给node打标签之后，再用nodeSelector指定
   kubectl label nodes node1 myapp.node/whoesnode=mynode
   ```

#### 与Label使用的相关命令

- 增 Label

```bash
kubectl label pods <pod-name> <label-key>=<label-value>
```

- 删 Label

```bash
kubectl label pods <label-key>-            # 后面是一个 减号
```

- 查 Label

```bash
kubectl get pods --show-labels
kubectl get pods -l mylabel=label1         # 通过label1查pods
kubectl get pods -l mylabel='!label1'      # 查排出label1的pods
kubectl get pods -A -L LABEL1,LABEL2
```

> 确保使用单引号来圈引电nv, 这样bashshell才不会解释感叹号（感叹号在bash中有特殊含义，表示事件指示器）
>
> `--all-namespaces -l` ：可以值得一个ns下的label，也可以跨ns使用label

- 改 Label

```bash
kubectl label pods <pod-name> <label-key>=<new-value> --overwrite
```

### 使用Namespace组织Pod

使用Namespace组织Pods，往往这些Pod是处在同一个项目下的。

## 其他相关

### 查Pod日志

`kubectl logs podname -c containername`：查看当前pod的某一容器日志。

> 但在某些情况下：有个容器因为某些故障被重新调度了，你想知道为什么前一个pod终止了，所以你想看的是前一个容器的日志，而不是当前容器的。`kubectl logs mypod --previous`

