# 容器：Pod中的Containers

## LivenessProbe：存活探针

存活探针的目标是容器。

LivenessProbe是让Kubernetes知道你的应用是否活着。如果你的应用还活着，那么Kubernetes就让它继续存在。如果你的应用程序已经死了，Kubernetes将移除Pod并重新启动一个来替换它。

> livenessProbe 默认探测频率是10s一次，可通过periodSeconds来设定。通过initialDelaySeconds 设置第一次探测前的等待时间

具体使用方法：

```bash
kubectl explain pod.spec.containers.livenessProbe
kubectl explain pod.spec.containers.livenessProbe.httpGet
```

主要三种探测容器机制：

1. 针对容器的ip，指定路径和端口，执行HTTP GET请求。响应状态码是2xx或3xx则探测成功。	

   ![image-20200804132348850](https://tva1.sinaimg.cn/large/007S8ZIlly1gi1m4h95uwj30ei014dfn.jpg)

2. 指定端口，尝试建立TCP连接，连接建立探测成功。

   ![image-20200804132415395](https://tva1.sinaimg.cn/large/007S8ZIlly1gi1m4gzik6j30es01gdfq.jpg)

3. 指定command，在容器里执行命令，根据命令返回值判断是否成功。

   ![image-20200804132435689](https://tva1.sinaimg.cn/large/007S8ZIlly1gi1m4i8qlpj30eu019wed.jpg)

一个存活探针使用例子：

```yaml
apiVersion: v1
kind: Pod
metadata:  
  name: kubia-liveness
  namespace: probe-test
spec:  
  containers:  
  - image: luksa/kubia-unhealthy
    imagePullPolicy: IfNotPresent
    name: kubia    
    livenessProbe:                       
      httpGet:                            
        path: /                             
        port: 8080
```

​	查看探针使用情况：

![image-20200804134332621](https://tva1.sinaimg.cn/large/007S8ZIlly1gi1m4hpifqj30jn074aap.jpg)

1.  Last State：容器上次结束的状态
2.  Exit Code：137=128+9；9是SIGKILL的信号编号：进程被强制终止。[Linux标准信号详解。](https://blog.csdn.net/XiaoTong_zZZ/article/details/106556716)
3.  Liveness：
    1. delay=0s：容器启动以后立即探测
    2. timeout：容器必须在1s内进行响应，否则认为失败
    3. period=10s：每10s进行一次探测
    4. #failure：连续探测3次失败，重启容器

> 当Exit Code：137 意味着容器被强行终止，这时候会创建一个全新的容器而不是重启原来的容器。

## ReadinessProbe：就绪探针

`kubectl explain pods.spec.containers.readinessProbe`

ReadinessProbe和livenessProbe都是一个层面的东西，所以他们的一些用法基本一致。

三种类型：Exec、HTTP GET、TCP socket；具体使用见上。

### ReadinessProbe操作流程

ReadinessProbe让Kubernetes知道你的应用是否准备好为请求提供服务。Kubernetes只有在就绪探针通过才会把流量转发到Pod。如果就绪探针检测失败，Kubernetes将停止向该容器发送流量，直到它通过。

与存活探针不同，如果容器未通过准备检查，则不会被终止或重新启动。这是存活探针与就绪探针之间的重要区别。存活探针通过杀死异常的容器并用新的正常容器替代它们来保持pod正常工作，而就绪探针确保只有准备好处理请求的pod才可以接收请求。

如果一个container的就绪探测失败，则将该容器从endpoints列表中移除，链接到Sevice的客户端不会重定向到该pod中。

![image-20200914094645320](https://tva1.sinaimg.cn/large/007S8ZIlly1gipxsd0u64j30gk06gdgh.jpg)

就绪探针保证客户端只与正常的Pod交互，并且永远不会知道系统存在问题。

### 创建ReadinessProb

```yamls
apiVersion: v1
kind: ReplicationController
metadata:
  name: kubia
  namespace: controller-test
spec:
  replicas: 3
  selector:
    app: kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          initialDelaySeconds: 20
          exec:
            command:
            - ls
            - /var/ready
```

> `initialDelaySeconds`给新启动的container一定的准备时间，让其就绪。不设置也会依据periodSeconds的值每几秒就探测一次，默认是10s；

## 设置容器启动执行Command

.spec.containers

容器内执行命令

```
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
        command: ["echo"]
        args: ["正在执行"]
```



