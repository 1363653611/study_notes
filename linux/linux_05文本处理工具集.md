---
title: 文本处理工具集
date: 2021-02-09 15:14:10
tags:
  - LINUX
categories:
  - LINUX
topdeclare: true
reward: true
---

## Linux下使用Shell处理文本时最常用的工具

###  01 find 文件查找

1 . 查找txt和pdf文件

```shell
find . ( -name "*.txt" -o -name "*.pdf" ) -print
```

2.  正则方式查找.txt和pdf

```shell
find . -regex  ".*(.txt|.pdf)$"
```

-iregex：忽略大小写的正则

3.  否定参数

查找所有非txt文本

```shell
find . ! -name "*.txt" -print
```

<!--more-->

4.  指定搜索深度

打印出当前目录的文件（深度为1）

```shell
find . -maxdepth 1 -type f
```

5. 定制搜索

按类型搜索：

```shell
find . -type d -print  //只列出所有目录-type f 文件 / l 符号链接
```

按时间搜索：

```shell
-atime 访问时间 (单位是天，分钟单位则是-amin，以下类似）
-mtime 修改时间 （内容被修改）
-ctime 变化时间 （元数据或权限变化）
```

最近7天被访问过的所有文件：

```shell
find . -atime 7 -type f -print
```

按大小搜索：

w字 k M G

寻找大于2k的文件

```shell
find . -type f -size +2k
```

按权限查找：

```shell
find . -type f -perm 644 -print //找具有可执行权限的所有文件
```

按用户查找：

```shell
find . -type f -user weber -print// 找用户weber所拥有的文件
```

6.  找到后的后续动作

删除：

删除当前目录下所有的swp文件：

```shell
find . -type f -name "*.swp" -delete
```

执行动作（强大的exec）

```shell
find . -type f -user root -exec chown weber {} ; //将当前目录下的所有权变更为weber
```

注：{}是一个特殊的字符串，对于每一个匹配的文件，{}会被替换成相应的文件名；

eg：将找到的文件全都copy到另一个目录：

```shell
find . -type f -mtime +10 -name "*.txt" -exec cp {} OLD ;
```

7.  结合多个命令

tips: 如果需要后续执行多个命令，可以将多个命令写成一个脚本。然后 -exec 调用时执行脚本即可；

```shell
-exec ./commands.sh {} ;
```

-print的定界符

默认使用' '作为文件的定界符；

-print0 使用''作为文件的定界符，这样就可以搜索包含空格的文件；

### 02 grep 文本搜索

```shell
grep match_patten file // 默认访问匹配行
```

常用参数:

- -o 只输出匹配的文本行 VS -v 只输出没有匹配的文本行
- -c 统计文件中包含文本的次数



```shell
grep -c "text" filename
```

- -n 打印匹配的行号
- -i 搜索时忽略大小写
- -l 只打印文件名

1 在多级目录中对文本递归搜索(程序员搜代码的最爱）：

```shell
grep "class" . -R -n
```

2 匹配多个模式

```shell
grep -e "class" -e "vitural" file
```

3 grep输出以作为结尾符的文件名：（-z）

```shell
grep "test" file* -lZ| xargs -0 rm
```

4 xargs 命令行参数转换

xargs 能够将输入数据转化为特定命令的命令行参数；这样，可以配合很多命令来组合使用。比如grep，比如find；

将多行输出转化为单行输出

```shell
cat file.txt| xargs
```

是多行文本间的定界符

将单行转化为多行输出

```shell
cat single.txt | xargs -n 3
```

-n：指定每行显示的字段数

xargs参数说明

- -d 定义定界符 （默认为空格 多行的定界符为 ）
- -n 指定输出为多行
- -I {} 指定替换字符串，这个字符串在xargs扩展时会被替换掉,用于待执行的命令需要多个参数时

eg：

```shell
cat file.txt | xargs -I {} ./command.sh -p {} -1
```

-0：指定为输入定界符

eg：统计程序行数

```shell
find source_dir/ -type f -name "*.cpp" -print0 |xargs -0 wc -l
```

### 03 sort 排序 :指定顺序显示文本

字段说明：

- -n 按数字进行排序 VS -d 按字典序进行排序
- -r 逆序排序
- -k N 指定按第N列排序

eg：

```shell
sort -nrk 1 data.txtsort -bd data // 忽略像空格之类的前导空白字符
```

sort可用于对文本进行排序并显示，默认为字典升序。
例如有一段文本test.txt内容如下：

```shell
vim
count
fail
help
help
dead
apple
```

- 升序显示文本

```shell
ort test.txt
apple
count
dead
fail
help
help
vim
```

- 降序:相关参数 -r

```shell
sort -r test.txt
vim
help
help
fail
dead
count
apple
```

- 去掉重复的行

我们可以观察到，前面的help有两行，如果我们不想看到重复的行呢？可以使用参数-u，例如：

```shell
sort -u test.txt
apple
count
dead
fail
help
vim
```

- 按照数字排序

如果按照字典排序，10将会在2的前面，因此我们需要按照数字大小排序：

```shell
sort -n file
```





### 04 uniq 消除重复行

常用命令

```shell
uniq file  --去除重复的行
uniq -c file --去除重复的行，并显示重复次数
uniq -d file --只显示重复的行
uniq -u file --只显示出现一次的行
uniq -i file --忽略大小写，去除重复的行
uniqe -w 10 file --认为前10个字符相同，即为重复
```



消除重复行

```shell
sort unsort.txt | uniq
```

统计各行在文件中出现的次数

```shell
sort unsort.txt | uniq -c
```

找出重复行

```shell
sort unsort.txt | uniq -d
```

可指定每行中需要比较的重复内容：-s 开始位置 -w 比较字符数

### 05 用 tr 进行转换

通用用法

```shell
echo 12345 | tr '0-9' '9876543210' //加解密转换，替换对应字符cat text| tr '    ' ' '  //制表符转空格
```

tr删除字符

```shell
cat file | tr -d '0-9' // 删除所有数字
```

-c 求补集

```shell
cat file | tr -c '0-9' //获取文件中所有数字cat file | tr -d -c '0-9 '  //删除非数字数据
```

tr压缩字符

tr -s 压缩文本中出现的重复字符；最常用于压缩多余的空格

```shell
cat file | tr -s ' '
```

字符类

tr中可用各种字符类：

- alnum：字母和数字
- alpha：字母
- digit：数字
- space：空白字符
- lower：小写
- upper：大写
- cntrl：控制（非可打印）字符

print：可打印字符

使用方法：tr [:class:] [:class:]

```shell
tr '[:lower:]' '[:upper:]'
```

### 06 cut 按列切分文本

截取文件的第2列和第4列：

```shell
cut -f2,4 filename
```

去文件除第3列的所有列：

```shell
cut -f3 --complement filename
```

-d 指定定界符：

```shell
cat -f2 -d";" filename
```

cut 取的范围

- N- 第N个字段到结尾
- -M 第1个字段为M
- N-M N到M个字段

cut 取的单位

- -b 以字节为单位
- -c 以字符为单位
- -f 以字段为单位（使用定界符）

eg:

```shell
cut -c1-5 file //打印第一到5个字符cut -c-2 file  //打印前2个字符
```

### 07 paste 按列拼接文本

将两个文本按列拼接到一起;

```shell
cat file1
12
cat file2
colin
book
paste file1 file2
1 colin
2 book
```

默认的定界符是制表符，可以用-d指明定界符

```shell
paste file1 file2 -d ","
1,colin
2,book
```

### 08 wc 统计行和字符的工具

```shell
wc -l file // 统计行数wc -w file // 统计单词数wc -c file // 统计字符数
```

### 09 sed 文本替换利器

sed是一个流编辑器，功能非常强大。

显示匹配关键字行

```shell
-- 查看包含某些关键字的日志行
sed -n "/string/p" logFile
```

打印指定行

```shell
sed -n "1,5p" logFile --打印第1到5行
sed -n '3,5{=;p}' logFile --打印3到5行，并且打印行号
sed -n "10p" logFIle  --打印第10行
```

首处替换

```shell
sed 's/text/replace_text/' file   //替换每一行的第一处匹配的text
```

全局替换

```shell
sed 's/text/replace_text/g' file
```

默认替换后，输出替换后的内容，如果需要直接替换原文件,使用-i：

```shell
sed -i 's/text/repalce_text/g' file
```

移除空白行：

```shell
sed '/^$/d' file
```

变量转换

已匹配的字符串通过标记&来引用.

```shell
echo this is en example | seg 's/w+/[&]/g'
$>[this]  [is] [en] [example]
```

子串匹配标记

第一个匹配的括号内容使用标记 来引用

```shell
sed 's/hello([0-9])//'
```

双引号求值

sed通常用单引号来引用；也可使用双引号，使用双引号后，双引号会对表达式求值：

```shell 
sed 's/$var/HLLOE/' 
```

当使用双引号时，我们可以在sed样式和替换字符串中指定变量；

```shell
p=patten
r=replaced 
echo "line con a patten" | sed "s/$p/$r/g"
$>line con a replaced
```

其它示例

字符串插入字符：将文本中每行内容（PEKSHA） 转换为 PEK/SHA

```shell
sed 's/^.{3}/&//g' file
```

### 10 awk 数据流处理工具

awk脚本结构

```shell
awk ' BEGIN{ statements } statements2 END{ statements } '
```

工作方式

1.执行begin中语句块；

2.从文件或stdin中读入一行，然后执行statements2，重复这个过程，直到文件全部被读取完毕；

3.执行end语句块；

print 打印当前行

使用不带参数的print时，会打印当前行;

```shell
echo -e "line1 line2" | awk 'BEGIN{print "start"} {print } END{ print "End" }' 
```

print 以逗号分割时，参数以空格定界;

```shell
echo | awk ' {var1 = "v1" ; var2 = "V2"; var3="v3";print var1, var2 , var3; }'$>v1 V2 v3
```

使用-拼接符的方式（""作为拼接符）;

```shell
echo | awk ' {var1 = "v1" ; var2 = "V2"; var3="v3";print var1"-"var2"-"var3; }'$>v1-V2-v3
```

特殊变量：`NR NF $0 $1 $2`

- NR:表示记录数量，在执行过程中对应当前行号；

- NF:表示字段数量，在执行过程总对应当前行的字段数；

- - $0:这个变量包含执行过程中当前行的文本内容；
  - $1:第一个字段的文本内容；
  - $2:第二个字段的文本内容；

```shell
echo -e "line1 f2 f3 line2 line 3" | awk '{print NR":"$0"-"$1"-"$2}'
```

打印每一行的第二和第三个字段：

```shell
awk '{print $2, $3}' file
```

统计文件的行数：

```shell
awk ' END {print NR}' file
```

累加每一行的第一个字段：

```shell
echo -e "1 2 3 4 " | awk 'BEGIN{num = 0 ;print "begin";} {sum += $1;} END {print "=="; print sum }'
```

传递外部变量

```shell
var=1000echo | awk '{print vara}' vara=$var -- 输入来自stdinawk '{print vara}' vara=$var file -- 输入来自文件
```

用样式对awk处理的行进行过滤

```shell
awk 'NR < 5' --行号小于5
awk 'NR==1,NR==4 {print}' file --行号等于1和4的打印出来
awk '/linux/' --包含linux文本的行（可以用正则表达式来指定，超级强大）
awk '!/linux/' --不包含linux文本的行
```

设置定界符

使用-F来设置定界符（默认为空格）

```shell
awk -F: '{print $NF}' /etc/passwd
```

读取命令输出

使用getline，将外部shell命令的输出读入到变量cmdout中；

```shell
echo | awk '{"grep root /etc/passwd" | getline cmdout; print cmdout }' 
```

在awk中使用循环

```shell
for(i=0;i<10;i++)
{print $i;}
for(i in array)
{print array[i];}
```

eg:

以逆序的形式打印行：(tac命令的实现）

```shell
seq 9|
awk ' {lifo[NR] = $0; lno=NR}
END{ for(;lno>-1;lno--){print lifo[lno];}
} '
```

awk实现head、tail命令

```shell
head:  
awk 'NR<=10{print}' filename
tail:  
awk '{buffer[NR%10] = $0;} END{for(i=0;i<11;i++){  print buffer[i %10]} } ' filename
```

打印指定列

awk方式实现：

```shell
ls -lrt | awk '{print $6}'
```

cut方式实现

```shell
ls -lrt | cut -f6
```

打印指定文本区域

确定行号

```shell
seq 100| awk 'NR==4,NR==6{print}'
```

确定文本

打印处于startpattern 和endpattern之间的文本；

```shell
awk '/start_pattern/, /end_pattern/' filename
-- eg:
seq 100 | awk '/13/,/15/'
cat /etc/passwd| awk '/mai.*mail/,/news.*news/'
```

awk常用内建函数

```shell
-- index(string,search_string):返回search_string在string中出现的位置sub(regex,replacement_str,string):将正则匹配到的第一处内容替换为replacement_str;match(regex,string):检查正则表达式是否能够匹配字符串；length(string)：返回字符串长度
echo | awk '{"grep root /etc/passwd" | getline cmdout; print length(cmdout) }' 
```

printf 类似c语言中的printf，对输出进行格式化

eg：

```shell
seq 10 | awk '{printf "->%4s ", $1}'
```

迭代文件中的行、单词和字符

1.  迭代文件中的每一行

while 循环法

```shell
while read line;
do
echo $line;
done < file.txt
```

改成子shell:

```shell
cat file.txt | (while read line;do echo $line;done)
```

awk法：

```shell
cat file.txt| awk '{print}'
```

2. 迭代一行中的每一个单词

```shell
for word in $line;
do 
echo $word;
done
```

 

3.  迭代每一个字符

`${string:startpos:numof_chars}：`从字符串中提取一个字符；(bash文本切片）${word}:返回变量word的长度

```shell
for((i=0;i<${word};i++))
do
echo ${word:i:1);
done
```

### 11 cat  文本显示

```shell
cat file  --全文本显示在终端
cat -n file --显示全文本，并显示行号
-- cat也可用作合并文件: 将file1 file2的内容合并写到file3中
cat file1 file2 >file3
```

### 12 tac 倒序显示全部文本

```shell
-- tac是cat倒过来的写法，tac以行为单位，倒序显示全文本内容。
tac file
```

### 13  more 分页显示文本

cat将整个文本内容输出到终端。那么也就带来一个问题，如果文本内容较多，前面的内容查看将十分不便。而more命令可以分页显示。

```shell
-- 显示内容
more file
```

之后，就可以使用按键来查看文本。常用按键如下：

> 回车  --向下n行，默认为1行
> 空格  --向下滚动一屏
> b   --向上滚动一屏
> =   --输出当前行号
> :f   --输出当前文件名和当前行号
> q   --退出

从指定行开始显示

```shell
-- 从第10行开始显示file的内容
more +10 file
-- 从匹配的字符串行开始显示:从有string的行的前两行开始file的内容
more +/string file
```

### 14 less 任意浏览搜索文本

 less命令的基本功能和more没有太大差别，但是 **less命令可以向前浏览文件，而more只能向后浏览文件**，同时less还拥有更多的搜索功能。
常见使用方法：

```shell
less file     --浏览file
less -N file  --浏览file，并且显示每行的行号
less -m file  --浏览file，并显示百分比
```

常用按键如下：

>f    --向前滚动一屏
>b    --向后滚动一屏
>回车或j  --向前移动一行
>k    --向后移动一行
>G    --移动到最后一行
>g    --移动到第一行
>/string --向下搜索string，n查看下一个，N查看上一个结果
>? string --向上搜索string，n查看下一个，N查看上一个结果
>q  --退出

相比more命令，less命令能够搜索匹配需要的字符串。另外，less还能在多个文件间切换浏览：

```shell
less file1 file2 file3
:n     --切换到下一个文件
:p     --切换到上一个文件
:x     --切换到第一个文件
:d     --从当前列表移除文件
```

### 15 head 显示头部文件

head命令的作用就像它的名字一样，用于显示文件的开头部分文本. 常见用法如下：

```shell
head -n 100 file --显示file的前100行
head -n -100 file --显示file的除最后100行以外的内容。  
```

### 16  tail 显示文本尾部的内容

和head命令类似，只不过tail命令用于读取文本尾部部分内容：

```shell
tail -100 file  --显示file最后100行内容
tail -n +100 file  --从第100行开始显示file内容   

-- tail还有一个比较实用的用法，用于实时文本更新内容。比如说，有一个日志文件正在写，并且实时在更新，就可以用命令：
tail -f logFile
```

### 17 vi 文本编辑器

```shell
最基本用法
vi  somefile.4
1 首先会进入“一般模式”，此模式只接受各种快捷键，不能编辑文件内容
2 按i键，就会从一般模式进入编辑模式，此模式下，敲入的都是文件内容
3 编辑完成之后，按Esc键退出编辑模式，回到一般模式；
4 再按：，进入“底行命令模式”，输入wq命令，回车即可

常用快捷键
一些有用的快捷键（在一般模式下使用）：
a   在光标后一位开始插入
A   在该行的最后插入
I   在该行的最前面插入
gg   直接跳到文件的首行
G    直接跳到文件的末行
dd    删除一行
3dd   删除3行
yy    复制一行
3yy   复制3行
p     粘贴
u     undo
v        进入字符选择模式，选择完成后，按y复制，按p粘贴
ctrl+v   进入块选择模式，选择完成后，按y复制，按p粘贴
shift+v  进入行选择模式，选择完成后，按y复制，按p粘贴

查找并替换
1 显示行号
:set nu
2 隐藏行号
:set nonu
3 查找关键字
:/you       -- 效果：查找文件中出现的you，并定位到第一个找到的地方，按n可以定位到下一个匹配位置（按N定位到上一个）
4 替换操作
:s/sad/bbb    查找光标所在行的第一个sad，替换为bbb
:%s/sad/bbb      查找文件中所有sad，替换为bbb
```





## 文件权限

### linux文件权限的描述格式解读

```shell
drwxr-xr-x      （也可以用二进制表示  111 101 101  -->  755）

d：标识节点类型（d：文件夹   -：文件  l:链接）
r：可读   w：可写    x：可执行 
第一组rwx：  -- 表示这个文件的拥有者对它的权限：可读可写可执行
第二组r-x：  -- 表示这个文件的所属组用户对它的权限：可读，不可写，可执行
第三组r-x：  -- 表示这个文件的其他用户（相对于上面两类用户）对它的权限：可读，不可写，可执行

```

###  修改文件权限

```shell
chmod g-rw haha.dat		-- 表示将haha.dat对所属组的rw权限取消
chmod o-rw haha.dat		 -- 表示将haha.dat对其他人的rw权限取消
chmod u+x haha.dat		 -- 表示将haha.dat对所属用户的权限增加x
chmod a-x haha.dat               -- 表示将haha.dat对所用户取消x权限

-- 也可以用数字的方式来修改权限
chmod 664 haha.dat   
-- 就会修改成   rw-rw-r--
-- 如果要将一个文件夹的所有内容权限统一修改，则可以-R参数
chmod -R 770 aaa/
```

### 修改文件所有权

```shell
-- 只有root权限能执行
chown angela  aaa		--改变所属用户
chown :angela  aaa		--改变所属组
chown angela:angela aaa/	--同时修改所属用户和所属组

```





#　参考

[史上最全的 Linux Shell 文本处理工具集锦](https://mp.weixin.qq.com/s/xP6JCYczPpgSln941sPflA)