# CSI: 容器存储接口Container Storage Interface

CSI 是一种 “out-of-tree” 的服务提供方式，在Kubernetes和外部存储系统之间建立一套标准的存储管理接口，通过该接口为容器提供存储服务。

In-Tree: 需要将后端存储的代码逻辑放到K8S的代码中运行。逻辑代码可能会引起与K8S其他部件之间的相互影响。

Flexvolume: 调用一个主机的可执行程序包的方式执行存储卷的挂载使用。解决了In-Tree方式的强耦合，不过命令行调用的方式，在主机安全性、部署依赖的容器化、与K8S服务之间的相互扩展性等方面存在不足。
Flexvolume运行在host 空间，不能使用rbac授权机制访问Kubernetes API，导致其功能极大的受限。

CSI: 使K8S和存储提供者之间将彻底解耦，将存储的所有的部件作为容器形式运行在K8S上。



有些东西目前还看不懂，能知道大概工作原理，参考《Kubernetes权威指南》

CSI存储组件/部署架构

![680719-20200403150347029-572617025](https://tva1.sinaimg.cn/large/007S8ZIlly1ghx1l22081j30sg0dyjv3.jpg)

CSI Controller

- 与Master通信的辅助sidecar容器。在sidecar容器内又可以包含attacher和provisioner两个容器：
  - external-attacher:	监控VolumeAttachment资源对象的变更，触发针对CSI端点的ControllerPublish和ControllerUnpublish操作。（具体实现变更：https://developer.aliyun.com/article/705626）
  - external-provisioner：监控PersistentVolumeClaim资源对象的变更，触发针对CSI端点的CreateVolume和DeleteVolume操作。
- CSI Driver存储驱动容器，由第三方存储提供商提供，需要实现上述接口：
  - 这两个容器通过本地Socket（Unix DomainSocket，UDS），并使用gPRC协议进行通信。
  - sidecar容器通过Socket调用CSI Driver容器的CSI接口，CSI Driver容器负责具体的存储卷操作。

CSI Node

CSI Node的主要功能是对主机（Node）上的Volume进行管理和操作。在Kubernetes中建议将其部署为DaemonSet，在每个Node上都运行一个Pod。

在这个Pod中部署以下两个容器：

- 与kubelet通信的辅助sidecar容器node-driver-registrar，主要功能是将存储驱动注册到kubelet中；
- CSI Driver存储驱动容器，由第三方存储提供商提供，主要功能是接收kubelet的调用，需要实现一系列与Node相关的CSI接口，例如NodePublishVolume接口（用于将Volume挂载到容器内的目标路径）、NodeUnpublishVolume接口（用于从容器中卸载Volume），等等。
- node-driver-registrar容器与kubelet通过Node主机的一个hostPath目录下的unixsocket进行通信。CSI Driver容器与kubelet通过Node主机的另一个hostPath目录下的unixsocket进行通信，同时需要将kubelet的工作目录（默认为/var/lib/kubelet）挂载给CSIDriver容器，用于为Pod进行Volume的管理操作（包括mount、umount等）。

CSI机制

https://www.cnblogs.com/itzgr/archive/2020/04/03/12626585.html#_label1_1