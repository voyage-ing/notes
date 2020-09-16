# PVC&PV：持久卷声明和持久卷

## PVC&PV基本流程

`kubectl explain pod.spec.volumes` 这里面可以发现有一些：aws，gce等类似的卷，这种方式与Kubernetes底层代码深度耦合；

使用持久卷声明和持久卷（PersistentVolumeClaim & PersistentVolume）;

![image-20200916114341028](https://tva1.sinaimg.cn/large/007S8ZIlly1gisceogc66j30g908gjsr.jpg)

> 这是一种手动的创建PV，PVC的过程，之后会详细学到StorageClass，就可以自动动态的创建PV；

PV不属于任何namespace，他跟节点一样是集群层面的资源；

![image-20200916120454728](https://tva1.sinaimg.cn/large/007S8ZIlly1gisd0q598gj30ho0bvabj.jpg)

## 手动创建PV

pv是没有命名空间限制的资源，但pvc是有命名空间限制的；

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: test-pv
spec:
  capacity: 
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/pvtest
```

- accessModes:
  - ReadWriteOnce -- the volume can be mounted as read-write by a single node
  - ReadOnlyMany -- the volume can be mounted read-only by many nodes
  - ReadWriteMany -- the volume can be mounted as read-write by many nodes
- persistentVolumeReclaimPolicy:
  - Retain -- 保留PV及数据
  - Recycle -- 保留PV，但清空PV数据 (`rm -rf /thevolume/*`)
  - Delete -- 删除released的pv和后端存储volume
- hostPath，本地路径，也有其他选项比如nfs；

```bash
$ kubectl get pv test-pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
test-pv   2Gi        RWO,ROX        Retain           Available                                   4m
```

pv状态显示为可用，因为还没创建PVC；

## 创建PVC与PV绑定

因为刚刚我们创建的PV是2G大小的，我们现在先创建个PVC需要3G的，看看会有什么情况：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pv
  namespace: default
spec:
  resources:
    requests:
      storage: 3Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
```

> pvc不是用storageClass，也需要写明这一项为空 `storageClassName: ""`

pv是2G的但PVC要的3G，没找到合适的就pending了；

```yaml
$ kubectl get pvc test-pv
NAME      STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test-pv   Pending                                                     47s
```

如果修改为2G的，就会bound；另外，如果pv是2G，pvc1G，也可以bound，但是这不是最优情况，它的bound是根据最优情况来的：

```bash
$ kubectl get pvc
NAME      STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test-pv   Bound    test-pv   2Gi        RWO,ROX                       11s
```

将回收策略为retain的pv状态恢复为available:

```bash
kubectl patch pv test-pv  -p '{"spec":{"claimRef": null}}'
```

- 如果回收策略为delete的话，released状态会直接删除pv；

## 在Pod中使用PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvpvcpod-test
spec:
  containers:
  - image: hub-mirror.c.163.com/library/busybox
    name: busybox
    args:
    - /bin/sh
    - -c
    - sleep 10; touch /tmp/healthy; sleep 30000
    volumeMounts:
    - name: test
      mountPath: /data/test
  volumes:
  - name: test
    persistentVolumeClaim:
      claimName: test-pv
```

