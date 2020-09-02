## Linux Commands

[TOC]



### **curl **

| Curl命令常用参数                 |                                          |
| -------------------------------- | :--------------------------------------- |
| -A：--user-agent \<string>       | 设置用户代理发送给服务器                 |
| -b：--cookie \<name=string/file> | cookie字符串或文件读取位置               |
| -c：--cookie-jar \<file>         | 操作结束后把cookie写入到这个文件中       |
| -C：--continue-at \<offset>      | 断点续转                                 |
| -D：--dump-header \<file>        | 把header信息写入到该文件中               |
| -e：--referer                    | 来源网址                                 |
| -f：--fail                       | 连接失败时不显示http错误                 |
| -o：--output                     | **把输出写到该文件中**                   |
| -O：--remote-name                | 把输出写到该文件中，保留远程文件的文件名 |
| -r：--range \<range>             | 检索来自HTTP/1.1或FTP服务器字节范围      |
| -s：--silent                     | 静音模式。不输出任何东西                 |
| -T：--upload-file \<file>        | 上传文件                                 |
| -u：--user <user[:password]>     | 设置服务器的用户和密码                   |
| -v：--verbose                    | 展示更多服务器的响应内容                 |
| -w：--write-out [format]         | **完成后输出什么**                       |
| -x：--proxy <host[:port]>        | 在给定的端口上使用HTTP代理               |
| -X：                             | 简单理解是POST/GET/等请求方法            |
| -#：--progress-bar               | 进度条显示当前的传送状态                 |

Example：

Json数据登陆保存Cookie：

```bash
curl -v -c cookie -X POST -H "Accept:application/json" --data '{"passtoken":"********", "username": "********", "method": "pass" }' https://vm.tdology.com/api/token
```

使用获取到的Cookie来请求：

```bash
 curl -X GET -b cookie https://vm.tdology.com/api/projects
```

使用Cookie并POST传参数：

```bash
curl -v -b cookie -X POST --data '{"bond":"eth1","vlans":["0","100"],"limits":{"cpu":"1","memory":"512"}}' http://10.43.115.207:8988/api/projects/hang
```

### nc	待学习

### nmap	待学习

### tee [OPTION]... [FILE]...	

tee：将输出到控制台的内容保存到另外的文件，常用作命令执行的输出需要保存到文件中。

简单的：`tee <filename>`，如果这个文件存在，则先将文件里面的内容全部清除，然后再输入内容。

追加：`ping baidu.com | tee -a <filename>`

输出到多个文件：`ping baidu.com | tee ping.log ping-baidu.log`

**提高写入文件权限**：具体使用场景，vi需要管理员权限的file时，保存提示没权限此时只需要使用`w !sudo tee %`，之后会提示你输入密码，然后就保存了。

> "%"代表当前文件，w!{cmd}，让vim执行一个外部命令{cmd}，然后把当前缓冲区的内容从stdin传入。
>
> **注！！！， 千万不要把%号写成*号，*是指当前路径下的所有文件。**

### Nohup：关闭终端不影响运行程序

```bash
nohup ./frpc -c ./frpc.ini >~/output 2>&1 &
```

