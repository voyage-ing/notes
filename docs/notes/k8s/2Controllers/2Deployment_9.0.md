

















kubectl -n qvm rollout restart deployment qvm

​    imagePullPolicy: IfNotPresent



imagePullPolicy
Always
总是拉取 pull

imagePullPolicy: Always
1
IfNotPresent
默认值,本地有则使用本地镜像,不拉取

imagePullPolicy: IfNotPresent
1
Never
只使用本地镜像，从不拉取

imagePullPolicy: Never



本地镜像并不是指 registry.k3s 而说的是 ctr  ， ctr images 中的镜像



​	



删 terminating的ns 



### 存在 Finalizers

k8s 资源的 metadata 里如果存在 `finalizers`，那么该资源一般是由某进程创建的，并且在其创建的资源的 metadata 里的 `finalizers` 加了一个它的标识，这意味着这个资源被删除时需要由创建资源的进程来做删除前的清理，清理完了它需要将标识从该资源的 `finalizers` 中移除，然后才会最终彻底删除资源。比如 Rancher 创建的一些资源就会写入 `finalizers` 标识。

处理建议：`kubectl edit` 手动编辑资源定义，删掉 `finalizers`，这时再看下资源，就会发现已经删掉了