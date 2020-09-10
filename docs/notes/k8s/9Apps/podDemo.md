此yaml文件只创建一个Pod，会慢慢补全不同的spec配置，可以根据需要来取舍；

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pure-pod
spec:
  containers:
  - image: hub-mirror.c.163.com/library/nginx:1.7.9
    imagePullPolicy: IfNotPresent
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
      name: web
    resources:
      limits:
        cpu: 100m
        memory: 200Mi
      requests:
        cpu: 100m
        memory: 100Mi
  tolerations:
    - key: node.kubernetes.io/not-ready
      operator: Exists
      effect: NoExecute
      tolerationSeconds: 2
    - key: node.kubernetes.io/unreachable
      operator: Exists
      effect: NoExecute
      tolerationSeconds: 2
```

