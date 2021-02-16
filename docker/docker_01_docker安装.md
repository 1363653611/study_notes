---
title: docker 安装
date: 2021-01-12 12:14:10
tags:
  - docker
categories:
  - docker
reward: true
---

## 01 docker 安装



### 查看centos 版本号 `cat /etc/redhat-release `

### 更新yum，保证yum是最新的

- 为了方便添加软件源，支持 devicemapper 存储类型，安装如下软件包
```linux
$ sudo yum update
$ sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```
- 遇到问题：
```linux
Total download size: 4.6 M
Downloading packages:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
  File "/usr/libexec/urlgrabber-ext-down", line 28
    except OSError, e:
                  ^
SyntaxError: invalid syntax
  File "/usr/libexec/urlgrabber-ext-down", line 28
    except OSError, e:
                  ^
SyntaxError: invalid syntax
```
- 解决方案：
```lunix
$ yum provides '*/applydeltarpm'  
$ yum install deltarpm -y
```
- 执行 `yum install deltarpm -y`报错
```lunix
Downloading packages:
  File "/usr/libexec/urlgrabber-ext-down", line 28
    except OSError, e:
                  ^
SyntaxError: invalid syntax
```
- 原因： python 更改到 python3 后，`urlgrabber-ext-down`软链引用失效引起的
```lunix
$ whereis urlgrabber-ext-down
$ vim /usr/libexec/urlgrabber-ext-down
# 修改第一行的#! /usr/bin/python 为 #! /usr/bin/python2
```

### 添加 yum 软件源
```lunix
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

### 安装 Docker
```lunix
$ sudo yum update
$ sudo yum install docker-ce
```
- 报错：
```lunix
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
No package docker-ce available.
Error: Nothing to do
```
- 解决方案：
```lunix
# 卸载老版本的 docker 及其相关依赖
sudo yum remove docker docker-common container-selinux docker-selinux docker-engine
# 安装 yum-utils，它提供了 yum-config-manager，可用来管理yum源
sudo yum install -y yum-utils
# 添加yum源
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 更新索引
sudo yum makecache fast
# 安装 docker-ce
sudo yum install docker-ce
```

### 启动 docker
- 如果想添加到开机启动：`sudo systemctl enable docker`
- 启动 docker 服务：`sudo systemctl start docker`

### 验证是否安装成功 `sudo docker info`

### 更新 Docker CE `sudo yum update docker-ce`
### 卸载 Docker CE `$ sudo yum remove docker-ce`
### 删除本地文件 `$ sudo rm -rf /var/lib/docker`
- 注意，docker 的本地文件，包括镜像(images), 容器(containers), 存储卷(volumes)等，都需要手工删除。默认目录存储在 /var/lib/docker。


## 安装 docker-compose
```lunix
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```
