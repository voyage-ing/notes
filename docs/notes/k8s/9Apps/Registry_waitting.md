

# Registry

[TOC]



## 基础知识：

**curl **

- -X \<method> : 设置请求方法；
- -H \<header> :  设置请求头；
- -D \<data> : 设置请求数据（POST方法）；
- -v : 展示服务器的响应；
- `-i` 参数可以显示 http response 的头信息，连同网页代码一起；
- `-I` 参数则只显示 http response 的头信息；

## Registry添加Service：

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

## 为Registry添加Ingress

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



## Registry api：

### Docker Registry HTTP API V2

- https://docs.docker.com/registry/spec/api/

### 常用API

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
    curl -I --header "Accept:application/vnd.docker.distribution.manifest.v2+json" registry.k3s:5000/v2/<name>/manifests/<tag>
    # 终端输出的 Docker-Content-Digest：对应值
    ```

  - ```bash
    curl -X DELETE registry.k3s:5000/v2/<name>/manifests/sha256:87c6c69372dc8d2bf545b5c119e4b6988d601f0a8e3b6260cac243ed8f63ea91
    ```

  
  > 这样删除有个问题，如果你是同一个镜像不同tag，删除任何一个tag，所有同源的镜像都会被删除；

### 使用api修改镜像tag和repo

https://stackoverflow.com/questions/33392023/how-to-rename-a-docker-image-in-the-remote-registry

仅修改tag：https://dille.name/blog/2018/09/20/how-to-tag-docker-images-without-pulling-them/

1. get manifests (in v2 schema)
2. post every layer.digest in the new repo
3. post config.layer
4. put whole manifest to new repo

## details:

```bash
curl --header "Accept:application/vnd.docker.distribution.manifest.v2+json" 127.0.0.1:5000/v2/vm/centos8/manifests/latest

MANIFEST=$(curl -H "Accept:application/vnd.docker.distribution.manifest.v2+json" http://localhost:5000/v2/vm/centos8/manifests/latest)
```

```
Handling connection for 5000
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
   "config": {
      "mediaType": "application/vnd.docker.container.image.v1+json",
      "size": 2608,
      "digest": "sha256:1c89293bfdb46a841899f126939d470134c32007074a70f8b377ca2645898307"
   },
   "layers": [
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 2813316,
         "digest": "sha256:cbdbe7a5bc2a134ca8ec91be58565ec07d037386d1f1d8385412d224deafca08"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 161,
         "digest": "sha256:9a07b4e592617b6d77631a8dc000c224bfdb5406b273dc2f21adbb031d8ed972"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 2097498376,
         "digest": "sha256:167d06fe4621510e5d3685f9f2450764b0545ebb4497f8b04486bd018830db48"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 186,
         "digest": "sha256:0f95ac085d2d817805ec4fd55f80796db608c98915577018127e9555740e70d2"
      }
   ]
}
```

2

```
curl -X POST 127.0.0.1:5000/v2/vm/test/centos8/blobs/uploads/?mount="sha256:1c89293bfdb46a841899f126939d470134c32007074a70f8b377ca2645898307"&from="vm/centos8"
```

3 

```
curl -X POST 127.0.0.1:5000/v2/vm/test/centos8/blobs/uploads/?mount="sha256:0f95ac085d2d817805ec4fd55f80796db608c98915577018127e9555740e70d2"&from="vm/centos8"
```



4

```bash
curl -X PUT -H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" -d "${MANIFEST}" 127.0.0.1:5000/v2/vm/test/centos8/manifests/newtagtest
```



1. **GET** manifest from `reg:5000/v2/{oldRepo}/manifests/{oldtag}` with`accept` header:`application/vnd.docker.distribution.manifest.v2+json`
2. For every layer(每一层) : **POST** `reg:5000/v2/{newRepo}/blobs/uploads/?mount={layer.digest}&from={oldRepoNameWithaoutTag}`
3. **POST** `reg:5000/v2/{newRepo}/blobs/uploads/?mount={config.digest}&from={oldRepoNameWithaoutTag}`
4. **PUT** `reg:5000/v2/{newRepo}/manifests/{newTag}` with `content-type` header:`application/vnd.docker.distribution.manifest.v2+json` and `body` from step 1 response

```
curl -X PUT -H "Content-Type: ${CONTENT_TYPE}" -d "${MANIFEST}" "${REGISTRY_NAME}/v2/${REPOSITORY}/manifests/${TAG_NEW}"
```

1. enjoy!