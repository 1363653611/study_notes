---
title: git_02 rebase 和merge 区别
date: 2020-03-07 12:30:10
tags:
  - git
categories:
  - git
topdeclare: false
reward: true
---

## 常见问题:

### 解决冲突
#### 合并冲突：
- 提交的文件如果出现冲突就会出现这种提示
```
CONFLICT (content): Merge conflict in readme.txt
Automatic merge failed; fix conflicts and then commit the result.
```
- 通过 `git status` 查看冲突文件
- Git用`<<<<<<<，=======，>>>>>>>`标记出不同分支的内容
  1. `<<<<<<<`标记冲突开始，后面跟的是当前分支中的内容。
  2. HEAD指向当前分支末梢的提交
  3. `=======`之后，`>>>>>>>`之前是要merge过来的另一条分支上的代码。
  4. `>>>>>>>`之后的dev是该分支的名字。
- 修改文件，保存，再次提交即可
- 通过git log查看分支合并的情况
<!---more-->
### git pull 和 git pull -rebase 的区别

- 操作关系:
  - git pull = git fetch + git merge
  - git pull --rebase = git fetch + git rebase

### git merge 和 git rebase 的区别
#### 问题场景预设:
1. 假设有3次提交A,B,C。  
![3times_commit](./imgs/3times_commit.png)
2. 在远程分支origin的基础上创建一个名为"mywork"的分支并提交了,同时有其他人在"origin"上做了一些修改并提交了, mywork 分支有人修改了同样的文件。  
![conflict](./imgs/conflict.png)

#### 两种解决方案:
##### `git merge`  
 用git pull命令把"origin"分支上的修改pull下来与本地提交合并（merge）成版本M，但这样会形成图中的菱形.
 - 命令:
  ```git
  git checkout mywork # 切换到我的分支
  git merge origin # 将origin合并到 mywork
  ```
  或者(更简单)
  ```git
  git merge origin mywork
  ```
  - 结果: 那么此时在mywork上git 自动会产生一个新的commit(merge commit)
![gitmerge](./imgs/gitmerge.png)

 - merge 特点:
  1. marge 特点：自动创建一个新的commit
  2. 如果合并的时候遇到冲突，仅需要修改后重新commit
  3. 优点：记录了真实的commit情况，包括每个分支的详情
  4. 缺点：因为每次merge会自动产生一个merge commit，所以在使用一些git 的GUI tools，特别是commit比较频繁时，看到分支很杂乱。


##### `git rebase`  
创建一个新的提交R，R的文件内容和上面M的一样，但我们将E提交废除，当它不存在（图中用虚线表示）。由于这种删除,不应该push其他的repository.rebase的好处是避免了菱形的产生，保持提交曲线为直线.
  - 本质是变基 变基 变基
  变基是什么? __找公共祖先__
  - 命令:
  ```git
  git checkout mywork
  git rebase origin
  ```
![git_rebase](./imgs/git_rebase.png)
- rebase 点:
  1. 会合并之前的commit历史
  2. 优点：得到更简洁的项目历史，去掉了merge commit
  3. 缺点：如果合并出现代码问题不容易定位，因为re-write了history
  4. 合并时如果出现冲突需要按照如下步骤解决:
    1. 修改冲突部分
    2. `git add`
    3. `git rebase --continue`
    4. 如果第三步无效可以执行 `git rebase --skip`
- 注意: 不要在git add 之后习惯性的执行 git commit命令

##### summary 总结:
- 如果你想要一个干净的，没有merge commit的线性历史树，那么你应该选择git rebase
- 如果你想保留完整的历史记录，并且想要避免重写commit history的风险，你应该选择使用git merge
