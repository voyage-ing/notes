# StorageClass：动态PV提供

## StorageClass参数

大规模集群中可能会有很多PV，如果这些PV都需要手动来创建这是一件很繁琐的事情；所以就有了动态供给概念，也就是Dynamic Provisioning；而之前手动创建的PV都是静态供给方式；而动态供给的关键就是StorageClass，它的作用就是创建PV模版。

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: standard
# 指定存储类的供应者
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
# 指定回收策略
reclaimPolicy: Retain
```

- `provisioner`：https://www.kubernetes.org.cn/4078.html
- `parameters`：依赖不同的提供者可能有不同的参数；
- `reclaimPolicy`：回收策略同PV；
- `volumeBindingMode`：pv和pvc绑定模式：Immediate，WaitForFirstConsumer
- `allowVolumeExpansion`：就算这里设为true也不一定可以resize pv 大小；因为只对特定后端存储类型有效：https://www.dazhuanlan.com/2019/12/24/5e01dd6f36f6f/



### NFS-StorageClass

创建NFS的storageclass：https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client，

```bash
helm install nfs-sc -n nfs-sc stable/nfs-client-provisioner --set nfs.server=172.20.1.225 --set nfs.path=/data/k8s-nfs/
```

## 使用StorageClass创建卷

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: storageclassName
  resources:
    requests:
      storage: 10Gi
```

