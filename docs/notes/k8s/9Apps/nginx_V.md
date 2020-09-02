这个部署完成以后，需要在容器的/usr/share/nginx/html/ 下添加index.html，用来访问测试，如果是一些sc类型，比如nfs，直接在pv的文件夹下创建这个即可。

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
  namespace: nginx
spec:
  storageClassName: nfs-client
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        k3s.io/hostname: lab4master
      containers:
      - name: nginx
        image: hub-mirror.c.163.com/library/nginx:1.7.9
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
      volumes:
      - name: www
        persistentVolumeClaim:
          claimName: nginx-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: nginx
  labels:
    app: nginx
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: web
    nodePort: 30080
  selector:
    app: nginx
```
