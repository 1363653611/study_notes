---
title: 01 LINUX基本命令
date: 2019-12-09 15:14:10
tags:
 - LINUX
categories:
 - LINUX
topdeclare: true
reward: true
---

# 基本操作
1. man 命令
  - 功能: 显示指定命令的用法和描述
  - 语法： `man <command name>`
  - eg： `man ls`

2. `touch`，`cat` 和 `less` 命令
  - A. touch
    - 功能：创建大小为0 的任意类型文件。
    - 语法： `touch <filename>`
    - eg：`touch demo.txt`
  - B. cat 命令用来查看文件内容。该命令只能查看，不能编辑。该命令不支持键盘上下键翻页
    - 语法：`cat <filename>`
    - eg：cat demo.txt

  - C. less 命令
    - 功能：浏览文件，less命令非常快。并且支持上下键查看文件的开头和结尾。

    - 语法： `less  <filename>`
    - eg：`less demo.txt`

  - D.more 命令
    - 功能：more 命令和less命令的功能相似。但是more命令只能用‘enter’ 键来实现文件的向下翻页，该命令不支持回退
    - 语法：`more <filename>`
    - eg：more demo.txt

3. sort 和grep命令
    - A. sort 命令用来对文件内容进行排序。
    - B grep 命令  
      - 功能：该命令非常强大，可以在文件中搜索制定格式的字符串。并对其进行标准输出。
      - 语法：`grep  <search string> <file name>`
      - eg：`grep "Mathew" test.txt`

4. cut 命令
  - 功能： 可以使用列或者分割符提取出文件中的指定部分。如果要列出文件中的全部内容，可以使用“-c”选项。
  - eg：列出test.txt文件中第1，2列的全部内容
    语法为： `cut -c1-2 test.txt`

  - 功能：如果希望从文件中读取指定的字符串，那么你可以使用分割符选项“-d” 和 “-f” 选项选中列。

5. sed 命令
 - sed 是一种在线编辑器。它一次只能处理一行内容。处理时，把当前处理的行存储在临时的缓冲区中，称为“模式空间（pattern space）”,接着用sed处理缓冲区中的内容。处理完之后，把缓冲区中的送往屏幕。接着处理下一行，这样不断的重复，直到文件的末尾。文件内容并没用改变，除非你使用重定向存储输出。
 - 语法： `sed "s/<old-word>/<mew-word>" test.txt`
 - eg：将test.txt文件中用“michael”替换“mike”
    - `sed "s/mike/michael" test.txt`

6. tar 命令
  - 功能：利用tar 命令来压缩和解压缩文件，其中经常用到 "-cf" 和  "-xf" 选项。
  - 语法：`tar <options> <archive-name> <file/folder name>`
  - eg1：将test.txt 文件打包 （-cf 打包）`tar -cf test.tar test.txt`
  - eg2：用"-C" 选项将刚才打包好的test.tar 解压至“demo”目录 (-xf 解压) `tar -xf test.tar -C/root/demo/`

7. find 命令
  - 功能 用来检索文件，可以用"-name" 选项来检索指定名称的文件`find -name text.txt`
  - 功能： 用"/ -name" 来检索指定名称的文件夹`find / -name passwd`

8. diff命令
  - 功能：用来找出两个文件的不同点。
  - 语法： `diff <filename1> <filename2>`
  - eg1：`diff test.txt test2.txt`

9. uniq 命令
  - 功能： 偶拿过来过滤文件中的重复行
  - eg: `uniq test.txt`

10. chmod命令
  - 功能：用来改变文件的读/写/执行权限。
  - 命令说明：
  ``` tiki wiki
  4 - read permission
  2 - write permission
  1 - execute permission
  0 - no permission
  ```
  - 最高权限 `chmod 755 test.txt`

11. 开启对外端口号:
    `iptables -I INPUT -p tcp --dport 5000 -j ACCEPT`

# 常用命令



##  clear

```shell
$ clear    ## 或者用快捷键  ctrl + l
```



## grep

 - 在文件中查找，不区分大小写

    ```shell
    $ grep -i "the" demo_file
    ```

  - 输出成功匹配的行，以及该行之后的三行

  ```shell
  $ grep -A 3 -i "example" demon_text
  ```

  - 在一个文件夹中递归查询包含指定字符串的文件

  ```shell
  $ grep -r "ramesh" *
  ```

- 更多示例：Get a Grip on the Grep! – 15 Practical Grep Command Examples

  http://www.thegeekstuff.com/2009/03/15-practical-unix-grep-command-examples/
  
  

## find

- 查找指定文件名的文件(不区分大小写)

```shell
$ find -iname "myProgram.c"
```

- 对找到的文件执行某个命令

```shell
$ find -iname "myProgram.c" -exec md5sum {} \;
```

- 查找home目录下的所有空文件

```shell
$ find ~ -empty
```

- 更多示例：Mommy, I found it! — 15 Practical Linux Find Command Examples

http://www.thegeekstuff.com/2009/03/15-practical-linux-find-command-examples/



## sed

- 将Dos系统中的文件复制到Unix/Linux后，这个文件每行都会以\r\n结尾，sed可以轻易将其转换为Unix格式的文件，使用\n结尾的文件

```shell
$ sed 's/.$//' filename
```

- 反转文件内容并输出

```shell
$ sed -n '1!G; h; p' filename
```

- 为非空行添加行号

  ```shell
  $ sed '/./=' thegeekstuff.txt | sed 'N; s/\n/ /'
  ```

- 更多示例：Advanced Sed Substitution Examples

  http://www.thegeekstuff.com/2009/10/unix-sed-tutorial-advanced-sed-substitution-examples/

## awk

- 删除重复行

```shell
$ awk '!($0 in array) { array[$0]; print}' temp
```

- 打印`/etc/passwd`中所有包含同样的uid和gid的行

```shell
$ awk -F ':' '$3=$4' /etc/passwd
```

- 打印文件中的指定部分的字段

```shell
$ awk '{print $2,$5;}' employee.txt
```

- 更多示例：8 Powerful Awk Built-in Variables – FS, OFS, RS, ORS, NR, NF, FILENAME, FNR

  http://www.thegeekstuff.com/2010/01/8-powerful-awk-built-in-variables-fs-ofs-rs-ors-nr-nf-filename-fnr/

## vim

```shell
# 打开文件并跳到第10行
$ vim +10 filename.txt
# 打开文件跳到第一个匹配的行
$ vim +/search-term filename.txt
# 以只读模式打开文件
$ vim -R /etc/passwd
```

更多示例：How To Record and Play in Vim Editor

http://www.thegeekstuff.com/2009/01/vi-and-vim-macro-tutorial-how-to-record-and-play/

## diff

```shell
# 比较的时候忽略空白符
$ diff -w name_list.txt name_list_new.txt
```



## sort

```shell
# 以升序对文件内容排序
$ sort names.txt
# 以降序对文件内容排序
$ sort -r names.txt
# 以第三个字段对/etc/passwd的内容排序
$ sort -t: -k 3n /etc/passwd | more
```

## export

- 输出跟字符串oracle匹配的环境变量

```shell
$ export | grep ORCALE
declare -x ORACLE_BASE="/u01/app/oracle"
declare -x ORACLE_HOME="/u01/app/oracle/product/10.2.0"
declare -x ORACLE_SID="med"
declare -x ORACLE_TERM="xterm"
```

- 设置全局环境变量

```shell
$ export ORACLE_HOME=/u01/app/oracle/product/10.2.0
```

## xargs

```shell
# 将所有图片文件拷贝到外部驱动器
$ ls *.jpg | xargs -n1 -i cp {} /external-hard-drive/directory
# 将系统中所有jpd文件压缩打包
$ find / -name *.jpg -type f -print | xargs tar -cvzf images.tar.gz
# 下载文件中列出的所有url对应的页面
$ cat url-list.txt | xargs wget –c
```

##  ls

- 以易读的方式显示文件大小(显示为MB,GB…)

```shell
$ ls -lh
-rw-r----- 1 ramesh team-dev 8.9M Jun 12 15:27 arch-linux.txt.gz
```

- 以最后修改时间升序列出文件

  ```shell
  $ ls -ltr
  ```

- 在文件名后面显示文件类型

  ```shell
  $ ls -F
  ```

  更多示例：Unix LS Command: 15 Practical Examples

  http://www.thegeekstuff.com/2009/07/linux-ls-command-examples/

## pwd

输出当前工作目录:**查看当前所在的工作目录的全路径**

## cd

```shell
cd -可以在最近工作的两个目录间切换
```

使用 **shopt -s cdspell** 可以设置自动对 cd 命令进行拼写检查

更多示例：6 Awesome Linux cd command Hacks

http://www.thegeekstuff.com/2008/10/6-awesome-linux-cd-command-hacks-productivity-tip3-for-geeks/

# 服务操作

##  crontab

```shell
# 查看某个用户的 crontab 入口
$ crontab -u john -l
# 设置一个每十分钟执行一次的计划任务
*/10 * * * * /home/ramesh/check-disk-space
```

更多示例：Linux Crontab: 15 Awesome Cron Job Examples

http://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/

## service

- service 命令用于运行 System V init 脚本，这些脚本一般位于/etc/init.d文件下，这个命令可以直接运行这个文件夹里面的脚本，而不用加上路径

```shell
## 查看服务状态
$ service ssh status
# 查看所有服务状态
$ service --status-all
# 重启服务
$ service ssh restart
```

## ps

ps命令用于显示正在运行中的进程的信息，ps命令有很多选项，这里只列出了几个

```shell
# 查看当前正在运行的所有进程
$ ps -ef | more
# 以树状结构显示当前正在运行的进程，H选项表示显示进程的层次结构
$ ps -efH | more
```

## free

这个命令用于显示系统当前内存的使用情况，包括已用 __内存__ 、可用内存和交换内存的情况

- 默认情况下free会以字节为单位输出内存的使用量

```shell
$ free
             total       used       free     shared    buffers     cached
Mem:       3566408    1580220    1986188          0     203988     902960
-/+ buffers/cache:     473272    3093136
Swap:      4000176          0    4000176
```

- 如果你想以其他单位输出内存的使用量，需要加一个选项，-g为GB，-m为MB，-k为KB，-b为字节

```shell
$ free -g
             total       used       free     shared    buffers     cached
Mem:             3          1          1          0          0          0
-/+ buffers/cache:          0          2
Swap:            3          0          3
```

## top

top命令会显示当前系统中占用资源最多的一些进程（默认以CPU占用率排序）如果你想改变排序方式，可以在结果列表中点击O（大写字母O）会显示所有可用于排序的列，这个时候你就可以选择你想排序的列

```shell
Current Sort Field:  P  for window 1:Def
Select sort field via field letter, type any other key to return

  a: PID        = Process Id              v: nDRT       = Dirty Pages count
  d: UID        = User Id                 y: WCHAN      = Sleeping in Function
  e: USER       = User Name               z: Flags      = Task Flags
  ........
```

- 如果只想显示某个特定用户的进程，可以使用-u选项

```shell
$ top -u oracle
```

更多示例：Can You Top This? 15 Practical Linux Top Command Examples

http://www.thegeekstuff.com/2010/01/15-practical-unix-linux-top-command-examples/

## df

显示文件系统的磁盘使用情况，默认情况下df -k 将以字节为单位输出磁盘的使用量

```shell
$ df -k
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda1             29530400   3233104  24797232  12% /
/dev/sda2            120367992  50171596  64082060  44% /home
```

使用 `-h` 选项可以以更符合阅读习惯的方式显示磁盘使用量

```shell
$ df -h
Filesystem                  Size   Used  Avail Capacity  iused      ifree %iused  Mounted on
/dev/disk0s2               232Gi   84Gi  148Gi    37% 21998562   38864868   36%   /
devfs                      187Ki  187Ki    0Bi   100%      648          0  100%   /dev
map -hosts                   0Bi    0Bi    0Bi   100%        0          0  100%   /net
map auto_home                0Bi    0Bi    0Bi   100%        0          0  100%   /home
/dev/disk0s4               466Gi   45Gi  421Gi    10%   112774  440997174    0%   /Volumes/BOOTCAMP
//app@izenesoft.cn/public  2.7Ti  1.3Ti  1.4Ti    48%        0 18446744073709551615    0%   /Volumes/public
```

使用 `-T` 选项显示文件系统类型

```shell
$ df -T
Filesystem    Type   1K-blocks      Used Available Use% Mounted on
/dev/sda1     ext4    29530400   3233120  24797216  12% /
/dev/sda2     ext4   120367992  50171596  64082060  44% /home
```

## kill

kill 用于终止一个进程。一般我们会先用ps -ef查找某个进程得到它的进程号，然后再使用kill -9 进程号终止该进程。你还可以使用killall、pkill、xkill来终止进程

```shell
$ ps -ef | grep vim
ramesh    7243  7222  9 22:43 pts/2    00:00:00 vim
$ kill -9 7243
```

更多示例：4 Ways to Kill a Process – kill, killall, pkill, xkill

http://www.thegeekstuff.com/2009/12/4-ways-to-kill-a-process-kill-killall-pkill-xkill/

## mysql

- mysql可能是Linux上使用最广泛的数据库，即使你没有在你的服务器上安装mysql，你也可以使用mysql客户端连接到远程的mysql服务器

```shell
# 连接一个远程数据库，需要输入密码
$ mysql -u root -p -h 192.168.1.2
# 连接本地数据库
$ mysql -u root -p
```

你也可以在命令行中输入数据库密码，只需要在-p后面加上密码作为参数，可以直接写在p后面而不用加空格

# 文件操作

## rm

```shell
# 删除文件前先确认
$ rm -i filename.txt
# 在文件名中使用shell的元字符会非常有用。删除文件前先打印文件名并进行确认
$ rm -i file*
# 递归删除文件夹下所有文件，并删除该文件夹
$ rm -r example
```

## cp

```shell
# 拷贝文件1到文件2，并保持文件的权限、属主和时间戳
$ cp -p file1 file2
# 拷贝file1到file2，如果file2存在会提示是否覆盖
$ cp -i file1 file2
```

## mv

```shell
# 将文件名file1重命名为file2，如果file2存在则提示是否覆盖
$ mv -i file1 file2
```

注意如果使用-f选项则不会进行提示

-v会输出重命名的过程，当文件名中包含通配符时，这个选项会非常方便

```shell
$ mv -v file1 file2
```

## cat

你可以一次查看多个文件的内容，下面的命令会先打印file1的内容，然后打印file2的内容

```shell
$ cat file1 file2
# -n命令可以在每行的前面加上行号
$ cat -n /etc/logrotate.conf
/var/log/btmp {
missingok
3	    monthly
4	    create 0660 root utmp
5	    rotate 1
6 }
```

## tail

```shell
# tail命令默认显示文件最后的10行文本
$ tail filename.txt
# 你可以使用-n选项指定要显示的行数
$ tail -n N filename.txt
# 你也可以使用-f选项进行实时查看，这个命令执行后会等待，如果有新行添加到文件尾部，它会继续输出新的行，在查看日志时这个选项会非常有用。你可以通过CTRL-C终止命令的执行
$ tail -f log-file
```

更多示例：3 Methods To View tail -f output of Multiple Log Files in One Terminal

http://www.thegeekstuff.com/2009/09/multitail-to-view-tail-f-output-of-multiple-log-files-in-one-terminal/

## less

这个命名可以在不加载整个文件的前提下显示文件内容，在查看大型日志文件的时候这个命令会非常有用

```shell
$ less huge-log-file.log
```

当你用less命令打开某个文件时，下面两个按键会给你带来很多帮助，他们用于向前和向后滚屏

> CTRL+F – forward one window
> CTRL+B – backward one window

更多示例：Unix Less Command: 10 Tips for Effective Navigation

http://www.thegeekstuff.com/2010/02/unix-less-command-10-tips-for-effective-navigation/

## mount

- 如果要挂载一个文件系统，需要先创建一个目录，然后将这个文件系统挂载到这个目录上

```shell
$ mkdir /u01
$ mount /dev/sdb1 /u01
```

- 也可以把它添加到fstab中进行自动挂载，这样任何时候系统重启的时候，文件系统都会被加载

```shell
/dev/sdb1 /u01 ext2 defaults 0 2
```

## awk

 数据流处理工具

```shell
# awk脚本结构
awk ' BEGIN{ statements } statements2 END{ statements } '
```

工作方式

1. 执行begin中语句块；

2. 从文件或stdin中读入一行，然后执行statements2，重复这个过程，直到文件全部被读取完毕；

3. 执行end语句块；

##  rename

```shell
## rename 可以用来批量更改文件名
[root@localhost aaa]# ll
total 0
-rw-r--r--. 1 root root 0 Jul 28 17:33 1.txt
-rw-r--r--. 1 root root 0 Jul 28 17:33 2.txt
-rw-r--r--. 1 root root 0 Jul 28 17:33 3.txt
[root@localhost aaa]# rename .txt .txt.bak *
[root@localhost aaa]# ll
total 0
-rw-r--r--. 1 root root 0 Jul 28 17:33 1.txt.bak
-rw-r--r--. 1 root root 0 Jul 28 17:33 2.txt.bak
-rw-r--r--. 1 root root 0 Jul 28 17:33 3.txt.bak
```



# 压缩文件

## tar   

- 创建一个新的 tar 文件
```shell
$ tar cvf archive_name.tar dirName/
# 上面的tar cvf选项不提供任何压缩。要在tar归档文件上使用gzip压缩，请使用z选项，如下所示。
$ tar cvzf archive_name.tar.gz dirname/
# 创建一个bzip2 tar存档
$ tar cvfj archive_name.tar.bz2 dirname/
```

以上命令说明:

> - c – 创建一个新的文档  create a new archive
> - v –  详细列出要处理的文件 verbosely list files which are processed.
> - f –  存档文件名 following is the archive file name
> - z – 通过 gzip 过滤文件 filter the archive through gzip

__NOTE__

>  I like to keep the ‘cvf’ (or tvf, or xvf) option unchanged for all archive creation (or view, or extract) and add additional option at the end, which is easier to remember. i.e cvf for archive creation, cvfz for compressed gzip archive creation, cvfj for compressed bzip2 archive creation etc., For this method to work properly, don’t give – in front of the options.

> **gzip vs bzip2**: bzip2 解压和压缩比 gzip 话费更多时间. 压缩后bzip2 比 gzip占用更小的空间.

- 解压tar

  ```shell
  $ tar xvf archive_name.tar
  # 使用选项xvzf提取压缩后的tar存档（* .tar.gz）
  $ tar xvfz archive_name.tar.gz
  # 使用选项xvjf提取bzip压缩的tar存档（* .tar.bz2）
  $ tar xvfj archive_name.tar.bz2
  ```

  命令说明：

  - x – 解压文件 从压缩包 extract files from archive

- 查看 tar

  ```shell
  $ tar tvf archive_name.tar
  ```

  命令说明：

  - t 查看压缩文件中的文件

- 更多示例：The Ultimate Tar Command Tutorial with 10 Practical Examples

  http://www.thegeekstuff.com/2010/04/unix-tar-command-examples/


## gzip

```shell
# 创建一个 *.gz 的压缩文件
$ gzip test.txt
# 解压 *.gz 文件
$ gzip -d test.txt.gz
```

- 显示压缩的比率

```shell
$ gzip -l *.gz
compressed        uncompressed  ratio uncompressed_name
23709               97975  75.8% asp-patch-rpms.txt
```

## bzip2

```shell
# 创建 *.bz2 压缩文件
$ bzip2 test.txt
# 解压 *.bz2 文件
$ bzip2 -d test.txt.bz2
```

更多示例：BZ is Eazy! bzip2, bzgrep, bzcmp, bzdiff, bzcat, bzless, bzmore examples

http://www.thegeekstuff.com/2010/10/bzcommand-examples/

##  uzip

```shell
# 解压 *.zip 文件
$ unzip test.zip
# 查看 *.zip 文件的内容
$ unzip -l jasper.zip
Archive:  jasper.zip
Length     Date   Time    Name
--------    ----   ----    ----
40995  11-30-98 23:50   META-INF/MANIFEST.MF
32169  08-25-98 21:07   classes_
15964  08-25-98 21:07   classes_names
10542  08-25-98 21:07   classes_ncomp
```

# 文件夹

## mkdir

```shell
# 在home目录下创建一个名为temp的目录
$ mkdir ~/temp
# 使用-p选项可以创建一个路径上所有不存在的目录
$ mkdir -p dir1/dir2/dir3/dir4/
```

# 系统权限

##  chmod

chmod用于改变文件和目录的权限

给指定文件的属主和属组所有权限(包括读、写、执行)

```shell
$ chmod ug+rwx file.txt
# 删除指定文件的属组的所有权限
$ chmod g-rwx file.txt
# 修改目录的权限，以及递归修改目录下面所有文件和子目录的权限
$ chmod -R ug+rwx file.txt
```

更多示例：7 Chmod Command Examples for Beginners

http://www.thegeekstuff.com/2010/06/chmod-command-examples/

## 	chown

-  chown用于改变文件属主和属组

```shell
# 同时将某个文件的属主改为oracle，属组改为db
$ chown oracle:dba dbora.sh
# 使用-R选项对目录和目录下的文件进行递归修改
$ chown -R oracle:dba /home/oracle
```

## passwd

```shell
# passwd用于在命令行修改密码，使用这个命令会要求你先输入旧密码，然后输入新密码
$ passwd
# 超级用户可以用这个命令修改其他用户的密码，这个时候不需要输入用户的密码
$ passwd USERNAME
# passwd还可以删除某个用户的密码，这个命令只有root用户才能操作，删除密码后，这个用户不需要输入密码就可以登录到系统
$ passwd -d USERNAME
```

# 网络

## ifconfig

ifconfig用于查看和配置Linux系统的网络接口

```shell
# 查看所有网络接口及其状态
$ ifconfig -a
# 使用up和down命令启动或停止某个接口
$ ifconfig eth0 up
$ ifconfig eth0 down
```

更多示例：Ifconfig: 7 Examples To Configure Network Interface

http://www.thegeekstuff.com/2009/03/ifconfig-7-examples-to-configure-network-interface/

## ping

```shell
#ping一个远程主机，只发5个数据包
$ ping -c 5 gmail.com
```

更多示例：Ping Tutorial: 15 Effective Ping Command Examples

http://www.thegeekstuff.com/2009/11/ping-tutorial-13-effective-ping-command-examples/

##  wget

```shell
# 使用wget从网上下载软件、音乐、视频
$ wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.2.1.tar.gz
# 下载文件并以指定的文件名保存文件
$ wget -O taglist.zip http://www.vim.org/scripts/download_script.php?src_id=7701
```

更多示例：The Ultimate Wget Download Guide With 15 Awesome Examples

http://www.thegeekstuff.com/2009/09/the-ultimate-wget-download-guide-with-15-awesome-examples/



# 系统

## uname

- uname可以显示一些重要的系统信息，例如内核名称、主机名、内核版本号、处理器类型之类的信息

```shell
$ uname -a
Linux john-laptop 2.6.32-24-generic #41-Ubuntu SMP Thu Aug 19 01:12:52 UTC 2010 i686 GNU/Linux
```

##  whereis

- 当你不知道某个命令的位置时可以使用whereis命令，下面使用whereis查找ls的位置

```shell
whereis ls
ls: /bin/ls /usr/share/man/man1/ls.1.gz /usr/share/man/man1p/ls.1p.gz
```

- 当你想查找某个可执行程序的位置，但这个程序又不在whereis的默认目录下，你可以使用-B选项，并指定目录作为这个选项的参数。下面的命令在/tmp目录下查找lsmk命令

```shell
$ whereis -u -B /tmp -f lsmk
lsmk: /tmp/lsmk
```

## whatis

```shell
# wathis显示某个命令的描述信息
$ whatis ls
ls		(1)  - list directory contents
$ whatis ifconfig
ifconfig (8)         - configure a network interface
```

## locate

locate命名可以显示某个指定文件（或一组文件）的路径，它会使用由updatedb创建的数据库

下面的命令会显示系统中所有包含crontab字符串的文件

```shell
$ locate crontab
/etc/anacrontab
/etc/crontab
/usr/bin/crontab
/usr/share/doc/cron/examples/crontab2english.pl.gz
/usr/share/man/man1/crontab.1.gz
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man5/crontab.5.gz
/usr/share/vim/vim72/syntax/crontab.vim
```

## man

```shell
# 显示某个命令的man页面
$ man crontab
# 有些命令可能会有多个man页面，每个man页面对应一种命令类型
$ man SECTION-NUMBER commandname
```

man页面一般可以分为8种命令类型

1.  用户命令
2.  系统调用
3.  c库函数
4.  设备与网络接口
5.  文件格式
6.  游戏与屏保
7.  环境、表、宏
8.  系统管理员命令和后台运行命令

例如，我们执行 `whatis crontab`，你可以看到 `crontab` 有两个命令类型1和5，所以我们可以通过下面的命令查看命令类型5的man页面

```shell
$ whatis crontab
crontab (1)          - maintain crontab files for individual users (V3)
crontab (5)          - tables for driving cron

$ man 5 crontab
```

## su

- su命令用于切换用户账号，超级用户使用这个命令可以切换到任何其他用户而不用输入密码

```shell
$ su - USERNAME
```

- 用另外一个用户名执行一个命令

  ```shell
  # 用户john使用raj用户名执行ls命令，执行完后返回john的账号
  [john@dev-server]$ su - raj -c 'ls'
  [john@dev-server]$
  # 用指定用户登录，并且使用指定的shell程序，而不用默认的
  $ su -s 'SHELLNAME' USERNAME
  ```

## yum

```shell
# 使用yum安装apache
$ yum install httpd
# 更新apache
$ yum update httpd
# 卸载/删除apache
$ yum remove httpd
```

## rpm

```shell
# 使用rpm安装apache
$ rpm -ivh httpd-2.2.3-22.0.1.el5.i386.rpm
# 更新 apache
$ rpm -uvh httpd-2.2.3-22.0.1.el5.i386.rpm
# 卸载/删除apache
$ rpm -ev httpd
```

更多示例：RPM Command: 15 Examples to Install, Uninstall, Upgrade, Query RPM Packages

http://www.thegeekstuff.com/2010/07/rpm-command-examples/

##  date 

查看当前系统的时间

```shell
# 查看当前系统的时间
$ date +%Y-%m-%d
# 加减也可以 month | year
$ date +%Y-%m-%d  --date="-1 day"

# 设置系统日期
$ date -s "01/31/2010 23:59:53"
# 当你修改了系统时间，你需要同步硬件时间和系统时间
$ hwclock –systohc
$ hwclock --systohc –utc
```

## who

**查看有谁在线（哪些人登陆到了服务器）**

```shell
# 查看当前在线
$ who  
# last 查看最近的登陆历史记录
$ last
```

## ssh

- 登陆到远程主机

```shell
$ ssh -l jsmith remotehost.example.com
```

- 显示客户机的版本

```shell
$ ssh -V
```

- 更多示例：5 Basic Linux SSH Client Commands

http://www.thegeekstuff.com/2008/05/5-basic-linux-ssh-client-commands/

## shutdown

```shell
# 关闭计算机并且立即关机
$ shutdown -h now
# 10分钟后关机
$ shutdown -h +10
# 重启
$ shutdown -r now
$ reboot   # 等于立刻重启
# 重启期间强制进行系统检查
$ shutdown -Fr now
```

## ftp

- ftp命令和sftp命令的用法基本相似连接ftp服务器并下载多个文件

```shell
$ ftp IP/hostname
ftp> mget *.html
```

- 显示远程主机上文件列表

```shell
ftp> mls *.html -
/ftptest/features.html
/ftptest/index.html
/ftptest/othertools.html
/ftptest/samplereport.html
/ftptest/usage.html
```

更多示例：FTP and SFTP Beginners Guide with 10 Examples

http://www.thegeekstuff.com/2010/06/ftp-sftp-tutorial/

## systemctl 

```shell
# 启动nfs服务
$ systemctl start nfs-server.service
# 设置nfs服务开机自启动
$ systemctl enable nfs-server.service
# 停止nfs服务开机自启动
$ systemctl disable nfs-server.service
# 查看nfs服务当前状态
$ systemctl status nfs-server.service
# 重新启动nfs服务
$ systemctl restart nfs-server.service
# 查看所有已启动的服务
$ systemctl list -units --type=service
```

实例：

```shell
# 开启防火墙
$ iptables -I INPUT -p tcp --dport 22 -j ACCEPT 
# 如果仍然有问题，就可能是SELinux导致的，关闭SElinux：修改/etc/selinux/config文件中的SELINUX=""为disabled，然后重启，彻底关闭防火墙：
$ sudo systemctl status firewalld.service
$ sudo systemctl stop firewalld.service          
$ sudo systemctl disable firewalld.service        //sudo是临时使用root权限执行命令
```

## echo

控制台打印:相当于java中System.out.println(userName)

```shell
[root@localhost ~]# a="hi boy"
[root@localhost ~]# echo a
a
[root@localhost ~]# echo $a
hi boy
```

# 功能

## 系统管理操作

#### 挂载外部存储设备

```shell
#可以挂载光盘、硬盘、磁带、光盘镜像文件等
# 挂载光驱
mkdir   /mnt/cdrom      #创建一个目录，用来挂载
#将设备/dev/cdrom挂载到 挂载点 ：  /mnt/cdrom中
mount -t iso9660 -o ro /dev/cdrom /mnt/cdrom/     

# 挂载光盘镜像文件（.iso文件）
mount -t iso9660 -o loop  /home/hadoop/Centos-6.7.DVD.iso /mnt/centos
#注：挂载的资源在重启后即失效，需要重新挂载。要想自动挂载，可以将挂载信息设置到/etc/fstab配置文件中，如下：
/dev/cdrom              /mnt/cdrom              iso9660 defaults        0 0

# 卸载 umount
umount /mnt/cdrom

# 存储空间查看
df -h
```

#### 统计文件或文件夹的大小

```shell
du -sh  /mnt/cdrom/packages
df -h    # 查看磁盘的空间
```

#### 系统服务管理

```shell
service sshd status
service sshd stop 
service sshd start
service sshd restart
```

#### 系统启动级别管理

```shell
vi  /etc/inittab
       # Default runlevel. The runlevels used are:
       #   0 - halt (Do NOT set initdefault to this)
       #   1 - Single user mode
       #   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
       #   3 - Full multiuser mode
       #   4 - unused
       #   5 - X11
       #   6 - reboot (Do NOT set initdefault to this)
       #
       id:3:initdefault:
       ## 通常将默认启动级别设置为：3
```

#### 进程管理

```shell
top
free
ps -ef | grep ssh
kill -9
```

###  基本的用户管理

#### 添加用户

```shell
#添加一个用户：
useradd spark
passwd  spark     #根据提示设置密码；
#即可

#删除一个用户：
userdel -r spark     #加一个-r就表示把用户及用户的主目录都删除
```

```shell
# 添加一个tom用户，设置它属于users组，并添加注释信息
#分步完成：
useradd tom
usermod -g users tom
usermod -c "hr tom" tom

# 一步完成：
useradd -g users -c "hr tom" tom

# 设置tom用户的密码
passwd tom
```

#### 修改用户

```shell
# 修改tom用户的登陆名为tomcat
usermod -l tomcat tom

# 将tomcat添加到sys和root组中
usermod -G sys,root tomcat

# 查看tomcat的组信息
groups tomcat
```

####  用户组操作

```shell
#添加一个叫america的组
groupadd america

#将jerry添加到america组中
usermod -g america jerry

#将tomcat用户从root组和sys组删除
gpasswd -d tomcat root
gpasswd -d tomcat sys

#将america组名修改为am
groupmod -n am america
```

#### 为用户配置sudo权限

```shell
#用root编辑 
vi /etc/sudoers
#在文件的如下位置，为hadoop添加一行即可
root    ALL=(ALL)       ALL     
hadoop  ALL=(ALL)       ALL

# 然后，hadoop用户就可以用sudo来执行系统级别的指令
[root@localhost ~]$ sudo useradd xiaoming
```

### 日常操作命令

#### 查看当前所在的工作目录的全路径 pwd

```shell
[root@localhost ~]# pwd
/root
```

####  查看当前系统的时间 date

```shell
[root@localhost ~]# date +%Y-%m-%d
2016-07-26

date +%Y-%m-%d  --date="-1 day" #加减也可以 month | year
2016-07-25

[root@localhost ~]# date -s "2016-07-28 16:12:00" ## 修改时间
Thu Jul 28 16:12:00 PDT 2016
```

####  查看有谁在线（哪些人登陆到了服务器）

```shell
who  #查看当前在线
[root@localhost ~]# who
hadoop   tty1         2016-07-26 00:01 (:0)
hadoop   pts/0        2016-07-26 00:49 (:0.0)
root     pts/1        2016-07-26 00:50 (192.168.233.1)

last #查看最近的登陆历史记录
[root@localhost ~]# last
root     pts/1        192.168.233.1    Tue Jul 26 00:50   still logged in   
hadoop   pts/0        :0.0             Tue Jul 26 00:49   still logged in   
hadoop   tty1         :0               Tue Jul 26 00:01   still logged in   
reboot   system boot  2.6.32-573.el6.x Tue Jul 26 07:58 - 16:23 (2+08:24)

```

####  关机/重启

```shell
#关机（必须用root用户）
shutdown -h now  ## 立刻关机
shutdown -h +10  ##  10分钟以后关机
shutdown -h 12:00:00  ##12点整的时候关机
halt   #  等于立刻关机

# 重启
shutdown -r now
reboot   # 等于立刻重启
```

####  清屏

```shell
clear    ## 或者用快捷键  ctrl + l
```

#### 退出当前进程

```shell
ctrl+c   ##有些程序也可以用q键退出
```

####  挂起当前进程

```shell
ctrl+z   ## 进程会挂起到后台
bg jobid  ## 让进程在后台继续执行
fg jobid   ## 让进程回到前台
```

### **目录操作**

#### 查看目录信息

```shell
ls /   ## 查看根目录下的子节点（文件夹和文件）信息
ls -al ##  -a是显示隐藏文件   -l是以更详细的列表形式显示
ls -l  ##有一个别名： ll    可以直接使用ll  <是两个L>
```

####  切换工作目录

```shell
cd  /home/hadoop    ## 切换到用户指定目录
cd ~     ## 切换到用户主目录
cd -     ##  回退到上次所在的目录
cd  什么路径都不带，则回到用户的主目录
```

####  创建文件夹

```shell
mkdir aaa     ## 这是相对路径的写法 
mkdir  /data    ## 这是绝对路径的写法 
mkdir -p  aaa/bbb/ccc   ## 级联创建目录
```

####  删除文件夹

```shell
rmdir  aaa   ## 可以删除空目录
rm  -r  aaa   ## 可以把aaa整个文件夹及其中的所有子节点全部删除
rm  -rf  aaa   ## 强制删除aaa
```

#### **修改文件夹名称**

```shell
mv  aaa  boy
mv本质上是移动
mv  install.log  aaa/  将当前目录下的install.log 移动到aaa文件夹中去

rename 可以用来批量更改文件名
[root@localhost aaa]# ll
total 0
-rw-r--r--. 1 root root 0 Jul 28 17:33 1.txt
-rw-r--r--. 1 root root 0 Jul 28 17:33 2.txt
-rw-r--r--. 1 root root 0 Jul 28 17:33 3.txt
[root@localhost aaa]# rename .txt .txt.bak *
[root@localhost aaa]# ll
total 0
-rw-r--r--. 1 root root 0 Jul 28 17:33 1.txt.bak
-rw-r--r--. 1 root root 0 Jul 28 17:33 2.txt.bak
-rw-r--r--. 1 root root 0 Jul 28 17:33 3.txt.bak
```

###  文件操作

#### 创建文件

```shell
touch  somefile.1       
## 创建一个空文件

echo "hi,boy" > somefile.2     
## 利用重定向“>”的功能，将一条指令的输出结果写入到一个文件中，会覆盖原文件内容，如果指定的文件不存在，则会创建出来

echo "hi baby" >> somefile.2    
## 将一条指令的输出结果追加到一个文件中，不会覆盖原文件内容
```

#### 拷贝/删除/移动

```shell
cp  somefile.1   /home/hadoop/
rm /home/hadoop/somefile.1
rm -f /home/hadoop/somefile.1
mv /home/hadoop/somefile.1 ../
```

#### 查看文件内容

```shell
cat    somefile      #一次性将文件内容全部输出（控制台）
more   somefile      #可以翻页查看, 下翻一页(空格)    上翻一页（b）   退出（q）
less   somefile      #可以翻页查看,下翻一页(空格)    上翻一页（b），上翻一行(↑)  下翻一行（↓）  可以搜索关键字（/keyword）
跳到文件末尾： G
跳到文件首行： gg
退出less ：  q

tail -10  install.log  #查看文件尾部的10行
tail +10  install.log  #查看文件 10-->末行
tail -f install.log    #小f跟踪文件的唯一inode号，就算文件改名后，还是跟踪原来这个inode表示的文件
tail -F install.log    #大F按照文件名来跟踪

head -10  install.log   #查看文件头部的10行
```

####  打包压缩

```shell
# gzip压缩
gzip a.txt

# 解压
gunzip a.txt.gz
gzip -d a.txt.gz

# bzip2压缩
bzip2 a

#解压
bunzip2 a.bz2
bzip2 -d a.bz2

#打包：将指定文件或文件夹
tar -cvf bak.tar  ./aaa
#将/etc/password追加文件到bak.tar中(r)
tar -rvf bak.tar /etc/password

#解压
tar -xvf bak.tar

#打包并压缩
tar -zcvf a.tar.gz  aaa/

#解包并解压缩(重要的事情说三遍!!!)
tar  -zxvf  a.tar.gz
#解压到/usr/下
tar  -zxvf  a.tar.gz  -C  /usr

#查看压缩包内容
tar -ztvf a.tar.gz
zip/unzip

#打包并压缩成bz2
tar -jcvf a.tar.bz2

#解压bz2
tar -jxvf a.tar.bz2
```

###  查找命令

#### **常用查找命令的使用**

```shell
#查找可执行的命令所在的路径：
which ls

#查找可执行的命令和帮助的位置：
whereis ls

#从某个文件夹开始查找文件
find / -name "hadooop*"
find / -name "hadooop*" -ls

#查找并删除
find / -name "hadooop*" -ok rm {} \;
find / -name "hadooop*" -exec rm {} \;

#查找用户为hadoop的文件
find  /usr  -user  hadoop  -ls

#查找用户为hadoop的文件夹
find /home -user hadoop -type d -ls

#查找权限为777的文件
find / -perm -777 -type d -ls

#显示命令历史
history
```

####  grep命令

```shell
#基本使用
#查询包含hadoop的行
grep hadoop /etc/password
grep aaa  ./*.txt 

# cut截取以:分割保留第七段
grep hadoop /etc/passwd | cut -d: -f7

# 查询不包含hadoop的行
grep -v hadoop /etc/passwd

#正则表达包含hadoop
grep 'hadoop' /etc/passwd

#正则表达(点代表任意一个字符)
grep 'h.*p' /etc/passwd

#正则表达以hadoop开头
grep '^hadoop' /etc/passwd

#正则表达以hadoop结尾
grep 'hadoop$' /etc/passwd

规则：
.  : 任意一个字符
a* : 任意多个a(零个或多个a)
a? : 零个或一个a
a+ : 一个或多个a
.* : 任意多个任意字符
\. : 转义.
o\{2\} : o重复两次

# 查找不是以#开头的行
grep -v '^#' a.txt | grep -v '^$' 

# 以h或r开头的
grep '^[hr]' /etc/passwd

#不是以h和r开头的
grep '^[^hr]' /etc/passwd

#不是以h到r开头的
grep '^[^h-r]' /etc/passwd
```

### 文件权限

#### linux文件权限的描述格式解读

```shell
drwxr-xr-x      （也可以用二进制表示  111 101 101  -->  755）

d：标识节点类型（d：文件夹   -：文件  l:链接）
r：可读   w：可写    x：可执行 
第一组rwx：  ## 表示这个文件的拥有者对它的权限：可读可写可执行
第二组r-x：  ## 表示这个文件的所属组用户对它的权限：可读，不可写，可执行
第三组r-x：  ## 表示这个文件的其他用户（相对于上面两类用户）对它的权限：可读，不可写，可执行

后面的9个字符划分为三段（每三个字符为一段）
第一段代表：属主权限
第二段代表：属组权限
第三段代表：其他用户权限
四种字符：
-	代表没权限		数字代表是0
r	代表读的权限		数字代表是4
w	代表写的权限		数字代表是2
x	代表可执行的权限	数字代表是1
修改权限的命令：chmod u=rwx,g=rwx,o=rwx 文件 
需求：针对yp.conf文件修改权限：u=rwx,g=rw,o=r    764

```

#### 修改文件权限

```shell
chmod g-rw haha.dat		 ## 表示将haha.dat对所属组的rw权限取消
chmod o-rw haha.dat		 ## 表示将haha.dat对其他人的rw权限取消
chmod u+x haha.dat		 ## 表示将haha.dat对所属用户的权限增加x
chmod a-x haha.dat               ## 表示将haha.dat对所用户取消x权限


也可以用数字的方式来修改权限
chmod 664 haha.dat   
就会修改成   rw-rw-r--
如果要将一个文件夹的所有内容权限统一修改，则可以-R参数
chmod -R 770 aaa/
```

####  修改文件所有权

```shell
# 只有root权限能执行
chown angela  aaa		## 改变所属用户
chown :angela  aaa		## 改变所属组
chown angela:angela aaa/	## 同时修改所属用户和所属组
```

### 网络配置

#### 主机名配置

```shell
# 查看主机名
hostname
# 修改主机名(重启后无效)
hostname hadoop
# 修改主机名(重启后永久生效) 
vi /ect/sysconfig/network
```

#### IP地址配置

```shell
#修改IP地址
# 方式一：setup
# 用root输入setup命令，进入交互式修改界面

# 方式二：修改配置文件 一般使用这种方法
# (重启后永久生效)
vi /etc/sysconfig/network-scripts/ifcfg-eth0

# 方式三：ifconfig命令
# (重启后无效)
ifconfig eth0 192.168.12.22
```

#### 网络服务管理

```shell
# 后台服务管理
service network status    #查看指定服务的状态
service network stop     #停止指定服务
service network start     #启动指定服务
service network restart   #重启指定服务
service --status-all       #查看系统中所有的后台服务

# 设置后台服务的自启配置
chkconfig   #查看所有服务器自启配置
chkconfig iptables off   #关掉指定服务的自动启动
chkconfig iptables on   #开启指定服务的自动启动
```

# 参考

