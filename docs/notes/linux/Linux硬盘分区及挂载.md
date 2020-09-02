# Linux硬盘分区及挂载



https://www.cnblogs.com/feiquan/archive/2018/06/24/9219447.html



查看磁盘分区file system命令：

https://www.cnblogs.com/youbiyoufang/p/7607174.html

fdisk -l 可以显示出所有挂载和未挂载的分区，但不显示文件系统类型。

**df -T 只可以查看已经挂载的分区和文件系统类型**

**parted -l 可以查看未挂载的文件系统类型，以及哪些分区尚未格式化**



\1. Create ext4 文件系统。

```
mkfs.ext4 /dev/vdb1
partprobe /dev/vdb
```



```
fdisk /dev/vdb
  202  ls
  203  lsblk
  204  mkfs.ext4 /dev/vdb1
```

