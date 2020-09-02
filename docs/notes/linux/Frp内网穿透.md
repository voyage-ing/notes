# Frp内网穿透

[TOC]

软件地址：[https://github.com/fatedier/frp](https://github.com/fatedier/frp)

中文官方文档：[https://github.com/fatedier/frp/blob/master/README_zh.md](https://github.com/fatedier/frp/blob/master/README_zh.md)

若无特别说明，公网服务器的配置frps.ini不变：

```ini
[common]
bind_port = 7000
```

启动公网服务器：`./frps -c ./frps.ini`

启动内网客户端：`./frpc -c ./frpc.ini`

客户端热加载配置文件：`./frpc reload -c ./frpc.ini`

客户端查看代理状态：`./frpc status -c ./frpc.ini`

快捷启动脚本：

- frps

```bash
cd /usr/local/frp/frp_0.33.0_linux_amd64/
nohup ./frps -c ./frps.ini >~/output 2>&1 &
cd -
```

- frpc

```bash
cd /usr/local/frp/frp_0.33.0_linux_amd64/
nohup ./frpc -c ./frpc.ini >~/output 2>&1 &
cd -
```

> 注意在公网服务器上，比如阿里云的ECS上开启对应的端口规则。

## 映射内网的http或者https

### 使用域名访问

### 使用内网ip + port访问

在frcp.ini中添加：注意在阿里云服务器上添加对应端口规则。

```bash
[https]
type = tcp
local_ip = 127.0.0.1
local_port = 30000
remote_port = 30000
```



## SSH到内网多个节点

修改frpc.ini:

```ini
[common]
server_addr = <公网ip>
server_port = 7000

[ssh1]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

[ssh2]
type = tcp
local_ip = 172.20.1.225
local_port = 22
remote_port = 6001

[ssh3]
type = tcp
local_ip = 172.20.1.211
local_port = 22
remote_port = 6002


```

> ssh连接的时候，公网ip + 这里的remote_port

### 我的配置

Server：

```ini
[common]
bind_port = 7000

dashboard_port = 7500
# dashboard 用户名密码，默认都为 admin
dashboard_user = admin
dashboard_pwd = ******
enable_prometheus = true
```

Client：

```ini
[common]
server_addr = 47.93.127.15
server_port = 7000

admin_addr = 127.0.0.1
admin_port = 7400
admin_user = admin
admin_pwd = ******

[k8s-dashboard]
type = tcp
local_ip = 127.0.0.1
local_port = 30000
remote_port = 30000

[frp-client]
type = tcp
local_ip = 127.0.0.1
local_port = 7400
remote_port = 7400

[ssh1]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

[ssh2]
type = tcp
local_ip = 172.20.1.225
local_port = 22
remote_port = 6001

[ssh3]
type = tcp
local_ip = 172.20.1.211
local_port = 22
remote_port = 6002

```

