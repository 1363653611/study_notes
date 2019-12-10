---
title: 2. python3 virtualenv 虚拟环境搭建
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
### 虚拟环境搭建 ###
1. venv 环境创建`virtualenv venv`
  - 报错,提示`virtualenv: command not found...`
  - 解决方案:
    1.  找到`virtualenv.py`:
      ```
      find / -name 'virtualenv.py'
      --> /usr/local/python3/lib/python3.8/site-packages/virtualenv.py
      ```
    2. 然后进入所在目录：
      - 方式1:
        ```
          cd  /usr/local/python3/lib/python3.8/site-packages/
          # 创建名为venvName的虚拟环境
          python virtualenv.py venvName
        ```
      - 方式2:
        ```
        vim /etc/profile
        # 将下面内容添加到文件的最下面
        PATH=$PATH:/usr/local/python3/bin

        #是添加的进行生效命令
        source /etc/profile

        # 最后查看是否添加成功
        echo $PATH
        ```
2. 虚拟机的激活(进入虚拟环境目录)
  ```
    source ./bin/activate
  ```
3. 退出虚拟环境 `deactivate`

4. 切换 虚拟环境 `workon [虚拟环境]`
  - 可能会报错 解决方案：按照提示重新执行一下 `mkvirtualenv venv`

5. `workon` 查看虚拟环境列表

6. 删除虚拟环境 `rmvirtualenv [虚拟环境名]`
