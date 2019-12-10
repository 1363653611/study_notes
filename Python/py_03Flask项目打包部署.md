---
title: 3. Flask 项目打包部署
date: 2019-10-06 13:14:10
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
### Flask 项目打包部署

#### requirements.txt 文件生成 `pip freeze > requirements.txt`

#### 安装requirements.txt依赖 `pip install -r requirements.txt`
   - 执行报错 `ModuleNotFoundError: No module named ‘_ctypes’`
   - 解决方案：
      ```
      yum install libffi-dev -y
      yum update -y

      make install
      ```
    - 如果还报错，在继续安装下其他基础包.
    ```
    yum install make curl curl-devel gcc gcc-c++ gcc-g77 gcc* make zlib-devel bzip2-devel openssl-devel xz-libs wget unzip xz vixie-cron crontabs ntpdate tar lrzsz sysstat bind-utils vim -y
    yum groupinstall 'development tools' -y
    yum update -y

    #进入解压后的目录，依次执行下面命令进行手动编译
    sudo ./configure prefix=/usr/local/python3
    sudo make
    sudo make install
    ```
    至此,问题解决

1. 安装virtualenv `sudo pip3 install virtualenv` `sudo pip3 install virtualenvwrapper`

2. 建立软连接 `ln -s /usr/local/python3/lib/python3.8/site-packages`(未执行)

2. 切换到你的flask应用项目的根目录
  ```lunix
  # 创建虚拟环境
  # virtualenv -p python3 py38env (命令失效)
  python -m virtualenv venv

  source venv/bin/activate
  ```
    - __问题__: mkvirtualenv: 未找到命令
      1. 升级 python 包管理器工具 pip3 `pip install --upgrade pip`
      2. python 虚拟环境的安装
        ```
        sudo pip3 install virtualenv
        sudo pip3 install virtualenvwrapper
        ```
      3. 创建目录用来存放虚拟环境 `mkdir $HOME/.virtualenvs`
      4. 在 ~/.bashrc 中添加行
        ```
        vi ~/.bashrc

        export WORKON_HOME=HOME/.virtualenvs
        # 网上很多教程说在 source /usr/local/bin/virtualenvwrapper.sh,实际上不对
        source /usr/bin/virtualenvwrapper.sh
        ```
      5. 运行:`source ~/.bashrc`

      6. 问题解决

      7. 其他命令(估计也有问题,未验证)
        ```
        # 创建虚拟环境
        mkvirtualenv [虚拟环境名称]
        workon [虚拟环境名称]

        # 退出虚拟环境 离开
        deactivate

        # 删除虚拟环境(慎用)
        rmvirtualenv [虚拟环境名称]
        ```

4. 进入虚拟环境后，安装你的flask应用的所有扩展包,最好把所有的扩展包写入requirements.txt
  ```
  pip install -r requirements.txt
  ```

5. 安装gunicorn和gevent
  ```
  pip3 install gunicorn
  pip3 install gevent
  ```
6. 启动gunicorn（注：这时必须进入你项目的根目录且处于虚拟环境中，因为gunicorn安装在虚拟环境中）

7. 配置gunicorn启动配置文件,在项目的根目录创建一个gunicron.conf,写入以下内容:
  ```python
  import gevent.monkey
  gevent.monkey.patch_all()
  import multiprocessing
  import os

  if not os.path.exists('/var/log/gunicorn'):
  	os.mkdir('/var/log/gunicorn')

  bind='0.0.0.0:5000'
  # 需要log目录存在。如果不存在，启动会报错
  #启动的进程数
  workers = multiprocessing.cpu_count() * 2 + 1
  backlog=2048
  worker_class="gevent"  #sync, gevent,meinheld
  debug=True
  proc_name = 'gunicorn_raab.pid'
  pidfile = '/var/log/gunicorn/raabpid.log'
  errorlog = '/var/log/gunicorn/raaberror.log'
  accesslog = '/var/log/gunicorn/raabaccess.log'
  loglevel = 'debug'
  threads = 4
  worker_connections = 2000

  x_forwarded_for_header = 'X-FORWARDED-FOR'
  ```
8. 然后执行以下代码启动
  ```
    # 不显示日志
    gunicorn -k gevent -c gunicorn.py wsgi:app
    # 带日志
    gunicorn -k gevent -c gunicorn.py wsgi:app –preload
    gunicorn -k gevent -c gunicorn.py wsgi:app --log-level=debug
  ```

  __注__:run:app说明
    1. run为你定义Flask应用实例的py文件
    2. app是你在该文件中实例化的Flask应用的变量名
    3. `gunicorn` 命令执行时,如果提示 `gunicorn commond not found` ,需要添加lunix 的环境变量:  
      ```lunix
        # 打开环境变量的配置位置
        vi /etc/profile
        # 添加 路径
        export PATH=$PATH:/usr/local/python3/bin
        # 使路径生效:
        source /etc/profile
      ```
