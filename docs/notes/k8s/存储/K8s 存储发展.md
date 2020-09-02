https://kubernetes.io/zh/docs/concepts/storage/volumes/

In-Tree 卷：

需要将后端存储的代码逻辑放到K8S的代码中运行。逻辑代码可能会引起与K8S其他部件之间的相互影响；这意味着它们是与 Kubernetes 的核心组件一同构建、链接、编译和交付的，并且这些插件都扩展了 Kubernetes 的核心 API。 

这意味着向 Kubernetes 添加新的存储系统（卷插件）需要将代码合并到 Kubernetes 核心代码库中，如：ConfigMap，Secret。

Out-of-Tree 卷 ：	

包括容器存储接口（CSI）和 FlexVolume

FlexVolume 

是一个自 1.2 版本（在 CSI 之前）以来在 Kubernetes 中一直存在的 out-of-tree 插件接口。 它使用基于 exec 的模型来与驱动程序对接。 用户必须在每个节点（在某些情况下是主节点）上的预定义卷插件路径中安装 FlexVolume 驱动程序可执行文件。

Flexvolume运行在host 空间，不能使用rbac授权机制访问Kubernetes API，导致其功能极大的受限。



