# Service创建及配置选项

[TOC]

需要Service的原因，我觉得主要从两个方面考虑：

1. Pod的状态并不稳定，导致PodIP会随时变化；
2. 水平伸缩会使多个Pod提供相同的服务来负载均衡，但每个Pod的ip肯定说不一样的；

所以就需要一个稳定的地址来暴露服务给用户，用户完全不需要考虑podip是多少，这个就是服务发现 service。

---

中间：待学习

举个例子，考虑一个图片处理 backend，它运行了3个副本。这些副本是可互换的 —— frontend 不需要关心它们调用了哪个 backend 副本。 然而组成这一组 backend 程序的 Pod 实际上可能会发生变化，frontend 客户端不应该也没必要知道，而且也不需要跟踪这一组 backend 的状态。 Service 定义的抽象能够解耦这种关联。

对 Kubernetes 集群中的应用，Kubernetes 提供了简单的 Endpoints API，只要 Service 中的一组 Pod 发生变更，应用程序就会被更新。 对非 Kubernetes 集群中的应用，Kubernetes 提供了基于 VIP 的网桥的方式访问 Service，再由 Service 重定向到 backend Pod。

endpoints 原理 [没有 selector 的 Service](http://docs.kubernetes.org.cn/703.html#_selector_Service)

为什么可能需要没有 selector 的 Service

---



## kubectl expose

通过kubectl expose 创建service，通过 kubectl expose -h 查询详细具体内容;

```yaml
kubectl expose可以使用的对象：
pod (po), service (svc), replicationcontroller (rc), deployment (deploy), replicaset (rs)
```

需要注意：

1. expose pod：前提要求pod必须有label，否则出错如下：

   ```yaml
   $ kubectl expose po httpd-manual --port=8080 --target-port=80
   error: couldn't retrieve selectors via --selector flag or introspection: the pod has no labels and cannot be exposed
   ```

2. expose controller：前提是`.spec.selector`必须设置。

几个expose实例：

Expose svc: `kubectl expose service -n nginx nginx --name=nginx1 --port=80 --type=NodePort`

Expose pod: `kubectl expose po httpd-manual --port=8080 --target-port=80`

Expose controller: `kubectl expose replicationcontroller -n controller-test kubia --name rc-expose --port=8080 --target-port=8080`

Expose from yaml: `kubectl expose -f ReplicationContraller.yaml -n controller-test --name=rc-expose2 --port=8080 --target-port=8080`

> ​	这个是根据yaml文件中的`.spec.selector`来创建service



## Service中的配置选项

关于Service的详细介绍：

```bash
kubectl explain svc.spec
```

一个简单的Service yaml文件

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubia
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: kubia
```

### 会话亲和度

通过配置service的`.spec.sessionAffinity: ClientIP`：实现从同一个clientIP的所有请求，均转发到同一个pod。

该参数只有两个可选项，默认为none。

### Service配置多端口

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
    selector:
      app: MyApp
    ports:
      - name: http
        protocol: TCP
        port: 80
        targetPort: 9376
      - name: https
        protocol: TCP
        port: 443
        targetPort: 9377
```

### 使用命名的端口	

**为什么要使用命名端口的方式：**最大的好处就是即使更换containerPort，也不需要改变service的targetPort。

比如现在你的pod中containerPort是8080，但你想更改他为80，使用命名的端口的话你只需要修改pod.spec.ports.containerPort为80，而不需要你去再修改service。

使用命名的端口，需要首先在pod中指定名字：

```yaml
kind: Pod
metedata:
  name: kubia
spec:
  containers:
    ports:
    - name: httpname1
      containerPort: 8080
    - name: httpsname2
      containerPort: 8443
```

由此可以明确的看到：tagetPort=containerPort 这样就不会混淆了。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubia
spec:
  ports:
  - name: http
    port: 80
    targetPort: httpname1
  - name: https
    port: 443
    targetPort: httpsname2
  selector:
    app: kubia
```

## NodePort

- 一个典型nodeport.yaml例子：


```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-node-service
  labels:
    name: kube-node-service
spec:
  type: NodePort      #这里代表是NodePort类型的
  ports:
  - port: 80          #这里的端口和clusterIP(10.97.114.36)对应，即10.97.114.36:80,供内部访问。
    targetPort: 8081  #端口一定要和container暴露出来的端口对应，nodejs暴露出来的端口是8081，所以这里也应是8081
    protocol: TCP
    nodePort: 32143   # 所有的节点都会开放此端口，此端口供外部调用。
  selector:
    app: web          #这里选择器一定要选择容器的标签。
```

- 一个nodePort类型的service会使所有的节点的nodePort端口打开。
- 不指定targetPort的话，就是和port一样的。