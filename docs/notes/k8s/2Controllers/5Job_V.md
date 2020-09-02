# Job：控制Pod完成任务

Begin：

```yaml
kubectl explain job.spec
```

## Job基础Yaml

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
  namespace: controller-test
spec:
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
        command: ["echo"]
        args: ["正在执行"]
```

- `restartPolicy: OnFailure`：容器在结束时会做什么，默认为Always，Job不建议用默认值，因为他们并不是要一直运行下去；绝大多数是OnFailure或Never。

## 一个Job运行多个Pods

一般无特别指明，一个Job运行一个Pod，Pod完成后处于completed状态结束。

运行多个Pods，通过指定属性`completions`和`parallelism`来实现。

1. completions：job完成需要几个pod完成
2. parallelism：同时可以有几个pod工作



Case1：Job完成需要5个pod completed，顺序执行（一次只能run一个）

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: multi-completion-job
  namespace: controller-test
spec:
  completions: 5
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
```

Case 2：Job完成需要 5个pod completed，同时可以运行2个Pod

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: multi-completion-batch-job
  namespace: controller-test
spec:
  completions: 5
  parallelism: 2
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
```

## Job超时时间设置

`activeDeadlineSeconds: 30`：如果job超过这个时间，job将终止尝试pod，并把job标记为失败

```yaml
sapiVersion: batch/v1
kind: Job
metadata:
  name: time-limited-batch-job
  namespace: controller-test
spec:
  activeDeadlineSeconds: 30
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
```

## Job失败重试次数设置

指定`.spec.backoffLimit`，指定失败之前可以重试次数，默认为6