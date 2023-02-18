# Git同时配置Gitee和GitHub

在当下，gitee 也成为国内很多开发人员交友社区。同时为了跟上时代的步伐，大家也不想放弃github。所以同时将自己的项目提交到gitee 和github 成了开发人员的诉求。

## git 全局用户设置

```shell
## 产看 全局配置
git config --global --list

# 清除（如果未添加过，则不需要清除）
git config --global --unset user.name "name"
git config --global --unset user.email "@mail"


git config --global user.name "new name"                      
git config --global user.email "new emial"

# 注：--global 表示全局属性，所有的git项目都会共用属性。设置本地机器默认commit的昵称与Email. 请使用有意义的名字与email.
```

## 生成生成新的 SSH keys

### GitHub 的钥匙

```shell

# 第一步
ssh-keygen -t rsa -f ~/.ssh/id_rsa.github -C "邮箱1"

out:
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
# 说明： 遇到以上Enter passphrase (empty for no passphrase)，直接敲回车即可，不需要输入用户名或者密码

# 第二步
一直敲回车
our identification has been saved in /Users/likun/.ssh/id_rsa.github.
Your public key has been saved in /Users/likun/.ssh/id_rsa.github.pub.
The key fingerprint is:
SHA256:xxxx xxxx
The key's randomart image is:
---[RSA 3072]----+
|     xx .   xxxx |
+----[SHA256]-----+

```

### Gitee 的钥匙

```shell
# 第一步
ssh-keygen -t rsa -f ~/.ssh/id_rsa.gitee -C "邮箱2"

# 第二步
一直敲回车

Your identification has been saved in /Users/likun/.ssh/id_rsa.gitee.
Your public key has been saved in /Users/likun/.ssh/id_rsa.gitee.pub.
The key fingerprint is:
SHA256:dFuVYB3D7tIzMbioTmv1O5O1Jl4F8TLIpFqgk0RsHuo 1363653611@qq.com
The key's randomart image is:
+---[RSA 3072]----+
|     xx .   xxxx |
+----[SHA256]-----+
```

## 完成后会在~/.ssh / 目录下生成以下文件。

```
- id_rsa.github
- id_rsa.github.pub
- id_rsa.gitee
- id_rsa.gitee.pub
```

## 识别 SSH keys 新的私钥

默认只读取 id_rsa，为了让 SSH 识别新的私钥，需要将新的私钥加入到 SSH agent 中。**这一步也需要再探索一下，不设置也可以成功。**

```shell
ssh-agent bash
ssh-add ~/.ssh/id_rsa.github
ssh-add ~/.ssh/id_rsa.gitee
```

## 多账号配置 config 文件

### 创建config文件

```shell
touch ~/.ssh/config 
```

#### config 中填入如下内容
```shell
#Default gitHub user Self
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa.github

# gitee
Host gitee.com
    Port 22
    HostName gitee.com
    User git
    IdentityFile ~/.ssh/id_rsa.gitee
```

## 添加 ssh

分别添加SSH到Gitee和Github：

1. Github：
   https://github.com/settings/keys
   将 id_rsa.github.pub 中的内容填进去，起名的话随意。

2. Gitee:
   https://gitee.com/profile/sshkeys
   将 id_rsa.gitee.pub 中的内容填进去，起名的话随意。

## 测试成功

```shell
ssh -T git@gitee.com
Hi zbcn! You've successfully authenticated, but GITEE.COM does not provide shell access.

ssh -T git@github.com
Hi 1363653611! You've successfully authenticated, but GitHub does not provide shell access.

```



# IDEA中同时push项目到gitee和github



1. 找到 git 的远程配置

<img src="/Users/likun/Documents/zbcn/study_notes/git/git配置gitee和github/image-20230218121034510.png" alt="image-20230218121034510" style="zoom:50%;" />

2. 多个push项目的时候就可以切换我们想要push的地方

<img src="/Users/likun/Documents/zbcn/study_notes/git/git配置gitee和github/image-20230218120858264.png" alt="image-20230218120858264" style="zoom:50%;" />





# 解决本地库同时关联GitHub和Gitee

## 跳转到要添加关联远程仓库的项目下

我们在本地库上使用命令`git remote add`把它同时和Github、Gitee的远程库关联起来

```shell
git remote add github git@github.com:xxx/xxx_test.git
git remote add gitee git@gitee.com:xxxx/xx-test.git

```

*此处可以为https地址也可以是ssh地址，orign为设置的远程仓库的别名（如果我们关联两个的话，则需要设置不同名，比如github和gitee），**强烈建议使用ssh方式**，因为https方式每次都要输入用户名和密码*

- 关联完成后，我们可以通过输入`git remote -v`来查看关联的远程库信息

### 这样一来，我们的本地库就可以同时与多个远程库互相同步：

![image-20230218122832989](/Users/likun/Documents/zbcn/study_notes/git/git配置gitee和github/image-20230218122832989.png)



如果要推送到GitHub，使用命令：`git push github master`

如果要推送到Gitee，使用命令：`git push gitee master`