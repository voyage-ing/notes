# Volumes

本节学习对象：`kubectl explain pod.spec.volumes`、`pod.spec.containers.image.volumeMounts`

## 介绍Volumes

容器内部也有自己的空间，但这里面保存的数据会在容器重启后就没了；所以为了保证容器重新启动时，数据保存不丢失，可以使用Volume挂载到pod上；另外，如果一个Pod中有多个容器，那么这个卷可以同时被所有的容器使用。

多容器的Pod中，容器之间无法互相访问彼此里面存的东西，所以可以用Volume来实现。

使用Volume首先要弄清楚：`.spec.volumes`和`.spec.containers.image.volumeMounts`

```yaml
spec:
  containers:
  - image: demoimage:latest
    name: containername
    volumeMounts:
    - name: thisVolumeName      # 和下面保持一致
      mountPath: /data          # 挂载在容器内的路径
      readOnly: true
  volumes:
  - name: thisVolumeName        # 保持一致
    emptyDir: {}                # 一种volume类型
```

> - `.spec.volumes.name`和`.spec.containers.image.volumeMounts.name`这样就可以将volume挂载到容器的对应位置；
> - 挂载点路径不存在的话是会自动创建的，而且可以设置挂载点权限`readOnly: true`;

当我设置`readOnly: true`，在容器中看挂载文件夹的权限是777，但尝试写入时：

```yaml
# touch aaa
touch: aaa: Read-only file system
```

## Volume重要参数

持续更新ing

### subPath

挂载到一个容器里已有的文件夹，如挂载volume到容器的/etc下，那么/etc下的所有原有文件都会被覆盖；

我们只是想把某少量文件，放到容器内原有的文件夹里，不对原有文件更改，

1. K8s提供了 `volumeMounts.subPath` 属性用于挂在单个文件而不是整个目录。

```yaml
spec:
    containers:
    - name: php
      image: php:7.0-apache
      volumeMounts:
      - mountPath: /var/www/html/index.php
        name: index
        subPath: indexaaa.php    
    volumes:
    - name: index
      configMap:
        name: php-index
        items:
        - key: index.php
          path: indexaaa.php      # configmap中的目录index.php对应的值给了相对路径 indexaaa.php，所以上面的subpath要用 相对路径indexaaa.php
```

2. 用subpath挂载文件夹到容器内已存在文件夹里

```yaml
spec:
    containers:
    - name: mysql
      image: mysql
      volumeMounts:
      - mountPath: /var/lib/mysql
        name: site-data
        subPath: mysql               # /var/lib/mysql/mysql
    - name: php
      image: php
      volumeMounts:
      - mountPath: /var/www/html
        name: site-data
        subPath: html                # 
    volumes:
    - name: site-data
      persistentVolumeClaim: xxx
```



## Volume的类型

目标对象：`kubectl explain pod.spec.volumes`

volume有太多类型，会详细介绍一些，官网有每一种Volume的具体使用方式 https://v1-18.docs.kubernetes.io/zh/docs/concepts/storage/volumes/：

- [emptyDir](#emptyDir)
- gitRepo
- [hostPath](#hostpath)
- [nfs](#nfs)
- ...

#### <a id="emptyDir">EmptyDir</a>

emptyDir卷对于在同一个pod中运行的容器之间共享文件特别有用。但是它用于将数据临时写入磁盘，当删除pod时卷的数据就会丢失。

使用emptyDir

```yaml
spec:
  containers:
  - image: luksa/fortune
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  volumes:
  - name: html
    emptyDir: {}
```

使用emptyDir创建的volume实际是在节点磁盘上创建的，我们可以将这个暂时存在的volume（tmfs）创建在内存上：

```yaml
  volumes:
  - name: html
    emptyDir: {}
      medium: Memory
```

#### <a id="hostpath">HostPath</a>：访问节点主机上的文件

HostPath卷需要和节点绑定，hostPath中的路径是Pod创建节点的绝对路径；

Pod删除后该路径下的数据不会被删除；

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  nodeSelector: 
    kubernetes.io/hostname: nodename
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
    hostPath:
      path: /home/rancher/test
```

<a id="nfs">NFS</a>

这个和NFS的StorageClass不同，这种会将nfs的整个资源池挂载在pod里，而不是在里面创建一个文件夹给pod使用的这种形式。

```yaml
spec:
    containers:
    - name: php
      image: php:7.0-apache
      volumeMounts:
      - mountPath: /var/www/html/index.php
        name: index
        subPath: index.php
```

