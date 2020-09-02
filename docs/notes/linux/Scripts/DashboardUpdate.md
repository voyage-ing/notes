### 快速只升级dashboard页面的脚本

使用此脚本之前，

1. 需要从remote同步最新代码
2. chmod +x updateDashboard.sh

```shell
#!/bin/bash
set -x
chmod +x build-in-docker.sh

if [ ! -d "./new_dashboard" ];then
	echo "qvm-web not build"
else
	echo "qvm already build, will re-build"
	rm -rf release
fi

./build-in-docker.sh .cn

mv release new_dashboard
# shell脚本中等号两边不能有空余的空格
podName=$(kubectl get pods -n qvm -o name | cut -d / -f 2)
if [ $? -ne 0 ]; then
	echo "fail to get qvm-pod-name"
	exit 1
else
	echo "successfully get qvm-pod-name"
fi

kubectl cp new_dashboard -n qvm $podName:/qvm

# for security：manual bak web/dashbard, 
# then: mv new_dashboard web/dashboard,
kubectl exec -it -n qvm $podName -- /bin/sh
```

- shell脚本中等号两边不能有空余的空格。
- [ -d "folder_path"] 判断文件夹是否存在。
- [ -f "file_path" ] 判断文件是否存在。
- $? 获取上一条命令的执行状态，[ $? -ne 0 ] 相当于 $? != 0

