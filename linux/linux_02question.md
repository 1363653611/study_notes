---
title: 02 LINUX遇到问题总结
date: 2019-12-09 15:14:10
tags:
 - LINUX
categories:
 - LINUX
topdeclare: true
reward: true
---

### LINUX遇到问题总结

1. `xxx is not in the sudoers file.This incident will be reported`
   - 解决方案：解决方法就是在/etc/sudoers文件里给该用户添加权限
     - 切换root 用户：方法为直接在命令行输入：su，然后输入密码
     - `/etc/sudoers` 文件默认是只读的，对root来说也是，因此需先添加sudoers文件的写权限,命令是:即执行操作：`chmod u+w /etc/sudoers`
     - 编辑sudoers文件  `vi /etc/sudoers`
        - 找到这行 `root ALL=(ALL) ALL`,在他下面添加 `xxx ALL=(ALL) ALL` (这里的xxx是你的用户名)
        - ps:这里说下你可以sudoers添加下面四行中任意一条
            *  `youuser ALL=(ALL) ALL`  *第一行:允许用户youuser执行sudo命令(需要输入密码).*
            *  `%youuser ALL=(ALL) ALL` *第二行:允许用户组youuser里面的用户执行sudo命令(需要输入密码).*
            * `youuser ALL=(ALL) NOPASSWD: ALL` *第三行:允许用户youuser执行sudo命令,并且在执行的时候不输入密码.*
            * `%youuser ALL=(ALL) NOPASSWD: ALL` *第四行:允许用户组youuser里面的用户执行sudo命令,并且在执行的时候不输入密码.*

        - 4.撤销sudoers文件写权限,命令:`chmod u-w /etc/sudoers`

        - 切回普通用户 `su - zbcn`
