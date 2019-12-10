---
title: 1. lunix python3.8 安装
date: 2019-11-05 13:14:10
tags:
 - python
 - env
categories:
 - python
 - env
#top: 1
topdeclare: true
reward: true
---
### lunix python 安装

1. 先看看现有的 python2在哪里
  ```lunix
  whereis python
  # python: /usr/bin/python /usr/bin/python2.7 /usr/bin/python.bak /usr/lib/python2.7 /usr/lib64/python2.7 /etc/python /usr/include/python2.7 /usr/share/man/man1/python.1.gz
  ```
2. 切换至bin 目录
  ```lunix
    cd /bin
  ```
3. 查看安装的python 版本
  ```lunix
  zbcn@zbcn bin]$ ll python*
  lrwxrwxrwx. 1 root root    7 Oct 23 17:56 python -> python2
  lrwxrwxrwx. 1 root root    9 Oct 23 17:56 python2 -> python2.7
  -rwxr-xr-x. 1 root root 7216 Aug  7 08:52 python2.7

  ```
4. 要安装编译 Python3的相关包
  ```lunix
  yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel
  ```
  __提示错误:__
    - 错误信息：`Loaded plugins: fastestmirror, langpacks You need to be root to perform this command.`

     解决方案: 输入su 回车输入密码 即可解决

  __注意：__     
    - 这里面有一个包很关键libffi-devel，因为只有3.7才会用到这个包，如果不安装这个包的话，在 make 阶段会出现如下的报错： `# ModuleNotFoundError: No module named '_ctypes'`

5. 安装pip，因为 CentOs 是没有 pip 的。
  ```lunix
  #运行这个命令添加epel扩展源
  yum -y install epel-release
  #安装pip
  yum install python-pip
  ```
6. 可以用 python 安装一下 wget `pip install wget`

7. 安装 3.8 的python 包
  ```lunix
  # 下载
  wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz

  #解压缩
  tar -zxvf Python-3.8.0.tgz

  #进入解压后的目录，依次执行下面命令进行手动编译
  ./configure prefix=/usr/local/python3
  make && make install
  ```
8. 检查python3.8安装是否成功
    ```lunix
    # 切换目录
     cd /usr/local/python3/bin/
     #校验python版本
     ./python3 -V
      ->  Python 3.8.0a3

    # pip 版本
     ./pip3 -V
      -> pip 19.0.3 from /usr/local/python3/lib/python3.8/site-packages/pip (python 3.8)
    ```
9. 添加软链接
  ```lunix
  #添加python3的软链接
  ln -s /usr/local/python3/bin/python3.8 /usr/bin/python3
  #添加 pip3 的软链接
  ln -s /usr/local/python3/bin/pip3.8 /usr/bin/pip3
  #测试是否安装成功了
  python -V
  ```

#### 可选，如果需要将 python3.8 指向 python 软链接。则需要进行如下步骤

1. [第9 步](self.9) 的软链不执行，则无需执行以下操作，如果已经执行，则删删除已经安装的软链接

  ```lunix
    # 删除软链接（python3 软链接）
    rm -rf  ./Python3
    rm -rf ./pip3
  ```

2. 备份原来的 python2 及 pip2
  ```lunix
   whereis python
   -> python: /usr/bin/python /usr/bin/python2.7 /usr/lib/python2.7 /usr/lib64/python2.7 /- --> etc/python /usr/include/python2.7 /usr/share/man/man1/python.1.gz

   # 备份到python2
   mv /usr/bin/python /usr/bin/python2

  whereis pip
  -> pip: /usr/bin/pip /usr/bin/pip2.7
  # 备份到pip2
  mv /usr/bin/pip /usr/bin/pip2
  ```
3. python3 及 python 软链接的创建
    ```lunix
      ln -s  /usr/local/python3/bin/python3 /usr/bin/python

      ln -s /usr/local/python3/bin/pip3 /usr/bin/pip

    python -V
    -> Python 3.8.0a3

    pip -V
    -> pip 19.0.3 from /usr/local/python3/lib/python3.8/site-packages/pip (python 3.8)
    ```
  4. 验证 python2 和 pip2 命令
    ```
    python2 -V
    pip2 -V
    ```
    - __注:__
      - 如果出现 `bash: cd: python2: Too many levels of symbolic links` 异常
        1. 原因: 建立软连接时,采用的时相对路径
        2. 查看软连接信息 `ls -al`
        3. 解决方案: 用绝对路径代替相对路径 `ln -s /usr/bin/python2.7 /usr/bin/python2`, 问题解决

  4. yum 命令执行报错

    ```
    yum -y install gcc

    -> File "/usr/bin/yum", line 30
    ->   except KeyboardInterrupt, e:
                              ^
    -> SyntaxError: invalid syntax
    ```
    __原因__:因为 yum 是使用 python2 编写的，所以需要把 yum 的头文件改成用 python2 作为解释器

    __解决方案__
    ```lunix
    whereis yum
    -> yum: /usr/bin/yum /etc/yum /etc/yum.conf /usr/share/man/man8/yum.8

    -> vim /usr/bin/yum

    其中，#!/usr/bin/python 改成 #!/usr/bin/python2 即可
    ```
