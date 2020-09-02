# Centos7 Samba配置及使用

[TOC]

## Samba服务端配置

```bash
systemctl stop firewalld	# 停止
systemctl mask firewalld	# 禁用

vi /etc/selinux/config	# 修改SELINUX=disabled
setenforce 0

yum install -y samba samba-client
```

### 1. 无密访问

​	`vi /etc/samba/smb.conf`

- 修改[global]

```bash
[global]
	workgroup = SAMBA
	security = user

	#passdb backend = tdbsam
	map to guest = bad user

	printing = cups
	printcap name = cups
	load printers = yes
	cups options = raw
```

- 添加[share]，可以自定义名字；path对应的路径需要创建，权限为777.

```bash
[share]
        comment = share directories
        path = /share
        public = yes
        browseable = yes
        writable = yes
        guest ok = yes
        create mask = 0777
        directory mask = 0775
        guest ok = yes
```

- 启动

```bash
service smb start
/bin/systemctl enable smb.service
service smb status
```

	>使用无密的samba服务器登陆是，提示需要输入密码，直接回车即可。

## Samba-client使用

首先安装：

```bash
yum install samba-client -y
```

使用：`1.1.1.1`需要修改为你对应的Samba server的ip。

- `smbclient -L 1.1.1.1`
- `smbclient //1.1.1.1/<sharedname>`

  登陆smb命令行后：

- `get file0 file1`：下载，同时更改名字。
- `get file0`

