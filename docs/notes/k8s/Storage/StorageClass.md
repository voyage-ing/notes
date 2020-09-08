# StorageClass

[TOC]

https://kubernetes.io/zh/docs/concepts/storage/storage-classes/





当然在部署`nfs-client`之前，我们需要先成功安装上 nfs 服务器

： https://blog.csdn.net/dengyadeng/article/details/79549632



Provisioner 相当于 nfc-client 这一类似的东西

https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client





[root@k8s-master1 nfs]# cat class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
archiveOnDelete: "false"   
这个参数可以设置为false和true.
archiveOnDelete字面意思为删除时是否存档,false表示不存档,即删除数据,true表示存档,即重命名路径.
————————————————
版权声明：本文为CSDN博主「王树民」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/wangshuminjava/article/details/105973318