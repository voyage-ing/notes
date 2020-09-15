# Ingress：通过域名发布服务

之前学习的Service，包括nodeport，clusterip等都是通过ipvs，或者iptable实现的（根据kubelet中的配置来选择）；四层代理有个缺陷就是他只是工作在tcp/ip协议栈，如果外部请求是HTTPS的请求，Service是无法调度的。如果构建在内部的服务是HTTP，还希望用Service调度的话，那么证书和私钥的配置问题就来了。

Ingress就是来解决这样一个问题的，用来解析域名请求，通过Ingress Controller把他们负载到后端。

Ingress只需要一个公网IP，就可以通过不同的主机名和路径访问许多服务，如下图：

![image-20200910155310238](https://tva1.sinaimg.cn/large/007S8ZIlly1gillwex3n9j30zk0b6tb4.jpg)

## Ingress Controller

Ingress Controller他是一个或一组独立的Pod资源，他通常就是一个运行着有七层代理能力或调度能力的应用，比如：NGINX、HAproxy、Traefik、Envoy。

深入理解Ingress工作原理：https://zhuanlan.zhihu.com/p/117617642

有一点需要注意的是：

后端pod的sevice仅仅是归组Pod，归组之后才能给ingress使用，所以是虚线；Ingress Controller是Pod，而Pod和Pod之间由于是在同一网段可以直接通信，无需经过Service，实线。

![image-20200910162533269](https://tva1.sinaimg.cn/large/007S8ZIlly1gilmu2x455j30pe0im16h.jpg)

## 创建Ingress资源

这里是一个traefik ingress controller的例子：

- `kubernetes.io/ingress.class: traefik`：用于识别Ingress Controller类型，便于生成对应规则。

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/frontend-entry-points: http,https
  name: ingress-name
spec:
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 80
```

### 同一主机不同路径

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-name
spec:
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: app1-foo
          servicePort: 80
      - path: /bar
        backend:
          serviceName: app1-bar
          servicePort: 80
```

- 访问app1：http://app1.example.com/foo
- 访问app2：http://app1.example.com/bar

### 不同主机

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-name
spec:
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: app1
          servicePort: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: app2
          servicePort: 80
```

- App1: app1.example.com
- App2: app2.example.com

## Ingress配置https访问

这里是个使用手动创建tls证书的ingress例子，但其实可以用cert-manager来自动分配证书，后面应该会学习到。

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/frontend-entry-points: http,https
    traefik.ingress.kubernetes.io/redirect-entry-point: https
  name: app1
spec:
  tls:
  - hosts:
    - app1.example.com
    secretName: tls-secret-test
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: app1
          servicePort: 8080
```

​	