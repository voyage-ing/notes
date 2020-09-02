---

---

# Velero集群迁移

[TOC]



## Velero基本介绍

官方文档：https://velero.io/docs/v1.4/

基本工作原理：

不管需求是实现什么，比如：集群迁移、恢复、备份，其核心都是通过velero client CLI创建一个backup，然后迁移和恢复等操作都是需要这个backup来完成的。

创建一个backup，`velero backup create test-backup`：

![image-20200720160432164](https://tva1.sinaimg.cn/large/007S8ZIlly1ggxi0810w5j31560ckdir.jpg)

1. Velero client 调用Kubernetes API服务器以创建Backup。
2. BackupController检测到新的backup，并验证。
3. BackupController开始backup，通过请求ApiServer获取资源来收集数据以进行备份。
4. BackupController将要备份的数据上传到一个对象存储服务器，如AMS S3。
5. 默认情况下，`velero backup create`会生产每一个PV的磁盘快照。您可以通过指定其他参数来调整快照。运行`velero backup create --help`以查看可用的参数。可以使用选项禁用快照`--snapshot-volumes=false`。

## 安装需要的工具

### 安装对象存储服务器：Minio

Velero支持的storage providers：https://velero.io/docs/v1.4/supported-providers/

这里使用本地安装的对象存储服务器，Minio

安装的Minio需要能被两个集群(集群迁移，一个到另外一个)，都能访问到。



## 安装Velero Client

Velero Client就是命令行工具，安装版本应该是v1.3.0， or later。

官方提供了多种安装方式：https://velero.io/docs/master/basic-install/

## 安装Velero Server





## 使用Velero

首先需要明确一点是：不管需求是什么，比如：集群迁移、恢复、备份，其核心都是通过backup实现的。灾难恢复是如果出现意外，那么从备份的backup恢复这个集群，而迁移的过程是使用当前集群的backup来在另外一个集群恢复。

## Velero常用命令

### 备份Backup

`velero backup get ` ：查看已备份的

`velero backup create <backupname>`：创建一个backup包含所有资源

`velero backup create <backupname> --include-namespaces ns1,ns2`：为ns1，ns2命名空间下的资源备份

`velero backup create <backupname> --exclude-namespaces ns1,ns2`：排除掉ns1，ns2的命名空间，创建备份

`velero backup create <backupname> --include-resources resource1,resource2`：为指定资源备份

`velero backup create <backupname> --exclude-resources resource1,resource2``：不备份指定资源

`--storage-location <localpath>`：将创建的备份保存到本地路径下

`-l, --selector`：通过指定label来匹配要back up的资源

除此以外还包括：delete、describe、logs

### 恢复Restore

`velero restore get`：查看已经restore的资源

`vel		ero restore create restore-1 --from-backup backup-1`：从backup-1恢复

`velero restore create --from-backup backup-2 --include-resources persistentvolumeclaims,persistentvolumes`：仅恢复指定资源，同样使用`--exclude-resources`：不恢复某资源

` velero restore create --from-schedule schedule-1`：从创建的schedule恢复

除此以外还包括：delete、describe、logs

### Schedule定时备份

Schedule是针对backup的，是独立于backup之外的一种资源，但他本身也是一个backup只不过是具有了定时的功能，符合Cron规则。

`velero create schedule NAME --schedule="0 */6 * * *"`：每6小时自动备份一次

`velero create schedule NAME --schedule="@every 24h" --include-namespaces web`：因为schedule也是一种backup，所以创建backup指定的参数这里也都可以使用

除此以外还包括：delete、describe、logs



介绍：

Velero 可以帮助你：

- 对集群进行备份并在丢失的情况下进行恢复。
- 将集群资源迁移到其他集群。
- 将生产集群复制到开发和测试集群。

Velero 包括：

- 在集群上运行的服务端
- 本地的CLI客户端



![image-20200720093619214](https://tva1.sinaimg.cn/large/007S8ZIlly1ggx6s91xnkj30rq0bcwfy.jpg)





推荐用这个安装：https://velero.io/docs/master/contributions/minio/

Velero v1.4.0下面两线之间是过程，结论是 两个集群里安装下面这个，参考的上面的这个url：

```
velero install  \
--provider aws  \
--plugins velero/velero-plugin-for-aws:v1.0.0 \
--kubeconfig /etc/rancher/k3s/k3s.yaml \
--bucket velero \
--secret-file ./credentials-velero  \
--use-volume-snapshots=false  \
--backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.lab3.cn \
--use-restic \
--wait\
```

---

运行安装命令：

```bash
velero install \
--image registry.cn-hangzhou.aliyuncs.com/acs/velero:latest  \
--provider aws \
--bucket velero \
--namespace velero \
--secret-file ./credentials-velero \
--velero-pod-cpu-request 200m \
--velero-pod-mem-request 200Mi \
--velero-pod-cpu-limit 200m \
--velero-pod-mem-limit 200Mi \
--use-volume-snapshots=false \
--use-restic \
--restic-pod-cpu-request 200m \
--restic-pod-mem-request 200Mi \
--restic-pod-cpu-limit 200m \
--restic-pod-mem-limit 200Mi \
--backup-location-config region=minio,s3ForcePathStyle="false",s3Url=http://127.0.0.1:30464
```

出现错误：

 An error occurred: --plugins flag is required

需要添加一个插件：

```
velero plugin add velero/velero-plugin-for-aws:v1.0.0
```

- ```
  An error occurred: deployments.apps "velero" not found
  ```

  

尝试下面这个 ok：

```
velero install \
--plugins velero/velero-plugin-for-aws:v1.0.0 \
--image registry.cn-hangzhou.aliyuncs.com/acs/velero:latest  \
--provider aws \
--bucket velero \
--namespace velero \
--secret-file ./credentials-velero \
--velero-pod-cpu-request 200m \
--velero-pod-mem-request 200Mi \
--velero-pod-cpu-limit 200m \
--velero-pod-mem-limit 200Mi \
--use-volume-snapshots=false \
--use-restic \
--restic-pod-cpu-request 200m \
--restic-pod-mem-request 200Mi \
--restic-pod-cpu-limit 200m \
--restic-pod-mem-limit 200Mi \
--backup-location-config region=minio,s3ForcePathStyle="false",s3Url=http://127.0.0.1:30464
```

删除安装的：

​	![image-20200720111512493](https://tva1.sinaimg.cn/large/007S8ZIlly1ggx9n4t1q4j30r006f0tj.jpg)

```
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
```

下一个出现的错误：

```
An error occurred: unknown flag: --feature
```

暂时解决：https://velero.io/docs/master/customize-installation/

用disable --feature来解决：

```
$ kubectl -n velero edit deploy/velero
$ kubectl -n velero edit daemonset/restic
```

下一个错误出现：

```
An error occurred: unable to register plugin (kind=VolumeSnapshotter, name=velero.io/aws, command=/plugins/velero-plugin-for-aws) because another plugin is already registered for this kind and name (command=/velero)
```

---



