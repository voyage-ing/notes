```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
spec:
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      volumes:
      - name: volume-test
        persistentVolumeClaim:
         claimName: busybox-pvc
      containers:
      - name: app
        image: rancher/library-busybox:1.31.1
        volumeMounts:
        - name: volume-test
          mountPath: /datatest
          readOnly: true
        resources:
          limits:
            cpu: 100m
            memory: 64M
          requests:
            cpu: 100m
            memory: 64M
        args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 30000
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: busybox-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
```

