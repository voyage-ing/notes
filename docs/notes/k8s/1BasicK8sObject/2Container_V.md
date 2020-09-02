

# 容器：Pod中的Containers

## 存活探针：容器健康状态检查

存活探针的目标是容器。

Kubemetes可以通过存活探针检查容器是否在运行。可以为pod中的每个容器单独指定存活探针。如果探测失败，Kubemetes将定期执行探针并重新启动容器。

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



