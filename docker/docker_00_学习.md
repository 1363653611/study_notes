---
title: Docker 学习
date: 2021-01-11 12:14:10
tags:
  - docker
categories:
  - docker
reward: true
---

# Docker

![image-20200606203315597](Docker.assets/image-20200606203315597.png)

## 参考资料

官方文档：https://docs.docker.com/docker-for-windows/ 

【官方文档超级详细】

仓库地址：https://hub.docker.com/

【发布到仓库，git pull push】

b站教程：https://www.bilibili.com/video/BV1og4y1q7M4?

【这个教程非常简洁！且深入！基于企业应用场景！推荐！以下笔记都基于该课程】

## 前期基础

linux基本命令，类似cd，mkdir等



## Docker概述

### Docker为什么会出现

一款产品，开发和上线两套环境，应用环境配置费时费力，而且容易出问题

尤其对于机器学习和深度学习的库更是如此，很可能存在版本问题、底层依赖冲突问题

所以发布项目时，不只是一套代码过去，而是代码+环境整体打包过去

所谓开发即运维，保证系统稳定性，提高部署效率

使用Docker后的流程：

开发：建立模型--环境--打包带上环境，即镜像--放到Docker仓库

部署：下载Docker中的镜像，直接运行即可



Docker的思想来自于集装箱，集装箱，对环境进行隔离

Docker通过隔离机制，可以将服务器利用到极致。

### Docker的历史

2010年，几个搞IT的人，在美国成立一家公司`dotCloud`

做一些pass的云计算服务

他们将自己的容器化技术命名为Docker

Docker基于Go语言开发

Docker刚刚诞生的时候，没有引起行业的注意，dotCloud活不下去

然后他们决定开源

2013年，创始人将Docker开源，不开则以，一开惊人，刚开源的时候，每个月都会更新一个版本

2014年4月9日，Docker 1.0发布

### 容器vs虚拟机

在容器技术出来之前，用的是虚拟机技术

#### 虚拟机原理示意图

![image-20200606205436434](Docker.assets/image-20200606205436434.png)

缺点：

1. 资源占用多
2. 冗余步骤多
3. 启动很慢

#### 容器化技术示意图

不是模拟的完整的操作系统

![image-20200606205739655](Docker.assets/image-20200606205739655.png)

#### 二者对比

比较虚拟机和Docker的不同

|          | 传统虚拟机               | Docker        |
| -------- | ------------------------ | ------------- |
| 虚拟内容 | 硬件+完整的操作系统+软件 | APP+LIB       |
| 大小     | 笨重，通常几个G          | 轻便几个M或KB |
| 启动速度 | 慢，分钟级               | 快，秒级      |
|          |                          |               |

## Docker安装

### Docker的基本组成

![image-20200606212250845](Docker.assets/image-20200606212250845.png)

明确几个概念：

1. 镜像(image)：docker镜像好比一个模板，可以通过这个模板来创建容器(container)，一个镜像可以创建多个容器，类似Python中的Class

2. 容器(container)：类似Python中通过Class创建的实例，Object；容器可以理解为一个简易的系统

3. 仓库(repository)：存放镜像的地方，

   分为共有仓库和私有仓库

   - Docker Hub：国外的

   - 阿里云：配置镜像加速

### 环境准备

我们要有一台服务器，并且可以操作它

1. Linux命令基础，购买linux阿里云的服务器
2. CentOS 7
3. 使用Xshell链接远程服务器

### 安装xshell

下载CentOS7 https://www.jianshu.com/p/a63f47e096e8

下载VMware 360软件管家下载

VMware配置虚拟机 https://blog.csdn.net/babyxue/article/details/80970526

xshell链接服务器 https://blog.csdn.net/zzy1078689276/article/details/77280814

```
[root@192 ~]# cd /
[root@192 /]# pwd
/
[root@192 /]# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
[root@192 /]# uname -r
3.10.0-1127.el7.x86_64
```

![image-20200608091950655](Docker.assets/image-20200608091950655.png)

用户名 

密码

查看ip：vmware里面输入，ip addIPr

视频书签，p602:20

https://www.bilibili.com/video/BV1og4y1q7M4?p=6

### Centos安装

https://docs.docker.com/engine/install/centos/

### 卸载旧的版本

```
# 卸载旧的版本
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

```

![image-20200608092628498](Docker.assets/image-20200608092628498.png)

### 安装基本环境



```
# 安装基本的安装包
$ sudo yum install -y yum-utils
```

!

![image-20200608093114774](Docker.assets/image-20200608093114774.png)

### 设置镜像的仓库

注意！！下载默认用国外的，太慢不要用！

用国内镜像，百度搜索，docker的阿里云镜像地址

```
# 不要用官网默认这个！
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo # 默认是国外的

# 换成下面的

$ sudo yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo # 阿里云镜像
```

![image-20200616145430166](Docker.assets/image-20200616145430166.png)

直接复制粘贴就OK了

更像软件包索引

```
yum makecache fast
```

![image-20200616150014082](Docker.assets/image-20200616150014082.png)

没有问题的话就是可以用的

### 安装docker引擎

```python
yum install docker-ce docker-ce-cli containerd.io # docker-ce 社区版 ee 企业版
```

注意这里会有几个个y/n的判断

![image-20200616150818860](Docker.assets/image-20200616150818860.png)

![image-20200616150922549](Docker.assets/image-20200616150922549.png)

要看到Complet再收手！



### docker 安装报错:

```shell
问题:
ackage containerd.io-1.2.0-3.el7.x86_64 is already installed.
Error:
 Problem: package docker-ce-3:19.03.13-3.el7.x86_64 requires containerd.io >= 1.2.2-3, but none of the providers can be installed
  - cannot install the best candidate for the job
  
解决方案:
yum install docker-ce docker-ce-cli containerd.io --nobest

```



### 启动Docker

```
systemctl start docker # 代表启动成功
```

```
docker version
```

```
Client: Docker Engine - Community
 Version:           19.03.11
 API version:       1.40
 Go version:        go1.13.10
 Git commit:        42e35e61f3
 Built:             Mon Jun  1 09:13:48 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.11
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.10
  Git commit:       42e35e61f3
  Built:            Mon Jun  1 09:12:26 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683

```

```
docker run hello-world
```

![image-20200616151641013](Docker.assets/image-20200616151641013.png)

中间一堆是签名信息

run的运行流程图

![image-20200616161441669](Docker.assets/image-20200616161441669.png)

查看下载的镜像

```
docker images
```

![image-20200616151913277](Docker.assets/image-20200616151913277.png)

### 卸载Docker

```
# 卸载依赖
yum remove docker-ce docker-ce-cli containerd.io

# 删除资源
rm -rf /var/lib/docker # docker 的默认工作路径

```

### 阿里云镜像加速

支付宝扫码登录，短信验证，确认授权

我有两个问题
1. 阿里云镜像加速必须配置嘛？

   >哎呦我去: 加速快
   >
   >哎呦我去: 要是翻墙就无所谓了

2. 这个阿里云必须要买嘛，买哪个，我看阿里云好多产品

   >哎呦我去:不需要买
   >
   >哎呦我去:免费的
   >
   >哎呦我去:阿里云搜索容器服务
   >
   >哎呦我去:有一个镜像加速

   

3. 这个地址是哪来的呀

操作

![image-20200616154429105](Docker.assets/image-20200616154429105.png)

![image-20200616154455964](Docker.assets/image-20200616154455964.png)

控制台搜索 容器镜像服务

![image-20200616155201285](Docker.assets/image-20200616155201285.png)



找到加速地址

![image-20200616155649476](Docker.assets/image-20200616155649476.png)

```
sudo mkdir -p /etc/docker # 创建一个陌路
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://uyfgafsw.mirror.aliyuncs.com"]
}
EOF # 编写配置文件

sudo systemctl daemon-reload # 重启服务
sudo systemctl restart docker # 重启docker
```

![image-20200616160315298](Docker.assets/image-20200616160315298.png)



[在线画图软件ProcessOn](https://www.processon.com/)



[服务器及购买相关介绍](https://www.bilibili.com/video/BV177411K7bH)

## 底层原理

Docker是怎么工作的？

Docker是一个Client-Server结构的系统，Docker的守护进程在主机上。通过Socket从客户端访问！

DockerServer接受到Docker-Client的指令，

![image-20200616162107363](Docker.assets/image-20200616162107363.png)

Docker为什么比VM快？

1. Docker有着比虚拟机更少的抽象层
2. docker主要用的是宿主机的内核，vm需要Guest OS

![image-20200616162302653](Docker.assets/image-20200616162302653.png)

所以说新建一个容器的时候，docker不需要像虚拟机一样重新加载一个操作系统内核，避免引导



## Docker命令

### 帮助命令

```
docker version # 显示docker的基本信息
docker info # 系统信息，镜像和容器的数量
docker 命令 --help # 全部信息
```

[官网文档](https://docs.docker.com/reference/)

![image-20200616163338187](Docker.assets/image-20200616163338187.png)



### 镜像命令

#### docker images

查看所有本地主机上的镜像

```bash
[root@192 ~]# docker images

```

![image-20200616172056530](Docker.assets/image-20200616172056530.png)

```
# 解释
REPOSITORY  # 镜像仓库源
TAG                 # 镜像的标签
IMAGE ID           # 镜像的ID
CREATED           # 镜像的创建时间
SIZE # 镜像的大小
```

```bash
--all , -a		Show all images (default hides intermediate images) # 显示所有
--digests		Show digests
--filter , -f		Filter output based on conditions provided
--format		Pretty-print images using a Go template
--no-trunc		Don’t truncate output
--quiet , -q		Only show numeric IDs # 只显示id
```

![image-20200616172651835](Docker.assets/image-20200616172651835.png)

#### docker search

搜索仓库中的镜像，相当于网页搜索

[网页搜索](http://hub.docker.com)

![image-20200616173009473](Docker.assets/image-20200616173009473.png)

mysql

![image-20200616173050756](Docker.assets/image-20200616173050756.png)

```
docker search mysql
```

![image-20200616173308194](Docker.assets/image-20200616173308194.png)

```
docker search --help
```

![image-20200616173740981](Docker.assets/image-20200616173740981.png)

```bash
# 解释
Options:
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print search using a Go template
      --limit int       Max number of search results (default 25)
      --no-trunc        Don't truncate output

```

```
docker search mysql --filter=STARS=3000 # 搜索出Stars大于3000的
```

![image-20200616174440284](Docker.assets/image-20200616174440284.png)

【视频书签，https://www.bilibili.com/video/BV1og4y1q7M4?p=9，13:44，太热了我要缓一缓】

#### docker pull

下载镜像

```bash
docker pull mysql # 下载mysql镜像，default tag，默认最新版latest
```

```bash
[root@192 ~]# sudo systemctl daemon-reload
[root@192 ~]# sudo systemctl restart docker
[root@192 ~]# docker pull mysql
Using default tag: latest # 不写tag默认最新版
latest: Pulling from library/mysql
8559a31e96f4: Pull complete  # layer 分层下载，docker image的核心 联合文件系统
d51ce1c2e575: Pull complete 
c2344adc4858: Pull complete 
fcf3ceff18fc: Pull complete 
16da0c38dc5b: Pull complete 
b905d1797e97: Pull complete 
4b50d1c6b05c: Pull complete 
c75914a65ca2: Pull complete 
1ae8042bdd09: Pull complete 
453ac13c00a3: Pull complete 
9e680cd72f08: Pull complete 
a6b5dc864b6c: Pull complete 
Digest: sha256:8b7b328a7ff6de46ef96bcf83af048cb00a1c86282bfca0cb119c84568b4caf6#签名
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest # 真实地址

# 即
docker pull mysql
# 等价于
docker pull docker.io/library/mysql:latest

```

```bash

# 指定版本下载 
docker pull mysql:5.7
```

版本来自于官网，版本库https://hub.docker.com/_/mysql

![image-20200617094339687](Docker.assets/image-20200617094339687.png)



![image-20200617100948088](Docker.assets/image-20200617100948088.png)

```
docker images
```

此时查看镜像，可以看到新下载的两个

![image-20200617101105899](Docker.assets/image-20200617101105899.png)

#### docker rmi

remove images

```bash
# 删除一个 可以通过名称 也可以指定id -f表示删除所有
docker rmi -f 9cfcce23593a
# 删除多个 用空格分隔id
docker rmi -f id id id
# 删除所有 
docker rmi -f $(docker images -aq) # images -aq就是查所有镜像id，从而递归删除
```

![image-20200617102049613](Docker.assets/image-20200617102049613.png)



![image-20200617102126526](Docker.assets/image-20200617102126526.png)

### 容器命令

说明：有了镜像才能创建容器，linux，下载一个centos镜像来测试学习

```bash
docker pull centos
```

![image-20200617103406974](Docker.assets/image-20200617103406974.png)

#### 新建容器并启动

```shell
docker run [可选参数] image

# 参数说明
--name=“Name” # 容器名字，用于区分容器
-d 后台方式运行
-it 使用交互方式运行，进入容器查看内容
-p 指定容器的端口 如-p 8080::8080
	-p ip:主机端口：容器端口
	-p 主机端口:容器端口
	-p 容器端口
	
-p 随机指定端口
```

#### 进入退出容器

```bash
# 进入
docker run -it centos /bin/bash 
# 查看目录
ls
# 退出
exit
```

![image-20200617104004004](Docker.assets/image-20200617104004004.png)

注意这里面主机名，编程了centos的id

这里面就是一个容器，套娃啊

#### 查看运行的容器

```shell
# 查看正在运行的容器
docker ps
# 查看曾经运行的容器
docker ps -a
# 显示最近创建的容器，设置显示个数
docker ps -a - n=? 
# 只显示容器的编号
docker ps -aq
```

```shell
[root@192 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@192 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
9939864fa2e6        centos              "bin/bash"          4 minutes ago       Exited (0) 4 minutes ago                       unruffled_knuth
5f42e9930435        centos              "/bin/bash"         8 minutes ago       Exited (0) 4 minutes ago                       lucid_cannon
a89ddb393d3d        bf756fb1ae65        "/hello"            19 hours ago        Exited (0) 19 hours ago                        gracious_bhabha
[root@192 ~]# docker ps -a -n=2
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
9939864fa2e6        centos              "bin/bash"          6 minutes ago       Exited (0) 6 minutes ago                       unruffled_knuth
5f42e9930435        centos              "/bin/bash"         10 minutes ago      Exited (0) 7 minutes ago 
[root@192 ~]# docker ps -aq
9939864fa2e6
5f42e9930435
a89ddb393d3d

```

#### 退出容器

```shell
# 容器停止退出
exit
# 容器不停止退出 注意必须在英文输入法下，中文输入法不行
Ctrl + P + Q
```

```shell
[root@192 ~]# docker run -it centos /bin/bash
[root@bfcea13c40cd /]# [root@192 ~]# docker ps ##注意这里会自动给个命令，删掉
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS               NAMES
bfcea13c40cd        centos              "/bin/bash"         About a minute ago   Up About a minute                       stoic_wilson
edbd9366d959        centos              "/bin/bash"         7 minutes ago        Up 7 minutes                            affectionate_bartik
[root@192 ~]# docker exec -it edbd9366d959 /bin/bash ## 再次进入
[root@edbd9366d959 /]# exit ##停止并推出
exit

```

#### 删除容器

```shell
# 删除指定容器 不能删除正在运行的容器，如果强制删除 rm -f
docker rm 容器id
# 删除所有容器
docker rm -f $(docker ps -aq)
# 删除所有容器
docker ps -a -q|xargs docker rm
```

```shell
[root@192 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
bfcea13c40cd        centos              "/bin/bash"         29 minutes ago      Up 29 minutes                                   stoic_wilson
edbd9366d959        centos              "/bin/bash"         35 minutes ago      Up 35 minutes                                   affectionate_bartik
9939864fa2e6        centos              "bin/bash"          48 minutes ago      Exited (0) 48 minutes ago                       unruffled_knuth
5f42e9930435        centos              "/bin/bash"         52 minutes ago      Exited (0) 49 minutes ago                       lucid_cannon
a89ddb393d3d        bf756fb1ae65        "/hello"            20 hours ago        Exited (0) 20 hours ago                         gracious_bhabha
[root@192 ~]# docker rm 5f42e9930435
5f42e9930435
[root@192 ~]# docker rm edbd9366d959      # 注意正在运行的容器不能删除
Error response from daemon: You cannot remove a running container edbd9366d9596c744dd449119269b04de2f2a494e7fc471f6396bcefd94c33fe. Stop the container before attempting removal or force remove

```

```shell
[root@192 ~]# docker ps -aq # 所有容器id
bfcea13c40cd
edbd9366d959
9939864fa2e6
a89ddb393d3d
[root@192 ~]# docker rm -f $(docker ps -aq) # 全部删除
bfcea13c40cd
edbd9366d959
9939864fa2e6
a89ddb393d3d

```

#### 启动和停止容器的操作

```shell
docker start
docker restart
docker stop
docker kill
```

```shell
[root@192 ~]# docker run -it centos /bin/bash
[root@7b1a7dd10ea4 /]# exit
exit
[root@192 ~]# docker ps #查看正在运行的
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@192 ~]# docker ps -a # 查看历史运行过的
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
7b1a7dd10ea4        centos              "/bin/bash"         54 seconds ago      Exited (0) 42 seconds ago                       fervent_mirzakhani
[root@192 ~]# docker start 7b1a7dd10ea4 # 启动当前这个容器 container id 粘过 来
7b1a7dd10ea4
[root@192 ~]# docker ps # 查看当前运行容器 发现启动成功
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
7b1a7dd10ea4        centos              "/bin/bash"         2 minutes ago       Up 28 seconds                           fervent_mirzakhani
[root@192 ~]# docker stop 7b1a7dd10ea4 # 停止运行
7b1a7dd10ea4
[root@192 ~]# docker ps # 再次查看 没有这个容器了
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES


```

### 常用其他命令

【视频书签：https://www.bilibili.com/video/BV1og4y1q7M4?p=11，不知不觉搞了一上午了，按部就班学东西的感觉真好，得找时间快点刷完】

#### 后台启动docker

```shell
docker run -d 镜像名
# 用docker ps 查看的时候 发现停止了

# 后台运行，docker发现前台没有，容器启动后，发现自己没有提供服务，会立刻停止
```

```shell
Last login: Wed Jun 17 19:47:35 2020
[root@192 ~]# systemctl start docker # 关机后重启了，需要启动docker
[root@192 ~]# docker run -d centos # 运行
8ce188e5fee31c2fac93c0a405ee1a95c38dbc50cb47c35b19c0039c27558ded
[root@192 ~]# docker ps -a # 查看正在运行的
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
8ce188e5fee3        centos              "/bin/bash"         19 seconds ago      Exited (0) 18 seconds ago                       tender_dirac
7b1a7dd10ea4        centos              "/bin/bash"         8 hours ago         Exited (0) 8 hours ago                          fervent_mirzakhani

```



#### 查看日志

```shell
docker logs
docker logs -f -t --tail n 【id】

```

![image-20200617161744298](Docker.assets/image-20200617161744298.png)

```shell
[root@192 ~]# docker logs --help

Usage:	docker logs [OPTIONS] CONTAINER

Fetch the logs of a container

Options:
      --details        Show extra details provided to logs
  -f, --follow         Follow log output
      --since string   Show logs since timestamp (e.g.
                       2013-01-02T13:23:37) or relative
                       (e.g. 42m for 42 minutes)
      --tail string    Number of lines to show from the
                       end of the logs (default "all")
  -t, --timestamps     Show timestamps # 时间戳
      --until string   Show logs before a timestamp (e.g.
                       2013-01-02T13:23:37) or relative
                       (e.g. 42m for 42 minutes)

```

```shell
whiel true;do echo shenzai;sleep 
```



```shell
# 运行一个
[root@192 ~]# docker run -it centos /bin/bash

[root@c2887d35c71d /]# [root@192 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
c2887d35c71d        centos              "/bin/bash"         57 seconds ago      Up 56 seconds                           vigorous_kare

# 查看日志，由于没有运行脚本，所以啥也没显示
[root@192 ~]# docker logs -f -t --tail 10 c2887d35c71d
^C # ctrl+c退出

# 运行centos里面加个脚本
[root@192 ~]# docker run -d centos /bin/sh -c "while true;do echo shenzai;sleep 1;done"
cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388

[root@192 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
cb6d7fbc3f27        centos              "/bin/sh -c 'while t…"   7 seconds ago       Up 6 seconds                            dreamy_almeida
c2887d35c71d        centos              "/bin/bash"              3 minutes ago       Up 3 minutes                            vigorous_kare

# 查看日志 发现隔一秒打印一条
[root@192 ~]# docker logs -f -t --tail 10 cb6d7fbc3f27
2020-06-17T12:02:11.293765084Z shenzai
2020-06-17T12:02:12.297675608Z shenzai
2020-06-17T12:02:13.301845582Z shenzai
2020-06-17T12:02:14.304800996Z shenzai
2020-06-17T12:02:15.307130238Z shenzai
2020-06-17T12:02:16.310574235Z shenzai
2020-06-17T12:02:17.312946923Z shenzai
2020-06-17T12:02:18.314841295Z shenzai
2020-06-17T12:02:19.317021705Z shenzai
2020-06-17T12:02:20.319670013Z shenzai
2020-06-17T12:02:21.322651649Z shenzai
2020-06-17T12:02:22.325466918Z shenzai
2020-06-17T12:02:23.327984704Z shenzai
2020-06-17T12:02:24.329656919Z shenzai

```

#### 查看正在运行的容器信息

```shell
[root@192 ~]# docker inspect cb6d7fbc3f27
[
    {
        # 容器的完整id
        "Id": "cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388",
        
        # 创建时间
        "Created": "2020-06-17T12:00:50.706906186Z",
        
        # 脚本位置
        "Path": "/bin/sh",
        
        # 运行的脚本
        "Args": [
            "-c",
            "while true;do echo shenzai;sleep 1;done"
        ],
        "State": {
            "Status": "running", # 状态，正在运行
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1909, # 父进程id
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2020-06-17T12:00:51.093617477Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        
        # 来源镜像
        "Image": "sha256:831691599b88ad6cc2a4abbd0e89661a121aff14cfa289ad840fd3946f274f1f",
        "ResolvConfPath": "/var/lib/docker/containers/cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388/hostname",
        "HostsPath": "/var/lib/docker/containers/cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388/hosts",
        "LogPath": "/var/lib/docker/containers/cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388/cb6d7fbc3f27a064137d58282de97b97365dea2705211ebfbad642079cc1b388-json.log",
        
        
        "Name": "/dreamy_almeida",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        
        # 主机配置
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Capabilities": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "KernelMemory": 0,
            "KernelMemoryTCP": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        
        # 其他配置
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/3675586ebbd79cd72d2562a90c9380627a331c563724c0dac091f92600af4907-init/diff:/var/lib/docker/overlay2/7f79322e0f58d651a84a555dadd83d92537788172525945d3f538dd95dce336c/diff",
                "MergedDir": "/var/lib/docker/overlay2/3675586ebbd79cd72d2562a90c9380627a331c563724c0dac091f92600af4907/merged",
                "UpperDir": "/var/lib/docker/overlay2/3675586ebbd79cd72d2562a90c9380627a331c563724c0dac091f92600af4907/diff",
                "WorkDir": "/var/lib/docker/overlay2/3675586ebbd79cd72d2562a90c9380627a331c563724c0dac091f92600af4907/work"
            },
            "Name": "overlay2"
        },
        
        "Mounts": [], # 挂载
        
        # 基本配置
        "Config": {
            "Hostname": "cb6d7fbc3f27",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ], # 基本环境变量，这里没有Java
            
            # 基本命令
            "Cmd": [
                "/bin/sh",
                "-c",
                "while true;do echo shenzai;sleep 1;done"
            ],
            "Image": "centos",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20200611",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        
        # 网卡，比如现在用的是桥接的网卡
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "4d701985d7e77aa153790b697b2f38a61e20555c224b7675e4bf650b82799882",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/4d701985d7e7",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "8a6c71e2bafb19ca7dfd85445ccc4bef6d17467360a243d624089e676a24a018",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.3",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:03",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "22b0fd2290ccbc4e066a75d3f01bd8bf32ee4352c5bbcfc9f911287219219571",
                    "EndpointID": "8a6c71e2bafb19ca7dfd85445ccc4bef6d17467360a243d624089e676a24a018",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.3",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:03",
                    "DriverOpts": null
                }
            }
        }
    }
]

```



```shell
# 停止正在疯狂输出的那个容器
[root@192 ~]# docker stop cb6d7fbc3f27
cb6d7fbc3f27
```

#### 进入当前正在运行的容器

```shell
# 我们通常容器都是使用后台方式运行的e

docker exec -it 容器id bashSHELL

# 测试
[root@192 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
c2887d35c71d        centos              "/bin/bash"         35 minutes ago      Up 35 minutes                           vigorous_kare
[root@192 ~]# docker exec -it c2887d35c71d /bin/bash
[root@c2887d35c71d /]# ls
bin  etc   lib	  lost+found  mnt  proc  run   srv  tmp  var
dev  home  lib64  media       opt  root  sbin  sys  usr
[root@c2887d35c71d /]# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 11:57 pts/0    00:00:00 /bin/bash
root         14      0  0 12:32 pts/1    00:00:00 /bin/bash
root         28     14  0 12:32 pts/1    00:00:00 ps -ef
[root@c2887d35c71d /]# c2887d35c71d
[root@c2887d35c71d /]# exit
exit

# 方式二
[root@192 ~]# docker attach c2887d35c71d
[root@c2887d35c71d /]# 

# 区别
# docker exec # 进入容器后开启一个新的终端，可以在里面操作(常用)
# docker attach 进入容器正在执行的终端，不会启动新的进程

```



#### 从容器内拷贝文件到主机上

```shell
# 运行
[root@192 ~]# docker run -it centos
# ctrl P Q 不关闭退出，查看
[root@0569081aa89c /]# [root@192 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
0569081aa89c        centos              "/bin/bash"         19 seconds ago      Up 19 seconds    
hopeful_chebyshev

# 查看主机home下无文件
[root@192 ~]# cd /home
[root@192 home]# ls

# 进入正在运行的容器
[root@192 home]# docker attach 0569081aa89c

# 进入容器home目录
[root@0569081aa89c /]# cd /home

# 在目录中创建java文件
[root@0569081aa89c home]# touch test.java

# 退出并停止容器
[root@0569081aa89c home]# exit
exit

# 查看现在运行的容器
[root@192 home]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

# 容器虽然被停止，但是数据都会保留
[root@192 home]# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                         PORTS               NAMES
0569081aa89c        centos              "/bin/bash"              3 minutes ago       Exited (0) 8 seconds ago                           hopeful_chebyshev
f589e5684a01        centos              "/bin/bash"              44 minutes ago      Exited (0) 44 minutes ago                          cranky_easley
cb6d7fbc3f27        centos              "/bin/sh -c 'while t…"   54 minutes ago      Exited (137) 42 minutes ago                        dreamy_almeida
c2887d35c71d        centos              "/bin/bash"              58 minutes ago      Exited (127) 16 minutes ago                        vigorous_kare
8ce188e5fee3        centos              "/bin/bash"              About an hour ago   Exited (0) About an hour ago                       tender_dirac
7b1a7dd10ea4        centos              "/bin/bash"              9 hours ago         Exited (0) 9 hours ago                             fervent_mirzakhani

# 容器数据拷贝到主机
[root@192 home]# docker cp 0569081aa89c:/home/test.java /home
[root@192 home]# ls
test.java

# 拷贝是一个手动过程，未来我们使用 -v 卷的技术，可以实现自动同步 /home /home
```

#### 查看内容占用

```shell
docker stats

```





#### 小结

![image-20200617210554147](Docker.assets/image-20200617210554147.png)

```shell
[root@192 home]# docker --help

Usage:	docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Options:
      --config string      Location of client config
                           files (default "/root/.docker")
  -c, --context string     Name of the context to use to
                           connect to the daemon
                           (overrides DOCKER_HOST env var
                           and default context set with
                           "docker context use")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket(s) to connect to
  -l, --log-level string   Set the logging level
                           ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by
                           this CA (default
                           "/root/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file
                           (default "/root/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default
                           "/root/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Management Commands:
  builder     Manage builds
  config      Manage Docker configs
  container   Manage containers
  context     Manage contexts
  engine      Manage the docker engine
  image       Manage images
  network     Manage networks
  node        Manage Swarm nodes
  plugin      Manage plugins
  secret      Manage Docker secrets
  service     Manage services
  stack       Manage Docker stacks
  swarm       Manage Swarm
  system      Manage Docker
  trust       Manage trust on Docker images
  volume      Manage volumes

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  exec        Run a command in a running container
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  info        Display system-wide information
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  login       Log in to a Docker registry
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes

```



![image-20200617210932306](Docker.assets/image-20200617210932306.png)



![image-20200617211021003](Docker.assets/image-20200617211021003.png)



![image-20200617211039508](Docker.assets/image-20200617211039508.png)

#### 作业练习

##### 部署Nginx

![image-20200618100621199](Docker.assets/image-20200618100621199.png)

```shell
# 官网搜索nginx，可以看到帮助文档

# 下载镜像
[root@192 home]# docker pull nginx
Using default tag: latest
latest: Pulling from library/nginx
8559a31e96f4: Pull complete 
8d69e59170f7: Pull complete 
3f9f1ec1d262: Pull complete 
d1f5ff4f210d: Pull complete 
1e22bfa8652e: Pull complete 
Digest: sha256:21f32f6c08406306d822a0e6e8b7dc81f53f336570e852e25fbe1e3e3d0d0133
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest

# 查看镜像
[root@192 home]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              latest              831691599b88        13 hours ago        215MB
nginx               latest              2622e6cca7eb        7 days ago          132MB

# 运行测试
# -d 后台运行，--name 命名，-p 暴露端口，3344服务器、宿主机的端口，容器内部端口
[root@192 home]# docker run -d --name nginx01 -p:3344:80 nginx
38dbf7bdcaef232d269b7184d91e44e06087181b5ee929494e177ad526810fa8
[root@192 home]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
38dbf7bdcaef        nginx               "/docker-entrypoint.…"   7 seconds ago       Up 6 seconds        0.0.0.0:3344->80/tcp   nginx01

# 使用3344可以访问成功
[root@192 home]# curl localhost:3344
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```

端口暴露

![image-20200617212310709](Docker.assets/image-20200617212310709.png)

可以公网访问

找到服务器地址

![image-20200617213213721](Docker.assets/image-20200617213213721.png)

浏览器输入 192.168.147.132:3344/

![image-20200617213142079](Docker.assets/image-20200617213142079.png)

```shell
[root@192 home]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
38dbf7bdcaef        nginx               "/docker-entrypoint.…"   21 minutes ago      Up 21 minutes       0.0.0.0:3344->80/tcp   nginx01

# 进入容器
[root@192 home]# docker exec -it nginx01 /bin/bash

# 查一下nginx在哪
root@38dbf7bdcaef:/# whereis nginx
nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx

# 到这个目录
root@38dbf7bdcaef:/# cd /etc/nginx
root@38dbf7bdcaef:/etc/nginx# ls
conf.d		koi-utf  mime.types  nginx.conf   uwsgi_params
fastcgi_params	koi-win  modules     scgi_params  win-utf

# 退出
root@38dbf7bdcaef:/etc/nginx# exit
exit

# 停止
[root@192 home]# docker stop 38dbf7bdcaef
38dbf7bdcaef


```



再次刷新网页，服务关闭

思考问题：每次改动nginx配置文件，都需要进入容器内部，十分麻烦，要是可以在容器外部提供一个映射路径，达到在容器修改文件名，容器内部就可以自动修改？-v 数据卷技术！

##### 部署tomcat

![image-20200618100551587](Docker.assets/image-20200618100551587.png)

【视频书签：https://www.bilibili.com/video/BV1og4y1q7M4?p=15】

【20200618毕竟生产力工具，加油搞，这周一定刷完！！每次关机都要重连，麻烦(*╹▽╹*)】



在docker hub上查看版本号和使用方法

![image-20200618100319796](Docker.assets/image-20200618100319796.png)

官方文档一定要翻烂，超多版本，我的天呐~

###### 官方方法

```shell
docker run -it --rm tomcat:9.0

# docker run 可以不用pull，能自动下载
# -it 直接进去运行
# --rm 是什么意思？入门的意思？
# 我们之前的启动都是后台，停止了容器之后，容器还是可以查到
# 写了--rm，类似阅后即焚模式，用完即删除，这种通常用来测试

# 最后冒号查好的版本号
```



![image-20200618101811914](Docker.assets/image-20200618101811914.png)

![image-20200618101849917](Docker.assets/image-20200618101849917.png)

ctrl+c退出

```shell
docker ps -a
```

![image-20200618102022167](Docker.assets/image-20200618102022167.png)

可以看到并没有tomcat，印证阅后即焚模式，容器会删除，镜像不会删除

平时不建议这样搞

###### 正常方法

```shell
docker pull tomcat:9.0 # 之前下过了，应该不用下了，这里老师讲错了
```



![image-20200618102544564](Docker.assets/image-20200618102544564.png)

```shell
# 启动运行，应该加上版本号
docker run -d -p 3355:8080 --name tomcat01 tomcat
```

![image-20200618102837397](Docker.assets/image-20200618102837397.png)



```shell
# 进入容器
docker exec -it tomcat01 /bin/bash
```

![image-20200618103109004](Docker.assets/image-20200618103109004.png)

发现问题

1. linux命令少了
2. 没有webapps

![image-20200618103407205](Docker.assets/image-20200618103407205.png)

这是阿里云镜像的原因：默认使用最小镜像，所有不必要的都剔除了，保证最小可运行环境

![image-20200618103848104](Docker.assets/image-20200618103848104.png)

再次找到结构

![image-20200618104052242](Docker.assets/image-20200618104052242.png)

在浏览器中输入：http://192.168.147.132:3355/

![image-20200618103958168](Docker.assets/image-20200618103958168.png)

思考问题：我们以后部署项目，如果每次都要进入容器是不是身份麻烦？我要是可以在容器外部提供一个映射路径，webapps，我们在外部放置项目，就自动同步到内部就好了！

docker容器 tomcat+网站 

docker mysql

##### 部署es+kibana

![image-20200618104950722](Docker.assets/image-20200618104950722.png)



```shell
# es 暴露的端口很多
# es 十分耗内存
# es 的数据一般需要放置到安全目录！挂载

# 启动 elasticsearch
$ docker run -d --name elasticsearch01 -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.6.2

# 查看内存占用情况
docker stats
```

![image-20200618111713885](Docker.assets/image-20200618111713885.png)

```shell
# 先赶紧stop一下
docker stop ba18713ca536
```



![image-20200618105057785](Docker.assets/image-20200618105057785.png)



```shell
# 通过 -e 限制内存
$ docker run -d --name elasticsearch02 -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m" elasticsearch:7.6.2
```

![image-20200618113018622](Docker.assets/image-20200618113018622.png)

没成功啊，SEI能告诉我为啥！！

```shell
docker run -d --name zbcn-es -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m" elasticsearch:7.6.2
```

>py0003null大佬:
>“ES_JAVA_OPTS=-Xms64m -Xmx512m” 
>
>py0003null大佬:
>引号提前试试

原因是引号！！你没觉得怪怪的嘛

![image-20200618115302656](Docker.assets/image-20200618115302656.png)

此时查看stats，发现内存占用在控制范围内

![image-20200618115149971](Docker.assets/image-20200618115149971.png)

ctrl + C退出，记得stop

![image-20200618115921069](Docker.assets/image-20200618115921069.png)

##### 思考：用kibana链接elasticsearch

![image-20200618113556445](Docker.assets/image-20200618113556445.png)



### 可视化

- portainer(先用这个)
- Rancher(CI/CD时用)

#### portainer

Docker图像化界面管理工具，提供一个后台面板供我们操作！

```shell
docker run -d -p 8088:9000 --restart=always -v /var/run/docker.sock:/var/run/docker --privileged=true portainer/portainer
```

![image-20200618114542622](Docker.assets/image-20200618114542622.png)

访问外网8088

![image-20200618114902169](Docker.assets/image-20200618114902169.png)

用户名

密码 

![image-20200618134706491](Docker.assets/image-20200618134706491.png)

【中午吃饭重连了一下，失败，不知道发生了啥】

![image-20200618135424706](Docker.assets/image-20200618135424706.png)

![image-20200618135450037](Docker.assets/image-20200618135450037.png)

【平时不会用这个，好吧，先往下】



## Docker镜像

### 原理

UnionFS 联合文件系统

![image-20200618140242423](Docker.assets/image-20200618140242423.png)

bootfs：boot file system

rootfs：root file system

![image-20200618140907894](Docker.assets/image-20200618140907894.png)





![image-20200618140932621](Docker.assets/image-20200618140932621.png)

![image-20200618141014511](Docker.assets/image-20200618141014511.png)



![image-20200618153329894](Docker.assets/image-20200618153329894.png)

Docker镜像都是只读的，当容器启动时，一个新的可写层被加到镜像的顶部，这一层就是我们通常说的容器层，容器层之下的都叫镜像层

![image-20200618153855605](Docker.assets/image-20200618153855605.png)



### commit提交镜像

```shell
docker commit # 提交容器成为一个新的副本
docker commit -m="提交的描述信息" -a="作者" 容器id 目标镜像名：[TAG]
```

```shell
docker images
docker run -it -p 8080:8080 tomcat
```

![image-20200618154457286](Docker.assets/image-20200618154457286.png)

这是一个前台程序

![image-20200618154736475](Docker.assets/image-20200618154736475.png)

将webapps.dist里面所有的文件拷贝到webapps里面，其中-r必须有，表示目录递归拷贝

![image-20200618154943194](Docker.assets/image-20200618154943194.png)



![image-20200618155750591](Docker.assets/image-20200618155750591.png)

```shell
docker commit -a="paidaxing" -m="add webapps app" 当前容器的id tomcat02:1.0
```

![image-20200618160425265](Docker.assets/image-20200618160425265.png)

发现新的版本，比之前的大了一些，因为里面记录了我们的改动

> 如果想保存当前容器的状态，可以通过commit提交，获得一个镜像
>
> 好比我们以前学习VM的时候的快照
>
> 到这里算是入门了
>
> 接下来三个部分是docker的精髓



## 容器数据卷

### 什么是容器卷

docker是要将应用和环境打包成一个镜像

这样，数据就不应该在容器中，否则容器删除，数据就会丢失，这就是删库跑路

故容器之间要有一个数据共享技术

在Docker容器中产生的数据，同步到本地，这就是卷技术

本质上是一个目录挂载，将容器内的目录挂载到虚拟机上

![image-20200618162917672](Docker.assets/image-20200618162917672.png)

目的：容器的持久化和同步操作

容器间可以数据共享

### 使用数据卷

方式一：直接使用命令来挂载

```shell
# docker run -it -v 主机目录:容器内目录  -p 主机端口:容器内端口
docker run -it -v -p
# -it 交互式进入
# -v volume卷技术
# -p 主机端口

# /home/ceshi：主机home目录下的ceshi文件夹  映射：centos容器中的/home
[root@iz2zeak7 home]# docker run -it -v /home/ceshi:/home centos /bin/bash
#这时候主机的/home/ceshi文件夹就和容器的/home文件夹关联了,二者可以实现文件或数据同步了

```

![image-20200618163659503](Docker.assets/image-20200618163659503.png)

新开一个窗口

```shell
docker inspect 容器id

#通过 docker inspect 容器id 查看
[root@iz2zeak7sgj6i7hrb2g862z home]# docker inspect 6064c490c371
```



![image-20200618163938466](Docker.assets/image-20200618163938466.png)

找到挂载信息Mounts

![image-20200618164148642](Docker.assets/image-20200618164148642.png)

测试

![image-20200618164818624](Docker.assets/image-20200618164818624.png)

容器停止后，修改主机文件，再启动容器的时候，数据同样改变

双向同步

好处：我们以后修改只需要在本地修改即可，容器内会自动同步！

### 实战安装mysql

MySQL的数据持久化命令

```shell
docker search mysql

# 拉取
docker pull mysql:5.7

# 挂载
docker run -d -p 3310:3306 -v /home/mysql/conf:/etc/mysql/conf.d -v /home/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql01 mysql5.7

-d 后台运行
-p 端口映射
-v 卷挂载
-e 环境配置 安装启动mysql需要配置密码
--name 容器名字

# 实操
 # 获取mysql镜像
[root@iz2zeak7sgj6i7hrb2g862z home]# docker pull mysql:5.7
# 运行容器,需要做数据挂载 #安装启动mysql，需要配置密码的，这是要注意点！
# 参考官网hub 
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
#启动我们得
-d 后台运行
-p 端口映射
-v 卷挂载
-e 环境配置
-- name 容器名字
$ docker run -d -p 3310:3306 -v /home/mysql/conf:/etc/mysql/conf.d -v /home/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql03 mysql:5.7
# 启动成功之后，我们在本地使用sqlyog来测试一下
# sqlyog-连接到服务器的3306--和容器内的3306映射 
# 在本地测试创建一个数据库，查看一下我们映射的路径是否ok！
```

![image-20200618171353336](Docker.assets/image-20200618171353336.png)

链接测试：打开SQLyog

![image-20200618173234347](Docker.assets/image-20200618173234347.png)

点 测试链接

![image-20200618173300551](Docker.assets/image-20200618173300551.png)

点 链接

![image-20200618173729692](Docker.assets/image-20200618173729692.png)

#### 当我们在本地用SQLyog新建名称为test的数据库时候，容器容器也会创建

![在这里插入图片描述](docker_00_学习/mysql-test.png)

假设我们将包含mysql的容器删除时，

![img](docker_00_学习/mysql-test01.png)

发现，**我们挂载到本地的数据卷依旧没有丢失，这就实现了容器数据持久化功能**。



### 具名和匿名挂载

```shell
# 匿名挂载
-v 容器内路径!
$ docker run -d -P --name nginx01 -v /etc/nginx nginx
# 查看所有的volume(卷)的情况
$ docker volume ls    
DRIVER              VOLUME NAME # 容器内的卷名(匿名卷挂载)
local               21159a8518abd468728cdbe8594a75b204a10c26be6c36090cde1ee88965f0d0
local               b17f52d38f528893dd5720899f555caf22b31bf50b0680e7c6d5431dbda2802c
# 这里发现，这种就是匿名挂载，我们在 -v只写了容器内的路径，没有写容器外的路径！
# 具名挂载 -P:表示随机映射端口
$ docker run -d -P --name nginx02 -v juming-nginx:/etc/nginx nginx
9663cfcb1e5a9a1548867481bfddab9fd7824a6dc4c778bf438a040fe891f0ee
# 查看所有的volume(卷)的情况
$ docker volume ls                  
DRIVER              VOLUME NAME
local               21159a8518abd468728cdbe8594a75b204a10c26be6c36090cde1ee88965f0d0
local               b17f52d38f528893dd5720899f555caf22b31bf50b0680e7c6d5431dbda2802c
local               juming-nginx #多了一个名字
# 通过 -v 卷名：查看容器内路径
# 查看一下这个卷
$ docker volume inspect juming-nginx
[
    {
        "CreatedAt": "2020-05-23T13:55:34+08:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/juming-nginx/_data", #默认目录
        "Name": "juming-nginx",
        "Options": null,
        "Scope": "local"
    }
]
```

##### 区分三种挂在方式

```shell
# 三种挂载： 匿名挂载、具名挂载、指定路径挂载
-v 容器内路径            #匿名挂载
-v 卷名：容器内路径          #具名挂载
-v /宿主机路径：容器内路径 #指定路径挂载 docker volume ls 是查看不到的
```

拓展：

```shell
# 通过 -v 容器内路径： ro rw 改变读写权限
ro #readonly 只读
rw #readwrite 可读可写
$ docker run -d -P --name nginx05 -v juming:/etc/nginx:ro nginx
$ docker run -d -P --name nginx05 -v juming:/etc/nginx:rw nginx
# ro 只要看到ro就说明这个路径只能通过宿主机来操作，容器内部是无法操作！
```



【视频书签：https://www.bilibili.com/video/BV1og4y1q7M4?p=23，有点累了，跟不动了，这两天运动太少了，有点颓】

![image-20200618203452205](Docker.assets/image-20200618203452205.png)

![image-20200618203744983](Docker.assets/image-20200618203744983.png)

### DockerFile使用来构建docker镜像的文件

**Dockerfile 就是用来构建docker镜像的构建文件**！命令脚本！先体验一下！

通过这个**脚本可以生成镜像**，镜像是一层一层的，脚本是一个个的命令，每个命令都是一层！

```shell
# 创建一个dockerfile文件，名字可以随便 建议Dockerfile
# 文件中的内容： 指令(大写) + 参数
$ vim dockerfile1
    FROM centos                     # 当前这个镜像是以centos为基础的
    VOLUME ["volume01","volume02"]     # 挂载卷的卷目录列表(多个目录)
    CMD echo "-----end-----"        # 输出一下用于测试
    CMD /bin/bash                    # 默认走bash控制台
# 这里的每个命令，就是镜像的一层！
# 构建出这个镜像 
-f dockerfile1             # f代表file，指这个当前文件的地址(这里是当前目录下的dockerfile1)
-t caoshipeng/centos     # t就代表target，指目标目录(注意caoshipeng镜像名前不能加斜杠‘/’)
.                         # 表示生成在当前目录下
$ docker build -f dockerfile1 -t caoshipeng/centos .
Sending build context to Docker daemon   2.56kB
Step 1/4 : FROM centos
latest: Pulling from library/centos
8a29a15cefae: Already exists 
Digest: sha256:fe8d824220415eed5477b63addf40fb06c3b049404242b31982106ac204f6700
Status: Downloaded newer image for centos:latest
 ---> 470671670cac
Step 2/4 : VOLUME ["volume01","volume02"]             # 卷名列表
 ---> Running in c18eefc2c233
Removing intermediate container c18eefc2c233
 ---> 623ae1d40fb8
Step 3/4 : CMD echo "-----end-----"                    # 输出 脚本命令
 ---> Running in 70e403669f3c
Removing intermediate container 70e403669f3c
 ---> 0eba1989c4e6
Step 4/4 : CMD /bin/bash
 ---> Running in 4342feb3a05b
Removing intermediate container 4342feb3a05b
 ---> f4a6b0d4d948
Successfully built f4a6b0d4d948
Successfully tagged caoshipeng/centos:latest
# 查看自己构建的镜像
$ docker images
REPOSITORY          TAG          IMAGE ID            CREATED              SIZE
caoshipeng/centos   latest       f4a6b0d4d948        About a minute ago   237MB
```



![image-20200618211547398](Docker.assets/image-20200618211547398.png)

> kas:
> 没有安装吧？
>
> kas:
> 安装一下就可以了
>
> py9001021曾叙坚:
> centos 默认使用vi写内容，vim需要下载
>
> py9001021曾叙坚:
> 是的，需要下载vim才能使用
>
> YF:
> 配置可以改下，字体就很炫酷了
>
> 都建民:
> 用vi  试试
>
> 都建民:
> 你没有安装vim
>
> 都建民:
> yum install vim
>
> 都建民:
> 试试这个命令

```shell
yum install vim # 编辑文件的，没有装一下
```

![image-20200618211516566](Docker.assets/image-20200618211516566.png)

安装完之后就可以运行这个命令了

![image-20200618211803012](Docker.assets/image-20200618211803012.png)

```shell
# 镜像是一层一层的，脚本是一行一行的
# 指令都是大写的
# 这里的每个命令可以理解为镜像的一层

FROM centos

VOLUME ["volume01","volume02"] # 再创建镜像的时候就挂载出来

CMD echo "---end---"
CMD /bin/bash

```

![image-20200618211023834](Docker.assets/image-20200618211023834.png)

想保存并退出

>Wesley.:
>shift  加  冒号



![image-20200618211318410](Docker.assets/image-20200618211318410.png)

```shell
cat dockerfile1

docker build -f dockerfile1 -t padaxing/centos:1.0 .  # 最后的点很重要 镜像名不能有/
```

![image-20200618212936481](Docker.assets/image-20200618212936481.png)

```shell
docker images
```

![image-20200618213310752](Docker.assets/image-20200618213310752.png)

启动生成的镜像

![image-20200618220658979](Docker.assets/image-20200618220658979.png)

在容器内部创建一个文件

![image-20200618221801103](Docker.assets/image-20200618221801103.png)

查看Mounts，Source对应容器外目录，匿名挂载卷

![image-20200618221837895](Docker.assets/image-20200618221837895.png)

测试一下，在container volume01下生成文件

![image-20200618222224352](Docker.assets/image-20200618222224352.png)

在主机挂载路径下，也同样生成

### 多个容器数据共享

【视频书签：https://www.bilibili.com/video/BV1og4y1q7M4?p=25，周日下午，滨江，大雨，本来说这周六刷完的，发现周六啥也干不下去，除了吃就是睡，要么发呆研究小金库】

![image-20200621165403842](Docker.assets/image-20200621165403842.png)

看一下有啥images

![image-20200621165733780](Docker.assets/image-20200621165733780.png)

启动docker01，用之前建的padaxing/centos 1.0  镜像

```shell
docker run -it --name docker01 padaxing/centos:1.0 # 1.0必须写
```

![image-20200621170429658](Docker.assets/image-20200621170429658.png)



当前这个ctrl+p+q不停止退出

![image-20200621170540593](Docker.assets/image-20200621170540593.png)

依次启动docker02、docker03

```shell
docker run -it --name docker02 --volumes-from docker01 padaxing/centos:1.0
```

docker02继承docker01的volumes

可以验证，在docker01下加一个数据，在docker02下也会出现

![image-20200621171513650](Docker.assets/image-20200621171513650.png)

创建docker03，同样继承docker01

```shell
docker run -it --name docker03 --volumes-from docker01 padaxing/centos:1.0
```

![image-20200621172333639](Docker.assets/image-20200621172333639.png)

在docker03的volume01下建立文件，在docker01的volume01下同样也有

即通过--volumes-from 可以实现不同容器间的数据共享

删除docker01，数据还在

```shell
docker rm -f 
```

![image-20200621172830779](Docker.assets/image-20200621172830779.png)

可以看到，删除docker01，进入docker02，数据依然在

结论：

容器之间配置信息的传递，数据卷容器的生命周期一直持续到没有容器使用位置

但是如果持久化到了本地，即使所有容器删除了，本地数据是不会删除的

### 数据卷容器2

**多个MySQL同步数据**！

命名的容器挂载数据卷！

![在这里插入图片描述](docker_00_学习/volume-001.png)

```shell
# 测试 启动3个容器，通过刚才自己写的镜像启动
# 创建docker01：因为我本机是最新版，故这里用latest，狂神老师用的是1.0如下图
$ docker run -it --name docker01 caoshipeng/centos:latest
# 查看容器docekr01内容
$ ls
bin  home   lost+found    opt   run   sys  var
dev  lib    media    proc  sbin  tmp  volume01
etc  lib64  mnt        root  srv   usr  volume02
# 不关闭该容器退出
CTRL + Q + P  
# 创建docker02: 并且让docker02 继承 docker01
$ docker run -it --name docker02 --volumes-from docker01 caoshipeng/centos:latest
# 查看容器docker02内容
$ ls
bin  home   lost+found    opt   run   sys  var
dev  lib    media    proc  sbin  tmp  volume01
etc  lib64  mnt        root  srv   usr  volume02
```

![img](docker_00_学习/format-0025png)

![在这里插入图片描述](docker_00_学习/formart-0026.png)

```shell
# 再新建一个docker03同样继承docker01
$ docker run -it --name docker03 --volumes-from docker01 caoshipeng/centos:latest
$ cd volume01    #进入volume01 查看是否也同步docker01的数据
$ ls 
docker01.txt
# 测试：可以删除docker01，查看一下docker02和docker03是否可以访问这个文件
# 测试发现：数据依旧保留在docker02和docker03中没有被删除
```

![img](docker_00_学习/format-0027.png)

####  多个mysql实现数据共享

```shell
$ docker run -d -p 3306:3306 -v /home/mysql/conf:/etc/mysql/conf.d -v /home/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql01 mysql:5.7
$ docker run -d -p 3310:3306 -e MYSQL_ROOT_PASSWORD=123456 --name mysql02 --volumes-from mysql01  mysql:5.7
# 这个时候，可以实现两个容器数据同步！
```

结论：

**容器之间的配置信息的传递，数据卷容器的生命周期一直持续到没有容器使用为止**。

**但是一旦你持久化到了本地，这个时候，本地的数据是不会删除的**！

------

## DockerFile

是用来构建docker镜像的文件，可以理解为命令参数脚本

构建步骤：

1. 编写一个dockerfile文件
2. docker build 构建成为一个镜像
3. docker run运行镜像
4. docker push 发布镜像（DockerHub、阿里云镜像仓库 私有/共有）

这个写一个项目时一样的

### 官方DockerFile示例

看一下官方的DockerFile

![image-20200621174204807](Docker.assets/image-20200621174204807.png)

可以看到官方镜像都是基础包，很多功能没有，我们通常会自己搭建自己的镜像

官方既然可以制作镜像，我们也可以

-----

### DockerFile基础知识

1. 每个保留关键字(指令）都是必须是大写字母
2. 按照从上到下顺序执行
3.  `#`表示注释
4. 每一个指令都会创建体检一个新的镜像层，并提交

![image-20200621174948310](Docker.assets/image-20200621174948310.png)

docker是面向开发的，我们以后要发布项目，做镜像，就要编写dockerfile文件，这个文件十分简单！

Docker镜像逐渐成为企业的交付标准，必须掌握！

DockerFile：构建文件，定义了一切的步骤，源代码

DockerImages：通过DockerFile构建生成的镜像，最终发布和运行产品。

Docker容器：容器就是镜像运行起来提供服务。

---

### DockerFile命令

![image](docker_00_学习/171.jpg)

### 

```shell
FROM # from:基础镜像，一切从这里开始构建 比如centos
MAINTAINER # 镜像是谁写的 姓名+邮箱
RUN # run:镜像构建的时候需要运行的命令
ADD # add:步骤，tomcat镜像，这个tomcat压缩包！添加内容 添加同目录
WORKDIR # workdir:镜像的工作目录
VOLUME # volume:挂载的目录
EXPOSE # 指定暴露端口，跟-p一个道理
RUN # 最终要运行的
CMD # 指定这个容器启动的时候要运行的命令，只有最后一个会生效，而且可被替代
ENTRYPOINT # 指定这个容器启动的时候要运行的命令，可以追加命令
ONBUILD # onbuild:当构建一个被继承Dockerfile 这个时候运行ONBUILD指定，触发指令
COPY # copy:类似ADD，将文件拷贝到镜像中
ENV # 构建的时候设置环境变量
```

### 实战构建自己的centos

Docker Hub中99%的镜像都是从FROM scratch开始的

添加centos7的压缩包

```shell
# 创建一个自己的centos

# 进入home目录
cd /home

# 创建一个目录，之后的东西都保存到这里
mkdir dockerfile
# 进入这个目录
cd dockerfile/
# 创建一个dockerfile，名字叫mydockerfile
vim mydockerfile-centos


```

xshell新开一个界面

```shell
# 官方默认centos
docker run -it centos
pwd # 官方默认有pwd命令
vim # 官方默认没有vim命令
ifconfig # 官方默认没有ifconfig命令
```

![image-20200621184333206](Docker.assets/image-20200621184333206.png)

回到mydockerfile

![image-20200621184847524](Docker.assets/image-20200621184847524.png)

```shell
# 下面给官方centos加上自定义的内容
FROM centos
MAINTAINER padaxing<010301200@hai.com>

ENV MYPATH /usr/local
WORKDIR $MYPATH

RUN yum -y install vim
RUN yum -y install net-tools

EXPOSE 80

CMD echo $MYPATH
CMD echo "---end---"
CMD /bin/bash
```

![image-20200621185539523](Docker.assets/image-20200621185539523.png)

ESC, shif + : 输入wq保存并退出

如果写错了需要修改、

```shell
vim mydockerfile-centos
# 进入之后按i或者INSERT键即可修改
```

### 创建自己的centos 步骤

```shell
# 1./home下新建dockerfile目录
$ mkdir dockerfile
# 2. dockerfile目录下新建mydockerfile-centos文件
$ vim mydockerfile-centos
# 3.编写Dockerfile配置文件
FROM centos                            # 基础镜像是官方原生的centos
MAINTAINER zbcn<zbcn810@163.com>     # 作者

ENV MYPATH /usr/local                # 配置环境变量的目录 
WORKDIR $MYPATH                        # 将工作目录设置为 MYPATH

RUN yum -y install vim                # 给官方原生的centos 增加 vim指令
RUN yum -y install net-tools        # 给官方原生的centos 增加 ifconfig命令

EXPOSE 80                            # 暴露端口号为80

CMD echo $MYPATH                    # 输出下 MYPATH 路径
CMD echo "-----end----"                
CMD /bin/bash                        # 启动后进入 /bin/bash


# 4.通过这个文件构建镜像
# 命令： docker build -f 文件路径 -t 镜像名:[tag] .
$ docker build -f mydockerfile-centos -t mycentos:0.1 .
```



下面通过这个这个文件创建镜像

```shell
docker build -f dockerfile-centos -t mycentos:0.1 .
```

![image-20200621190219978](Docker.assets/image-20200621190219978.png)

依次执行命令

![image-20200621190439448](Docker.assets/image-20200621190439448.png)

最终返回Successfully表示成功

![image-20200621190524848](Docker.assets/image-20200621190524848.png)

```shell
docker run -it mycentos:0.1 # 版本号必须写，不然他会去找最新的
pwd
vim
ifconfig
```

![image-20200621190812481](Docker.assets/image-20200621190812481.png)

这时可以看到这些功能都有了

可以通过查看docker构建历史

![image-20200621192103460](Docker.assets/image-20200621192103460.png)

可以看到当前这个镜像是怎么一步一步构建起来的

我们平时拿到一个镜像也可以通过这个方法研究一下他是怎么做的

### CMD与ENTRYPOINT

```shell
CMD                    # 指定这个容器启动的时候要运行的命令，只有最后一个会生效，可被替代。
ENTRYPOINT            # 指定这个容器启动的时候要运行的命令，可以追加命令
```

####  测试cmd

【视频书签，https://www.bilibili.com/video/BV1og4y1q7M4?p=29，雨终于停了，想去江边跑步】

```shell

FROM centos
CMD ["ls","-a"] # 启动centos展示目录
```

![image-20200622075427103](Docker.assets/image-20200622075427103.png)

```shell
# 编写dockerfile文件
$ vim dockerfile-test-cmd
FROM centos
CMD ["ls","-a"]                    # 启动后执行 ls -a 命令
# 构建镜像
$ docker build  -f dockerfile-test-cmd -t cmd-test:0.1 .
# 运行镜像
$ docker run cmd-test:0.1        # 由结果可得，运行后就执行了 ls -a 命令
.
..
.dockerenv
bin
dev
etc
home

# 想追加一个命令  -l 成为ls -al：展示列表详细数据
$ docker run cmd-test:0.1 -l
docker: Error response from daemon: OCI runtime create failed: container_linux.go:349: starting container process caused "exec: \"-l\":
executable file not found in $PATH": unknown.
ERRO[0000] error waiting for container: context canceled 
# cmd的情况下 -l 替换了CMD["ls","-l"] 而 -l  不是命令所以报错
```

#### 测试ENTRYPOINT

![image-20200622075653789](Docker.assets/image-20200622075653789.png)

run的时候可以直接加命令

![image-20200622075802180](Docker.assets/image-20200622075802180.png)

Docker中许多命令都十分相似，我们需要了解他们的区别，最好的方式就是这样对比测试

```shell
# 编写dockerfile文件
$ vim dockerfile-test-entrypoint
FROM centos
ENTRYPOINT ["ls","-a"]
# 构建镜像
$ docker build  -f dockerfile-test-entrypoint -t cmd-test:0.1 .
# 运行镜像
$ docker run entrypoint-test:0.1
.
..
.dockerenv
bin
dev
etc
home
lib
lib64
lost+found ...
# 我们的命令，是直接拼接在我们得ENTRYPOINT命令后面的
$ docker run entrypoint-test:0.1 -l
total 56
drwxr-xr-x   1 root root 4096 May 16 06:32 .
drwxr-xr-x   1 root root 4096 May 16 06:32 ..
-rwxr-xr-x   1 root root    0 May 16 06:32 .dockerenv
lrwxrwxrwx   1 root root    7 May 11  2019 bin -> usr/bin
drwxr-xr-x   5 root root  340 May 16 06:32 dev
drwxr-xr-x   1 root root 4096 May 16 06:32 etc
drwxr-xr-x   2 root root 4096 May 11  2019 home
lrwxrwxrwx   1 root root    7 May 11  2019 lib -> usr/lib
lrwxrwxrwx   1 root root    9 May 11  2019 lib64 -> usr/lib64 ....
```



### 实战Tomcat镜像

【视频书签，https://www.bilibili.com/video/BV1og4y1q7M4?p=30，这节有点长，这个jar包是哪来的，晚上再搞，先去该模型比较急，还有10节课，这周争取都看完】

1. 准备镜像文件 

准备tomcat 和 jdk 到当前目录，编写好README

![image-20200827110412069](docker_00_学习/image-20200827110412069.png)

2. 编写dokerfile

```shell
$ vim dockerfile
FROM centos                                         # 基础镜像centos
MAINTAINER zbcn<1165680007@qq.com>                    # 作者
COPY README /usr/local/README                         # 复制README文件
ADD jdk-8u231-linux-x64.tar.gz /usr/local/             # 添加jdk，ADD 命令会自动解压
ADD apache-tomcat-9.0.35.tar.gz /usr/local/         # 添加tomcat，ADD 命令会自动解压
RUN yum -y install vim                                # 安装 vim 命令
ENV MYPATH /usr/local                                 # 环境变量设置 工作目录
WORKDIR $MYPATH
ENV JAVA_HOME /usr/local/jdk1.8.0_231                 # 环境变量： JAVA_HOME环境变量
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_HOME /usr/local/apache-tomcat-9.0.35     # 环境变量： tomcat环境变量
ENV CATALINA_BASH /usr/local/apache-tomcat-9.0.35
# 设置环境变量 分隔符是：
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/lib:$CATALINA_HOME/bin     
EXPOSE 8080                                         # 设置暴露的端口
CMD /usr/local/apache-tomcat-9.0.35/bin/startup.sh && tail -F /usr/local/apache-tomcat-9.0.35/logs/catalina.out                     # 设置默认命令
```

3. 构建镜像

```shell
# 因为dockerfile命名使用默认命名 因此不用使用-f 指定文件
$ docker build -t mytomcat:0.1 .
```

4. run镜像

```shell
# -d:后台运行 -p:暴露端口 --name:别名 -v:绑定路径 
$ docker run -d -p 8080:8080 --name tomcat01 
-v /home/kuangshen/build/tomcat/test:/usr/local/apache-tomcat-9.0.35/webapps/test 
-v /home/kuangshen/build/tomcat/tomcatlogs/:/usr/local/apache-tomcat-9.0.35/logs mytomcat:0.1
```

5. 访问测试

```shell
$ docker exec -it 自定义容器的id /bin/bash
# 访问测试
$ cul localhost:8080
```

6. 项目发布

(由于做了卷挂载，我们直接在本地编写项目就可以发布了！)

发现：项目部署成功，可以直接访问！

我们以后开发的步骤：需要掌握Dockerfile的编写！我们之后的一切都是使用docker镜像来发布运行！

## 发布自己的镜像

### 发布到 Docker Hub

1、地址 https://hub.docker.com/

2、确定这个账号可以登录

3、登录

```shell
$ docker login --help
Usage:  docker login [OPTIONS] [SERVER]
Log in to a Docker registry.
If no server is specified, the default is defined by the daemon.
Options:
  -p, --password string   Password
      --password-stdin    Take the password from stdin
  -u, --username string   Username
$ docker login -u 你的用户名 -p 你的密码
```

4. 提交 push镜像

![img](docker_00_学习/format-005.png)

```shell
# 会发现push不上去，因为如果没有前缀的话默认是push到 官方的library
# 解决方法：
# 第一种 build的时候添加你的dockerhub用户名，然后在push就可以放到自己的仓库了
$ docker build -t kuangshen/mytomcat:0.1 .
# 第二种 使用docker tag #然后再次push
$ docker tag 容器id kuangshen/mytomcat:1.0 #然后再次push
$ docker push kuangshen/mytomcat:1.0
```

### 发布到 阿里云镜像服务上

看官网 很详细https://cr.console.aliyun.com/repository/

```shell
$ sudo docker login --username=zchengx registry.cn-shenzhen.aliyuncs.com
$ sudo docker tag [ImageId] registry.cn-shenzhen.aliyuncs.com/dsadxzc/cheng:[镜像版本号]
# 修改id 和 版本
sudo docker tag a5ef1f32aaae registry.cn-shenzhen.aliyuncs.com/dsadxzc/cheng:1.0
# 修改版本
$ sudo docker push registry.cn-shenzhen.aliyuncs.com/dsadxzc/cheng:[镜像版本号]
```

### 小结

![image-20200827104430514](docker_00_学习/image-20200827104430514.png)

# Docker 网络

## 理解docker0

学习之前**清空下前面的docker 镜像、容器**

```shell
# 删除全部容器
$ docker rm -f $(docker ps -aq)
# 删除全部镜像
$ docker rmi -f $(docker images -aq)
```

## 测试

![img](docker_00_学习/format-004.png)

## 三个网络

*问题： docker 是如果处理容器网络访问的？*



![img](docker_00_学习/format-003.png)

```shell
# 测试  运行一个tomcat
$ docker run -d -P --name tomcat01 tomcat
# 查看容器内部网络地址
$ docker exec -it 容器id ip addr

# 发现容器启动的时候会得到一个 eth0@if91 ip地址，docker分配！
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
261: eth0@if91: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
       
       
# 思考？ linux能不能ping通容器内部！ 可以 容器内部可以ping通外界吗？ 可以！
$ ping 172.18.0.2
PING 172.18.0.2 (172.18.0.2) 56(84) bytes of data.
64 bytes from 172.18.0.2: icmp_seq=1 ttl=64 time=0.069 ms
64 bytes from 172.18.0.2: icmp_seq=2 ttl=64 time=0.074 ms
```

## *原理*

我们每启动一个docker容器，docker就会给docker容器分配一个ip，我们只要按照了docker，就会有一个docker0桥接模式，使用的技术是veth-pair技术！

https://www.cnblogs.com/bakari/p/10613710.html

再次测试 ip addr

![img](docker_00_学习/format-02.png)

再启动一个容器测试，发现又多了一对网络

![img](docker_00_学习/format001.png)

```shell
# 我们发现这个容器带来网卡，都是一对对的
# veth-pair 就是一对的虚拟设备接口，他们都是成对出现的，一端连着协议，一端彼此相连
# 正因为有这个特性 veth-pair 充当一个桥梁，连接各种虚拟网络设备的
# OpenStac,Docker容器之间的连接，OVS的连接，都是使用evth-pair技术
```

我们来测试下tomcat01和tomcat02是否可以ping通

```shell
# 获取tomcat01的ip 172.17.0.2
$ docker-tomcat docker exec -it tomcat01 ip addr  
550: eth0@if551: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
       
# 让tomcat02 ping tomcat01       
$ docker-tomcat docker exec -it tomcat02 ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.098 ms
64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.071 ms
# 结论：容器和容器之间是可以互相ping通
```

## 网络模型图

![img](docker_00_学习/format.png)

结论：tomcat01和tomcat02公用一个路由器，docker0。

所有的容器不指定网络的情况下，都是docker0路由的，docker会给我们的容器分配一个默认的可用ip。

## *小结*

Docker使用的是Linux的桥接，宿主机是一个Docker容器的网桥 docker0

![img](docker_00_学习/format-007.png)

Docker中所有网络接口都是虚拟的，虚拟的转发效率高（内网传递文件）

只要容器删除，对应的网桥一对就没了！

**思考一个场景：我们编写了一个微服务，database url=ip: 项目不重启，数据ip换了，我们希望可以处理这个问题，可以通过名字来进行访问容器**？

## –-link

```shell
$ docker exec -it tomcat02 ping tomca01   # ping不通
ping: tomca01: Name or service not known

# 运行一个tomcat03 --link tomcat02 
$ docker run -d -P --name tomcat03 --link tomcat02 tomcat
5f9331566980a9e92bc54681caaac14e9fc993f14ad13d98534026c08c0a9aef
# 3连接2
# 用tomcat03 ping tomcat02 可以ping通
$ docker exec -it tomcat03 ping tomcat02
PING tomcat02 (172.17.0.3) 56(84) bytes of data.
64 bytes from tomcat02 (172.17.0.3): icmp_seq=1 ttl=64 time=0.115 ms
64 bytes from tomcat02 (172.17.0.3): icmp_seq=2 ttl=64 time=0.080 ms
# 2连接3
# 用tomcat02 ping tomcat03 ping不通
```

### 探究

docker network inspect 网络id 网段相同

![img](docker_00_学习/format-008.png)

docker inspect tomcat03

![img](docker_00_学习/format-009.png)

查看tomcat03里面的/etc/hosts发现有tomcat02的配置

![img](docker_00_学习/format-010.png)

–link 本质就是在hosts配置中添加映射

现在使用Docker已经不建议使用–link了！

自定义网络，不适用docker0！

docker0问题：不支持容器名连接访问！

## 自定义网络

```shell
docker network
connect     -- Connect a container to a network
create      -- Creates a new network with a name specified by the
disconnect  -- Disconnects a container from a network
inspect     -- Displays detailed information on a network
ls          -- Lists all the networks created by the user
prune       -- Remove all unused networks
rm          -- Deletes one or more networks
```

###  查看所有的docker网络

![img](docker_00_学习/format-011.png)

### 网络模式

- bridge ：桥接 docker（默认，自己创建也是用bridge模式）
- none ：不配置网络，一般不用
- host ：和所主机共享网络
- container ：容器网络连通（用得少！局限很大）

## 测试

```shell
# 我们直接启动的命令 --net bridge,而这个就是我们得docker0
# bridge就是docker0
$ docker run -d -P --name tomcat01 tomcat
等价于 => docker run -d -P --name tomcat01 --net bridge tomcat
# docker0，特点：默认，域名不能访问。 --link可以打通连接，但是很麻烦！
# 我们可以 自定义一个网络
$ docker network create --driver bridge --subnet 192.168.0.0/16 --gateway 192.168.0.1 mynet
```

![img](docker_00_学习/format-012.png)

`$ docker network inspect mynet;`

![img](docker_00_学习/format-013.png)

启动两个tomcat,再次查看网络情况

![img](docker_00_学习/format-014.png)

![img](docker_00_学习/format-015.png)

在自定义的网络下，服务可以互相ping通，不用使用–link

![img](docker_00_学习/format-016.png)

我们自定义的网络docker当我们维护好了对应的关系，推荐我们平时这样使用网络！

**好处：**

- redis -不同的集群使用不同的网络，保证集群是安全和健康的
- mysql-不同的集群使用不同的网络，保证集群是安全和健康的

![img](docker_00_学习/format--017.png)

##  网络联通

![img](docker_00_学习/format-018.png)

![img](docker_00_学习/format-019.png)

```shell
# 测试两个不同的网络连通  再启动两个tomcat 使用默认网络，即docker0
$ docker run -d -P --name tomcat01 tomcat
$ docker run -d -P --name tomcat02 tomcat
# 此时ping不通
```

![img](docker_00_学习/format-020.png)

```shell
# 要将tomcat01 连通 tomcat—net-01 ，连通就是将 tomcat01加到 mynet网络
# 一个容器两个ip（tomcat01）
```

![img](docker_00_学习/format-021.png)

```shell
# 01连通 ，加入后此时，已经可以tomcat01 和 tomcat-01-net ping通了
# 02是依旧不通的
```

结论：假设要跨网络操作别人，就需要使用docker network connect 连通！

## 实战  部署redis 集群

![img](docker_00_学习/format-022.png)

```shell
# 创建网卡
docker network create redis --subnet 172.38.0.0/16

# 通过脚本创建六个redis配置
for port in $(seq 1 6);\
do \
mkdir -p /mydata/redis/node-${port}/conf
touch /mydata/redis/node-${port}/conf/redis.conf
cat << EOF >> /mydata/redis/node-${port}/conf/redis.conf
port 6379
bind 0.0.0.0
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip 172.38.0.1${port}
cluster-announce-port 6379
cluster-announce-bus-port 16379
appendonly yes
EOF
done

# 通过脚本运行六个redis
for port in $(seq 1 6);\
docker run -p 637${port}:6379 -p 1667${port}:16379 --name redis-${port} \
-v /mydata/redis/node-${port}/data:/data \
-v /mydata/redis/node-${port}/conf/redis.conf:/etc/redis/redis.conf \
-d --net redis --ip 172.38.0.1${port} redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
docker exec -it redis-1 /bin/sh #redis默认没有bash
redis-cli --cluster create 172.38.0.11:6379 172.38.0.12:6379 172.38.0.13:6379 172.38.0.14:6379 172.38.0.15:6379 172.38.0.16:6379  --cluster-replicas 1
```

![img](docker_00_学习/format-023.png)

docker搭建redis集群完成！

![img](docker_00_学习/format-024.png)

我们使用docker之后，所有的技术都会慢慢变得简单起来！

## SpringBoot微服务打包Docker镜像

1、构建SpringBoot项目

2、打包运行

```shell
mvn package
```

3、编写dockerfile

```shell
FROM java:8
COPY *.jar /app.jar
CMD ["--server.port=8080"]
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
```

4、构建镜像

```shell
# 1.复制jar和DockerFIle到服务器
# 2.构建镜像
$ docker build -t xxxxx:xx  .
```

5、发布运行

以后我们使用了Docker之后，给别人交付就是一个镜像即可！

## IDEA整合Docker

## Docker 整合Docker

## Docker Compose

## Docker Swarm

## 各种bug

### Xshell链接失败

![image-20200616200418271](Docker.assets/image-20200616200418271.png)

```bash
Connecting to 192.168.147.131:22...
Could not connect to '192.168.147.131' (port 22): Connection failed.

```



注：电脑休眠重启后，机子会断开，要重新在vmware里面输入ip addr 获得ip

![image-20200616200344918](Docker.assets/image-20200616200344918.png)

修改xshell中的主机接口即可

![image-20200616200505065](Docker.assets/image-20200616200505065.png

![image-20200624101454866](Docker.assets/image-20200624101454866.png)