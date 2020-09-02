

# Kubeconfig基本结构并管理多集群

[TOC]

前提通过rbac授权role或者clusterrole，再进行如下配置。

## 快速多kubeconfig融合：

```bash
KUBECONFIG=lab2:lab3 kubectl config view --merge --flatten > config
```

## 通过Kubectl设置kubeconfig

ca证书获取方式，下面用到的是base64解密之后的：

```bash
kubectl get secret <secretname> -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
```

token获取方式（需要base64解密）：

```bash
kubectl get secret <secretname> -o jsonpath='{.data.token}' | base64 --decode > token
```

1. 设置cluster

```bash
kubectl config set-cluster cluster_name \
    --embed-certs=true \
    --server=https://ip:6443 \
    --certificate-authority=./ca.crt
```

> 这里的ca.crt是base64解密之后的，形如
>
> -----BEGIN CERTIFICATE-----
> ...............................................
> -----END CERTIFICATE-----

2. 设置token认证

```bash
kubectl config set-credentials lab2-user --token=<token>
```

3. 设置上下文

```bash
kubectl config set-context lab2 --cluster=lab2 --user=lab2-user
```

验证：

![image-20200709142332144](https://tva1.sinaimg.cn/large/007S8ZIlly1ggkp9pcowmj30nc04ajrv.jpg)

## 修改kubeconfig的NAME 、CLUSTER、AUTHIINFO

修改kubectl时候注意三大位置，clusters，contexts，users，对应位置的名称对应。

![image-20200709141358025](https://tva1.sinaimg.cn/large/007S8ZIlly1ggkozs6i0nj30tu0t8jux.jpg)

## 通过ServiceAccount的token，创建kubeconfig文件

关于sa的一些知识，请在文档内搜索rbac。

```yaml
apiVersion: v1
kind: Config

clusters:
- name: ${cluster_name}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
    
contexts:
- name: ${context_name}
  context:
    cluster: ${cluster_name}
    namespace: default
    user: ${sa_name}
    
current-context: ${context_name}

users:
- name: ${sa_name}
  user:
    token: ${token}
```

- ca证书获取方式（这里需要的是base64加密之后的）：

```bash
ca=$(kubectl get secret -n kube-system <secretname> -o jsonpath='{.data.ca\.crt}')
```

- token获取方式（需要base64解密）：

```bash
token=$(kubectl get secret -n kube-system <secretname> -o jsonpath='{.data.token}' | base64 --decode)
```

- Server: 需要是https://ip:6443，一般是6443
- sa_name: 并不一定是Servicename，只要与users.name对应即可。
- cluster_name 和 context_name可以自己指定，也可以修改，会稍微麻烦，建议一次性修改准确，因为这个和控制多集群又关系。

需要的这几个值设置好之后就可以进行下一步：

```bash
echo "
apiVersion: v1
kind: Config

clusters:
- name: ${cluster_name}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
    
contexts:
- name: ${context_name}
  context:
    cluster: ${cluster_name}
    namespace: default
    user: ${sa_name}
    
current-context: ${context_name}

users:
- name: ${sa_name}
  user:
    token: ${token}
" > sa-kubeconfig
```

验证：

![image-20200708121637987](https://tva1.sinaimg.cn/large/007S8ZIlly1ggjfzchatxj30vo02uaad.jpg)

![image-20200708121737504](https://tva1.sinaimg.cn/large/007S8ZIlly1ggjg0dhr2vj30qq02qglu.jpg)

