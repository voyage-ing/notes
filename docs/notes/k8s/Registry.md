

## Registry

[TOC]



### 基础知识：

#### **curl **

- -X \<method> : 设置请求方法
- -H \<header> :  设置请求头
- -D \<data> : 设置请求数据（POST方法）
- -v : 展示服务器的响应

### Registry添加Service：

- Ingress: 推荐使用
  - 访问UI界面：http://r.lab3.cn/ui
  - 访问api：http://r.lab3.cn/v2/_catalog

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/frontend-entry-points: http,https
    # traefik.ingress.kubernetes.io/redirect-entry-point: https				强制https
  name: registry
  namespace: kube-system
spec:
  rules:
  - host: r.lab3.cn
    http:
      paths:
      - backend:
          serviceName: kube-registry
          servicePort: 5000
        path: /v2
      - backend:
          serviceName: kube-registry
          servicePort: 8000
        path: /ui
  tls:
  - hosts:
    - r.lab3.cn
    # secretName: repo-tls	https可以启用
status:
  loadBalancer:
    ingress:
    - ip: 172.27.11.151			# 需要修改为节点ip
```

- nodePort：
  - Api: nodeip:30500/v2
  - Ui: nodeip:30800/ui

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-registry-nodeport
  namespace: kube-system
  labels:
    app: kube-registry
spec:
  type: NodePort     
  ports:
  - port: 5000          
    targetPort: 5000
    protocol: TCP
    nodePort: 30500
  selector:
    app: kube-registry
---
apiVersion: v1
kind: Service
metadata:
  name: kube-registry8000-nodeport
  namespace: kube-system
  labels:
    app: kube-registry
spec:
  type: NodePort      
  ports:
  - port: 8000          
    targetPort: 8000
    protocol: TCP
    nodePort: 30800
  selector:
    app: kube-registry
```

### Registry api：

#### Docker Registry HTTP API V2

- https://docs.docker.com/registry/spec/api/

#### 常用API

\<name> 是指包括存储路径的镜像名字，如`drone/drone`

\<digest> 是对应该镜像的sha256

\<reference> 是对应镜像的tag,  如latest，v1，v2

- 获取所有镜像：`GET /v2/_catalog`

- 获取镜像详情：`GET /v2/<name>/manifests/<reference>`

- 获取镜像对应的digets：`HEAD /v2/<name>/manifests/<reference>` 
  - 需要在request header中添加："Accept" : "application/vnd.docker.distribution.manifest.v2+json"
  - 在Headers中的"Docker-Content-Digest"
  
- 列出镜像的所有tag：`GET /v2/<name>/tags/list`

- 删除镜像：`DELETE /v2/<name>/manifests/<digest>` \<digest>从第三条获取

  - ```bash
    curl -I --header "Accept:application/vnd.docker.distribution.manifest.v2+json" registry.k3s:5000/v2/vm/openwrt/manifests/19.07.3
    # 终端输出的 Docker-Content-Digest：对应值
    ```

  - ```
    curl -X DELETE registry.k3s:5000/v2/vm/openwrt/manifests/sha256:87c6c69372dc8d2bf545b5c119e4b6988d601f0a8e3b6260cac243ed8f63ea91
    ```

    



### 为Registry的Ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/frontend-entry-points: http,https
  name: registry
  namespace: kube-system
spec:
  rules:
  - host: r.lab3.cn
    http:
      paths:
      - path: /ui
        backend:
          serviceName: kube-registry
          servicePort: 8000
      - path: /v2
        backend:
          serviceName: kube-registry
          servicePort: 5000
```

