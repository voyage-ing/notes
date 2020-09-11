# 玩K8S不得不会的HELM

### 一、基本概念

**HELM**：类似于Linux系统下的包管理器，就像apt，yum之类的通过instarll，和uninstall来安装或者卸载服务。

其中有几个对应的概念需要了解：

- Chart： helm的软件包，可以理解为这个服务所需要的各类资源的yaml，并不包含镜像，只有镜像的地址。
- Release：在kubernetes中集群中运行的一个Chart实例，在同一个集群上，一个Chart可以安装多次，每次安装均会生成一个新的release

### 二、Helm使用

- helm for mac命令自动补全，zsh

  ```bash
  source <(helm completion zsh)
  echo "source <(helm completion bash)" >> ~/.zshrc
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

- 查看镜像仓库列表：`helm repo list`；

- 删除镜像仓库：`helm repo remove <repoName>`；

- 查询Chart：`helm search repo <appName>`；

- `helm repo update `:  Make sure we get the latest list of charts；

- `helm install stable/mysql --generate-name`： 未指定名字；

- `helm install drone --namespace production -f drone-values.yaml stable/drone`: 
  
  - Drone : 指定Release名字；
  - -- namespace：指定服务部署的命名空间；
  - -f values.yaml ：指定values.yaml代替chart中的value.yaml；
  - Stable/drone ：在线安装，从仓库里的Chart来安装；
  
- `helm install ./<folder>`：从tgz解压之后的文件夹安装；

- `helm install xxx.tgz`：其他参数与在线安装一致；

- ```bash
  # values.yaml中修改的配置选项较少时，可以使用这样。
  helm install rancher --namespace cattle-system \ 
  --set privateCA=true \ 
  --set additionalTrustedCAs=true
  ```

- `helm template <foldername，可选> -f myvalues.yaml ./mysql-0.3.5.tgz --output-dir ./` ：根据values文件渲染模版，不指定values默认是文件夹里面的values，输出yaml文件的folder；

- `helm template -f myvalues.yaml ./mysql --output-dir ./mysqlyamls` ：也可以这样；

- ```bash
  #当然也可以这样
  helm template <foldername，可选> --namespace cattle-system \
  --output-dir . \ 
  --set privateCA=true \ 
  --set additionalTrustedCAs=true
  ```

- `helm list -A` ：所有NameSpa，也可以 -n 指定ns；

- `helm pull <repo/app>` ：将Chart的tgz文件下载到本地；

- `helm lint`：在Chart的文件夹里执行，验证其格式正确；

- `helm package <appName> ` ：将Charts打包为app.tgz；

