BusyBox 是一个集成了三百多个最常用Linux命令和工具的软件。BusyBox 包含了一些简单的工具，例如ls、cat和echo等等，还包含了一些更大、更复杂的工具，例grep、find、mount以及telnet。所以经常部署busybox做一些集群内的测试

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
      tolerations:
      - key: "key"
        operator: "Exists"
        effect: "NoSchedule"
      volumes:
      - name: volume-test
        emptyDir: {}
      containers:
      - name: app
        image: hub-mirror.c.163.com/library/busybox
        volumeMounts:
        - name: volume-test
          mountPath: /datatest
          readOnly: true
        args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 30000
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 10         #10s之后开始第一次探测
          periodSeconds: 5                #第一次探测之后每隔5s探测一次
```

