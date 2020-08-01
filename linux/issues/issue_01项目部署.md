## linux 下 mysql 大小写敏感问题配置
- mysql是通过lower_case_table_names变量来处理大小写问题的
- mysql在Linux下数据库名、表名、列名、表别名大小写规则如下：  
1、数据库名与表名严格区分大小写；  
2、表别名严格区分大小写；  
3、列名和列别名在所有情况下都是忽略大小写的；  
4、变量名也是严格区分大小写的； 

- 登录mysql `mysql -uroot -pxingqier` <uroot是用户名，proot是密码>
- 查看当前MYSQL字符集[在mysql命令行模式下执行]：`show variables like 'character%'`

- 查看大小写敏感 `show Variables like '%table_names'`
    - 查询结果：显示0 是开启大小敏感的  
    - lower_case_table_names=0（默认）区分大小写，lower_case_table_names=1表示不区分大小写
- 更改解决
- 修改/etc/my.cnf,在[mysqld]后边添加lower_case_table_names=1 重启mysql服务，这时已设置成功
```lunix
vi /etc/my.cnf
```
- 重新启动mysql服务  
    __启动方式__
    1. 使用 service 启动：sudo service mysql start
    2. 使用 mysqld 脚本启动：sudo /etc/inint.d/mysqld start
    3. 使用 safe_mysqld 启动：sudo safe_mysqld& 

    __停止__
    1. 使用 service 启动：sudo service mysql stop
    2. 使用 mysqld 脚本启动：sudo /etc/inint.d/mysqld stop
    3. mysqladmin shutdown

    __重启__
    1. 使用 service 启动：sudo service mysql restart
    2. 使用 mysqld 脚本启动：sudo /etc/inint.d/mysqld restart
### 参考：
- https://mp.weixin.qq.com/s/E3h7QHZdkNIsAyzmGNiv-Q


## ry  权限管理系统启动：在ry 文件夹下：`java -jar ruoyi-admin.jar`

## 索引长度过长 ERROR 1071 (42000): Specified key was too long; max key length is 767 bytes
- 问题原因：mysql 在创建单列索引的时候对列的长度是有限制的 myisam和innodb存储引擎下长度限制分别为1000 bytes和767 bytes。(注意bytes和character的区别)
- 对于innodb存储引擎，多列索引的长度限制如下：

每个列的长度不能大于767 bytes；所有组成索引列的长度和不能大于3072 bytes（使用innodb存储引擎，smallint 占2个bytes，timestamp占4个bytes，utf8字符集。utf8字符集下，一个character占三个byte）
- 查看 `show variables like 'innodb_large_prefix';`
- 修改
- 解决方法为：
- （1） 使用innodb引擎； 
- （2） 启用innodb_large_prefix选项，将约束项扩展至3072byte；
- （3） 重新创建数据库
- my.cnf配置：
 ```lunix
 default-storage-engine=INNODB
 innodb_large_prefix=on
 ```

- 一般情况下不建议使用这么长的索引，对性能有一定影响；

## index column size too large. the maximum column size is 767 bytes

```sql
set global innodb_file_format = BARRACUDA;
set global innodb_large_prefix = ON;
# 对脚本进行修改，添加ROW_FORMAT=DYNAMIC
create table test (........) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
```
