#!/usr/bin/env bash
# 显示当前 目录
owd
# 显示系统时间
date +%Y-%d-%m
#加减也可以 month | year
date +%Y-%m-%d  --date="-1 day"
## 修改时间
date -s "2016-07-28 16:12:00"


# 查看谁在线
who
# 查看最近的登陆历史记录
last

# 关机（必须用root用户）
shutdown -h now  ## 立刻关机
shutdown -h +10  ##  10分钟以后关机
shutdown -h 12:00:00  ##12点整的时候关机
halt   #  等于立刻关机

# 重启
shutdown -r now # 立即重启


#清屏
clear ## 或者用快捷键  ctrl + l

# 退出当前进程
ctrl+c # 有些进程q也可以退出

# 进程操作
ctrl+z # 挂起当前进程

bg jobid ## 让进程在后台继续执行
fg job id ## 让进程回到前台

echo # 输出： 相当于java中的System.out.println(xxx)

## 目录操作
ls /   ## 查看根目录下的子节点（文件夹和文件）信息
ls -al ##  -a是显示隐藏文件   -l是以更详细的列表形式显示
ls -l  ##有一个别名： ll    可以直接使用ll  <是两个L>

# 切换工作目录
cd  /home/hadoop    ## 切换到用户主目录
cd ~     ## 切换到用户主目录
cd -     ##  回退到上次所在的目录
cd  #什么路径都不带，则回到用户的主目录

# 创建文件夹
mkdir aaa     ## 这是相对路径的写法
mkdir  /data    ## 这是绝对路径的写法
mkdir -p  aaa/bbb/ccc   ## 级联创建目录

# 删除文件夹
rmdir  aaa   ## 可以删除空目录
rm  -r  aaa   ## 可以把aaa整个文件夹及其中的所有子节点全部删除
rm  -rf  aaa   ## 强制删除aaa

#修改文件夹名称
mv  aaa  boy
# mv 本质上是移动
mv  install.log  aaa/  #将当前目录下的install.log 移动到aaa文件夹中去

#rename 可以用来批量更改文件名
rename .txt .txt.bak *

# 文件操作
#创建一个新文件
touch  somefile.1
## 利用重定向“>”的功能，将一条指令的输出结果写入到一个文件中，会覆盖原文件内容，如果指定的文件不存在，则会创建出来
echo "hi,boy" > somefile.2

# 将一条指令的输出结果追加到一个文件中，不会覆盖原文件内容
echo "hi baby" >> somefile.2

最基本用法
vi  somefile.4
1 #首先会进入“一般模式”，此模式只接受各种快捷键，不能编辑文件内容
2 #按i键，就会从一般模式进入编辑模式，此模式下，敲入的都是文件内容
3 #编辑完成之后，按Esc键退出编辑模式，回到一般模式；
4 #再按：，进入“底行命令模式”，输入wq命令，回车即可

#常用快捷键
#一些有用的快捷键（在一般模式下使用）：
a   #在光标后一位开始插入
A   #在该行的最后插入
I   #在该行的最前面插入
gg   #直接跳到文件的首行
G    #直接跳到文件的末行
dd    #删除一行
3dd   #删除3行
yy    #复制一行
3yy   #复制3行
p     #粘贴
u     undo
v        #进入字符选择模式，选择完成后，按y复制，按p粘贴
ctrl+v   #进入块选择模式，选择完成后，按y复制，按p粘贴
shift+v  #进入行选择模式，选择完成后，按y复制，按p粘贴

#查找并替换
1 显示行号
:set nu
2 隐藏行号
:set nonu
3 查找关键字
:/you       ## 效果：查找文件中出现的you，并定位到第一个找到的地方，按n可以定位到下一个匹配位置（按N定位到上一个）
4 替换操作
:s/sad/bbb    #查找光标所在行的第一个sad，替换为bbb
:%s/sad/bbb      #查找文件中所有sad，替换为bbb
