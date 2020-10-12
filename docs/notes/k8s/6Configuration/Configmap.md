# Configmap

传递配置给容器化应用程序有几种方式：

1. 嵌入应用本身；
2. 通过命令行传递参数；
3. 通过环境变量传递参数；

在k8s中无论你有没有使用configmap，以下方法均可以配置应用程序：

1. 向容器传递命令行参数：command、args；
2. 为每个容器设置自定义环境变量；
3. 通过特殊类型的卷将配置文件挂载到容器中，如：gitrepo；

**ConfigMap的主要作用:**

就是为了让镜像和配置文件解耦，以便实现镜像的可移植性和可复用性，因为一个configMap其实就是一系列配置信息的集合，将来可直接注入到Pod中的容器使用；

ConfigMap本质上就是一个键值对，值可以是定义的具体值，也可以是完整的配置文件；

应用无需读取Configmap，映射的内容是通过env或者volume的形式传递给容器，而不是直接传递给容器；

## 创建Configmap

### 命令创建简单的configmap

```yaml
kubectl create configmap my-config --from-literal=key1=config1
```

- `--from-literal`是命令的参数，后面的才是配置的key-value；

多个参数：

```yaml
kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2
```

从字面量创建参数，也可以从文件，文件夹等创建configmap，可以通过命令：`kubectl create configmap -h` 查看；



