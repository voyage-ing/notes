# 使用Kustomize管理集群资源

目前还是记录的简单的应用。

## Kustomize

Customization of kubernetes YAML configurations；

github：https://github.com/kubernetes-sigs/kustomize

Kustomize解决的痛点：

一般应用都会存在多套部署环境：开发环境、测试环境、生产环境，多套环境意味着存在多套 K8S 应用资源 YAML。而这么多套 YAML 之间只存在微小配置差异，比如镜像版本不同、Label 不同等，而这些不同环境下的YAML 经常会因为人为疏忽导致配置错误。



作者：guoweikuang
链接：https://www.jianshu.com/p/837d7ae77818
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## 目录结构

Github 中描述了一个 Demo 目录结构如下：

```
~/someApp
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── development                # 研发环境
    │   ├── cpu_count.yaml
    │   ├── kustomization.yaml
    │   └── replica_count.yaml
    └── production                 # 生产环境
        ├── cpu_count.yaml
        ├── kustomization.yaml
        └── replica_count.yaml
```

### base目录

该目录下的Yaml可以是不完整的，可以被补充、覆盖；

改目录下用来存放各个环境的公共配置，要记录在kustomization.yaml中；

```
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
```

![image-20200911111957916](https://tva1.sinaimg.cn/large/007S8ZIlly1gimjmf59ihj30q10do435.jpg)

base/kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```



### overlay目录

其实这里也可以不需要把development，production放在overlay中，也可以直接就是development，production（和base同级），只要在kustomization.yaml记录好base路径。

所以base/kustomization.yaml是必要的。

```
└── overlays
    ├── development                # 研发环境
    │   ├── cpu_count.yaml
    │   ├── kustomization.yaml
    │   └── replica_count.yaml
    └── production                 # 生产环境
        ├── cpu_count.yaml
        ├── kustomization.yaml
        └── replica_count.yaml
```

![image-20200911112103446](https://tva1.sinaimg.cn/large/007S8ZIlly1gimjnjwlg5j30pr0dbjx5.jpg)

overlays下的kustomization.yaml

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization  
bases:
  - ../base
resources:                  #添加一个新yaml文件
  - issuer.yaml
patchesStrategicMerge:      #使用新的ingress.yaml替换掉模板中的ingress  
  - yaml1.yaml
  - yaml2.yaml
```

- commonLabels，commonAnnotations会在每种资源的metadata的labels，annotations中添加对应字段。

## 使用Kustomization

检查输出的yaml文件是否是你期望的：

```bash
kubectl kustomize ./folder
```

如果符合你的修改要求，执行下面来部署资源：

```bash
 kubectl apply -k .
```

## 配置选项

### 为资源添加metadata.labels/annotations

```
commonLabels:
  app: foo
  team: Beijing
commonAnnotations:
  application: foo
  owners: Xiaoming,Damao
```

### 为资源添加名称前缀

这样添加以后，如果资源yaml里面的name是app，则最终创建资源名字是：my-app

```yaml
namePrefix: my-
```

