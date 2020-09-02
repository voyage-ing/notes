# Centos7初始化和软件配置

[TOC]

不留坑，快速配置。

## CENTOS7修改镜像源

- https://www.cnblogs.com/gaodi2345/p/11214363.html

- https://mirrors.cnnic.cn/help/centos/

## SSH免密登陆

https://blog.csdn.net/qq_37392589/article/details/81058479

## Docker

docker安装

```bash
sudo yum install -y docker
```

修改docker镜像源

```bash
sudo mkdir -p /etc/docker
sudo vi /etc/docker/daemon.json
```

- daemon.json可能不存在，需要手动创建新的。

- 将以下镜像源写入daemon.json

```yaml
{
  "registry-mirrors": [
  "https://registry.docker-cn.com",
  "https://docker.mirrors.ustc.edu.cn"
  ]
}
```

- 重新加载配置文件，设置开机自启动

```bash
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
```

- 设置当前非管理员用户也可以使用docker命令，设置完重新登陆用户即可

```bash
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo systemctl restart docker
```

## Kubectl命令安装

1. ```bash
   cat <<EOF > /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
   EOF
   ```

2. ```bash
   yum install -y kubectl kubelet kubeadm
   systemctl enable kubelet
   systemctl start kubelet
   ```


## Centos7配置VNC

https://www.cnblogs.com/st-jun/p/7757707.html