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

命令创建简单的configmap

```yaml
kubectl create configmap my-config --from-literal=key1=config1
```

- `--from-literal`是命令的参数，后面的才是配置的key-value；

多个参数：

```yaml
kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2
```

从字面量创建参数，也可以从文件，文件夹等创建configmap，可以通过命令：`kubectl create configmap -h` 查看；

yaml文件创建

configmap的yaml文件比较简单，data下面就是一个一个的条目；

关于`|`管道符的含义，点击[此处](../0Other/Yaml.md)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cfg
  namespace: default
data:
  cache_host: memcached-gcxt
  cache_port: "11211"
  cache_prefix: gcxt
  my.cnf: |
    [mysqld]
    log-bin = mysql-bin
  app.properties: |
    property.1 = value-1
 property.2 = value-2
 property.3 = value-3
```

## 使用Configmap

将configmap中的值传递给容器有三种方式；	

### 1. 容器的环境变量

> 环境变量命名不可以使用"-"

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fortune-config
data:
  sleep-interval: "25"

```

注入容器：

```yaml
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom: 
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
```

Pod运行后，容器内的INTERVAL环境变量值就是25；

### 2. 作为命令行参数

`pod.spec.containers.args`无法直接引用ConfigMap entries(条目)，可以利用configmap先初始化某个环境变量，再在参数字段中引用；

```yaml
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom: 
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
   # ！！！
   args: ["$(INTERVAL)"]   
```

### 3. 将configmap条目暴露为文件

Env和命令行参数传值仅适用于变量值较短的场景，但configmap中可以包含完整的配置文件，如下所示，可以借助于configmap volume；

a.json

```json
server {
    listen              80;
    server_name         www.kubia-example.com;

    gzip on;
    gzip_types text/plain application/xml;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

}
```

用命令创建configmap：

```bash
kubectl create configmap fortune-config --from-file=a.json --from-literal=sleep-interval=25
```

configmap demo

```yaml
apiVersion: v1
data:
  a.json: |
    server {
        listen              80;
        server_name         www.kubia-example.com;

        gzip on;
        gzip_types text/plain application/xml;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

    }
  sleep-interval: "25"
kind: ConfigMap
```

> 关于此处`|`管道符的含义，点击[这里](../0Other/Yaml.md)

Usag：使用configMap volume挂载到容器的`/etc/nginx/conf.d`文件夹下，configmap里的每个条目会自动转换为该文件夹下的文件；

对于这个demo文件夹下有两个文件：a .json、sleep-interval

```
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: fortune-config
```

这种方式的问题时：如果这个容器只需要条目1，但这样会所有条目都暴露出来，存在安全隐患；所以应该只暴露容器需要的条目；

还是针对上面的configmap fortune-config，使用volume的items属性：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: fortune-config
      items:              # 使用iterms属性
      - key: a.json				# configmap条目的key
        path: gzip.conf   # 条目的value被存在gzip.conf文件中
```

此时/etc/nginx/conf.d文件夹下仅有gzip.conf这个文件，内容是a .json；对于没有加入到items的其他条目，你可以环境变量，或者命令行参数继续引入；

**configmap独立条目作为文件被挂载且不覆盖容器内原有文件夹里的原内容：**

```yaml
spec:
    containers:
    - name: php
      image: php:7.0-apache
      volumeMounts:
      - mountPath: /var/www/html/index.php
        name: index
        subPath: indexaaa.php     # 
    volumes:
    - name: index
      configMap:
        name: php-index
        items:                    # 不用items也可以用subpath
        - key: index.php
          path: indexaaa.php      # configmap中的目录index.php对应的值给了相对路径 indexaaa.php，所以上面的subpath要用 相对路径indexaaa.php
```

不用items也可以用subpath，只要是挂载文件或者文件夹到容器里的已经存在的目录下就可以用subpath不对原有的造成影响。

### 设置挂载的配置文件权限

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config                    # 
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: config
      mountPath: /tmp/whole-fortune-config-volume
      readOnly: true
  volumes:
  - name: html
    emptyDir: {}
  - name: config                     #
    configMap:
      name: fortune-config
      defaultMode: 0660              # rw- rw- ---
```

> 四位权限，一般只考虑后三位；详细了解：https://blog.csdn.net/qq_33472414/article/details/92803165?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~all~sobaiduend~default-1-92803165.nonecase&utm_term=linux%E6%9D%83%E9%99%90%E6%95%B0%E5%AD%97%E8%A1%A8%E7%A4%BA4%E4%BD%8D&spm=1000.2123.3001.4430

### 在Pod中引用不存在的Configmap

创建Pod时，configmap不存在，引用了不存在的configmap的容器会启动失败，其他容器能正常启动；

可以标记Configmap引用是可选的：`configMapKeyRef.optional: true`；即便该configmap引用不存在也可以正常启动容器；

### Configmap热更新

Configmap热更新效果是：更新configmap只用，注入到容器内部的配置变动；但热更新是有前提的：

- **注入环境变量，或者通过subPath挂载的文件都不能动态更新**，只有通过**目录**挂载的configmap才具有热更新功能；

Configmap热更新原理 https://github.com/QingyaFan/container-cloud/issues/2