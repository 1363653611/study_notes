---
title: lunix 环境下 jdk 8 安装
date: 2021-02-09 15:14:10
tags:
 - LINUX
categories:
 - LINUX
topdeclare: true
reward: true
---

# lunix 环境下 jdk 8 安装

## 检查是否安装 jdk： `java -version`

##  检测系统JDK默认安装包

- 命令：`rpm -qa | grep java`　：命令的意思是搜索java，查看安装包文件。

## 卸载OpenJDK

- 卸载命令：`rpm -e --nodeps 名称`　　　　或者　　　　`yum remove *openjdk*`
- 之后再次输入命令 查看卸载情况：`rpm -qa | grep java`　　或者　　`java -version`

```shell
卸载命令rpm：
[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-headless-1.8.0.242.b08-1.el7.x86_64
[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-1.8.0.242.b08-1.el7.x86_64
或者
卸载命令yum：
[root@localhost ~]# yum remove *openjdk*

检查
[root@localhost root]$ java -version
bash: java: 未找到命令...
或者
[root@localhost ~]# rpm -qa | grep java
python-javapackages-3.4.1-11.el7.noarch
tzdata-java-2019c-1.el7.noarch
javapackages-tools-3.4.1-11.el7.noarch
```

<!--more-->


## 安装JDK

- 选择到JDK官网上下载你想要的JDK版本，下载完成之后将需要安装的JDK安装包上传到Linux系统指定的文件夹下，并且命令进入该文件夹下。
- 进入用户根目录，创建一个文件夹downfile，用于保存上传的文件。
- 解压JDK文件到/usr/usr/local/目录中。`tar -xvf jdk-8u202-linux-x64.tar.gz -C /usr/local/jdk`

## 配置环境变量

- Linux环境变量配置都在：/etc/profile文件中

- VIM命令编辑文件（建议编辑前复制一份源文件作为备份）`vim /etc/profile`

- 在编辑模式下加入如下配置

  ```shell
  export JAVA_HOME=/usr/local/jdk/jdk1.8.0_202
  export PATH=$JAVA_HOME/bin:$PATH
  export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
  ```

## 重新载入配置文件

- `source /etc/profile`

## 检查新安装的JDK

- `java -version`

# yum 安装

##　查询JDK可用版本

```shell
yum -y list java*
# 或者
yum search java | grep -i --color JDK
```

## 选择安装JDK

- `yum  install  -y  java-1.8.0-openjdk.x86_64`

## 检测安装

- ` java -version`

# 参考

- https://www.cnblogs.com/xsge/p/13817301.html