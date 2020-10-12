# Cert-Manager



k8s cert-manager issuer 和 tls



官方稳定：https://cert-manager.io/docs/

学习及参考：https://cloud.tencent.com/developer/article/1402451

![image-20200929164204982](https://tva1.sinaimg.cn/large/007S8ZIlly1gj7m3kghagj313q0q2437.jpg)

- `Issuer`代表的是证书颁发者，可以定义各种提供者的证书颁发者，当前支持基于`Letsencrypt`、`vault`和`CA`的证书颁发者，还可以定义不同环境下的证书颁发者。
  - `kind: Issuer`仅同一命名空间下可用；
  - ` ClusterIssuer`整个集群可用；

## 安装部署

```bash
# Kubernetes 1.16+
$ kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
```

验证安装：

```bash
$ kubectl get pods --namespace cert-manager

NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5c6866597-zw7kh               1/1     Running   0          2m
cert-manager-cainjector-577f6d9fd7-tr77l   1/1     Running   0          2m
cert-manager-webhook-787858fcdb-nlzsq      1/1     Running   0          2m
```

Create an `Issuer` to test the webhook works okay:

```bash
cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```

```bash
kubectl apply -f test-resources.yam
```

稍等片刻，`kubectl describe certificate -n cert-manager-test`，若出现下面则成功：

```yaml
Events:
  Type    Reason     Age   From          Message
  ----    ------     ----  ----          -------
  ...
  Normal  Issuing    3m4s  cert-manager  The certificate has been successfully issued
```

## 使用Cert-Manager

clusterissuer

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-cluster
spec:
  acme:
    email: liyi.meng@me.com
    privateKeySecretRef:
      name: letsencrypt-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - http01:
        ingress:
          class: traefik
```



```yaml

```

