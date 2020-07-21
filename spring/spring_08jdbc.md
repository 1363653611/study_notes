---
title: Spring_08 spring JDBC
date: 2020-07-20 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
## springJDBC 数据库链接
- jdbc （java data base connection）， 用于执行sql 的api。为多种关系型数据库提供统一访问入口。

<!--more-->

## JDBC 的原理及流程
1. 引入jdbc 驱动程序包
2. 加载驱动程序：`class.forname("com.mysql.jdbc.Driver");`
3. 创建链接对象：`Connection connection= DriverManager.getConnection（"连接数据库的URL","用户名","密码"）` (URL＝协议名＋IP 地址（域名）＋端口＋数据库名称)
4. 创建statment 对象,Statment 类主要用于执行静态的sql语句，并返回他获取到的结果对象。`Statement statament = connection.createStatement();`
5. 调用statment 对象执行相应的sql 语句。
    - `execuUpdate()` 用来执行更新，包括：插入，删除。 `staternent.excuteUpdate ("I NSERT INTO staff (narne , age , sex , address , depart , worklen , wage ) " + " VALUES ('Tornl' , 321,'M','china' ,'Personnel','3' ,'3000')")`
    - `executeQuery()` 数据查询，查询结果会得到 ResultSet(查询返回结果集)对象，`ResultSet resultset = staternent.executeQuery ("select * from staff");`
6. 关闭数据库链接。 `connection.close()`.

## spring 使用 jdbc 链接数据库
### 配置数据源
```xml
 <bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.cj.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/test?serverTimezone=UTC&amp;characterEncoding=utf-8"/>
        <property name="username" value="root"/>
        <property name="password" value="123456"/>
        <!--连接池启动时的起始值-->
        <property name="initialSize" value="1"/>
        <!--最大空闲值,当经过一个高峰时间后,连接池可以将一部分不用的连接慢慢释放,一直减到maxIdle为止-->
        <property name="maxIdle" value="300"/>
        <!--最小空闲值:当空闲数量少于一定的阀值时,连接池就会预先申请一些连接,以免洪峰时来不及申请-->
        <property name="minIdle" value="1"/>
    </bean>
```

### 配置 `jdbcTemplate` bean
```xml
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"/>
    </bean>
```

### dao 层引入 jdbcTemplate 使用

### 源码分析
> （略）
