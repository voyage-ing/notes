# CronJob：按照Cron进行Job

Begin：

```bash
kubectl explain cronjob.spec
```

CronJob最重要的功能就是cron调度；CronJob按照cron的调度，按照jobTemplate来启用一个job，然后通过这个job来运行pod。

## CronJob基础Yaml

每个小时内的0分、15分、30分、45分的时候，通过Job运行pod。

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batch-job-every-fifteen-minutes
  namespace: controller-test
spec:
  schedule: "0,15,30,45 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          restartPolicy: OnFailure
          containers:
          - name: main
            image: luksa/batch-job
```

## 其他一些重要参数

可以根据这个查看：

```bash
kubectl explain cronjob.spec
```

- `.spec.startingDeadlineSeconds: 15`：单位是秒，表示如果Job因为某种原因无法按调度准时启动，在spec.startingDeadlineSeconds时间段之内，CronJob仍然试图重新启动Job，如果在.spec.startingDeadlineSeconds时间之内没有启动成功，则不再试图重新启动。如果spec.startingDeadlineSeconds的值没有设置，则没有按时启动的任务不会被尝试重新启动
- `.spec.concurrencyPolicy`：是否允许Job并发:
  - Allow：上一次Job没有完成，本次Job可以启动。
  - Forbid：上一次Job没有完成，本次Job不可以启动。
  - Replace：上一次Job没有完成，本次Job取而代之，将上一次Job杀死。
- `.spec.successfulJobsHistoryLimit`：保存成功历史Job的数量，默认３，如果为０则CronJob在Job成功后立即删除。
- `.spec.failedJobsHistoryLimit`：保存失败历史Job的数量，默认１，如果为0则CronJob在Job失败后立即删除。
- `.spec.suspend` 字段也是可选的。如果设置为 `true`，后续所有执行都将被挂起。它对已经开始执行的 Job 不起作用。默认值为 `false`。

## 实践：

每一分钟执行一个，上一个没完成运行并行下一个，只保留5个完成的job。

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cronjob-test
  namespace: controller-test
spec:
  successfulJobsHistoryLimit: 5
  concurrencyPolicy: Allow
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          restartPolicy: OnFailure
          containers:
          - name: main
            image: luksa/batch-job
```

edit cronjob，设置 spec.suspend=true：后续所有执行都将被挂起。它对已经开始执行的 Job 不起作用。

