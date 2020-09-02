# Longhorn分布式存储

[TOC]

**Longhorn Manager** ：容器在Longhorn群集中的每个主机上运行，是以DaemonSet（简单来说就是集群的每个节点都运行一个pod） 的方式处理来自UI或Flex Volume和CSI Kubernetes插件的API调用。

Longhorn Manager创建卷时，它会在该卷连接到的主机以及将放置副本的主机上创建一个控制器容器。副本应放在单独的主机上，以确保最大的可用性。

longhorn学习。https://www.bilibili.com/video/BV1cK411W7oV



## Longhorn部署安装

磁盘要求：ext4或者xfs文件系统

安装方式推荐：

1. 通过Rancher应用商店安装

2. Helm3安装Longhorn

建议通过这两种方式安装，安装过程比较简单，单我遇到了几个问题，希望能解决你的问题，如何和我一样的话。

问题一：

Longhorn-driver-deployer一直重启，查看容器日志，如下；这是因为Kubelet Root Director这个参数如果不设置的话，默认情况下它会自动探测，但不知道什么原因自动探测失败，那就手动指定下就好了。

```bash
time="2020-08-21T02:28:59Z" level=debug msg="Deploying CSI driver"
time="2020-08-21T02:28:59Z" level=debug msg="proc cmdline detection pod discover-proc-kubelet-cmdline in phase: Pending"
time="2020-08-21T02:29:00Z" level=debug msg="proc cmdline detection pod discover-proc-kubelet-cmdline in phase: Pending"
time="2020-08-21T02:29:02Z" level=debug msg="proc cmdline detection pod discover-proc-kubelet-cmdline in phase: Pending"
time="2020-08-21T02:29:03Z" level=debug msg="proc cmdline detection pod discover-proc-kubelet-cmdline in phase: Pending"
time="2020-08-21T02:29:04Z" level=warning msg="Proc not found: kubelet"
time="2020-08-21T02:29:04Z" level=debug msg="proc cmdline detection pod discover-proc-k3s-cmdline in phase: Pending"
time="2020-08-21T02:29:05Z" level=debug msg="proc cmdline detection pod discover-proc-k3s-cmdline in phase: Pending"
time="2020-08-21T02:29:06Z" level=debug msg="proc cmdline detection pod discover-proc-k3s-cmdline in phase: Pending"
time="2020-08-21T02:29:07Z" level=debug msg="proc cmdline detection pod discover-proc-k3s-cmdline in phase: Running"
time="2020-08-21T02:29:08Z" level=warning msg="Proc not found: k3s"
time="2020-08-21T02:29:09Z" level=error msg="failed to get arg root-dir. Need to specify \"--kubelet-root-dir\" in your Longhorn deployment yaml.: failed to get kubelet root dir, no related proc for root-dir detection, error out"
time="2020-08-21T02:29:09Z" level=fatal msg="Error deploying driver: failed to get arg root-dir. Need to specify \"--kubelet-root-dir\" in your Longhorn deployment yaml.: failed to get kubelet root dir, no related proc for root-dir detection, error out"
```

## Longhorn资源介绍

```
kubectl get crd | grep longhorn.io
```

### Longhorn Driver Deployer

负责相关CSI plugins部署，如：csi-attacher, csi-provisioner, csi-resizer

![image-20200821105205845](https://tva1.sinaimg.cn/large/007S8ZIlly1ghy8szkc7qj30um0emgqc.jpg)

这些镜像都用的k8s官方的CSI镜像，这些插件longhorn都是使用原生的没修改过的

![image-20200821105346336](https://tva1.sinaimg.cn/large/007S8ZIlly1ghy8uoxcorj30oe047wf5.jpg)

### Longhorn Manager

- 以DeamontSet方式部署的；
- 提供Longhorn API供Longhorn UI调用；
  - 启动多个Controller，如下图详情；

![image-20200821105904537](https://tva1.sinaimg.cn/large/007S8ZIlly1ghy907iuqyj30n605r75q.jpg)