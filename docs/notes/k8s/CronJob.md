## CronJob

### A CronJob Example

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

- .spec.schedule	指定任务运行周期，格式同[Cron](https://blog.csdn.net/weixin_42433970/article/details/102505784)
- .spec.jobTemplate   指定需要运行的任务，格式同[Job](https://www.kubernetes.org.cn/Job)
- .spec.startingDeadlineSeconds   指定任务开始的截止期限
- .spec.concurrencyPolicy   指定任务的并发策略，支持Allow、Forbid和Replace三个选项

