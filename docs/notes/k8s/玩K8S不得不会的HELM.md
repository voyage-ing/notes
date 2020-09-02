# 玩K8S不得不会的HELM

[TOC]



### 一、基本概念

**HELM**：类似于Linux系统下的包管理器，就像apt，yum之类的通过instarll，和uninstall来安装或者卸载服务。

其中有几个对应的概念需要了解：

- Chart： helm的软件包，可以理解为这个服务所需要的各类资源的yaml，并不包含镜像，只有镜像的地址。
- Release：在kubernetes中集群中运行的一个Chart实例，在同一个集群上，一个Chart可以安装多次，每次安装均会生成一个新的release

### 二、Helm使用

- helm for mac命令自动补全，zsh

```

```



- ```
  helm repo add {仓库名字} {仓库地址}
  ```

  ```
  # 几个常用仓库
  rancher-stable	https://releases.rancher.com/server-charts/stable
  stable        	http://mirror.azure.cn/kubernetes/charts
  aliyun        	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
  ```

- 查看镜像仓库列表：`helm repo list`
- 删除镜像仓库：`helm repo remove <repoName>`
- 查询Chart：`helm search repo <appName>`
- `helm repo update `:  Make sure we get the latest list of charts
- `helm install stable/mysql --generate-name`： 未指定名字
- `helm install drone --namespace production -f drone-values.yaml stable/drone`: 
  
  - Drone : 指定Release名字
  - -- namespace：指定服务部署的命名空间
  - -f values.yaml ：指定values.yaml代替chart中的value.yaml
  - Stable/drone ：在线安装，从仓库里的Chart来安装
- `helm install ./<folder>`：从tgz解压之后的文件夹安装

- `helm install xxx.tgz`：其他参数与在线安装一致
- `helm list -A` ：所有NameSpa，也可以 -n 指定ns
- `helm pull <repo/app>` ：将Chart的tgz文件下载到本地
- `helm lint`：在Chart的文件夹里执行，验证其格式正确
- `helm package <appName> ` ：将Charts打包为app.tgz

### 三、Charts

#### 从私有镜像仓库获取需要的镜像

- values.yaml中对应位置设置参数`pullSecret`

  ```yaml
  images:
    server:
      repository: "私有仓库Url/drone/drone"
      tag: 1.6.5
      pullPolicy: IfNotPresent
      pullSecret:	<secretName>
  ```

- templates/deployment-xxx.yaml: 

  ```yaml
  {{- if .Values.images.server.pullSecret }}				# 有的文件并没有，需要手动添加
        imagePullSecrets:
          - name: {{ .Values.images.server.pullSecret }}
  {{- end }}
        containers:
        - name: server
          image: "{{ .Values.images.server.repository }}:{{ .Values.images.server.tag }}"
          imagePullPolicy: {{ .Values.images.server.pullPolicy }}
  ```

  



