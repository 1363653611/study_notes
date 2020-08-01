## 查看可用的 MySQL 版本
 - 访问 MySQL 镜像库地址：https://hub.docker.com/_/mysql?tab=tags 。
 - 通过 命令: `docker search mysql`

## 拉去镜像 `docker pull mysql:latest`

## 查看本地镜像 `docker images`

## 运行容器: `docker run -itd --name mysql-zbcn -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql`
`docker run -p 3306:3306 --name mysql-zbcn -v /usr/local/mysql/conf:/etc/mysql/conf.d -v /usr/local/mysql/logs:/logs -v /usr/local/mysql/data:/mysql_data -e MYSQL_ROOT_PASSWORD=123456 -d 9228ee8bac7a --lower_case_table_names=1 --sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'`


##  MySql版本问题sql_mode=only_full_group_by 问题解决
- 查看sql_mode `select @@sql_mode`
- 去掉ONLY_FULL_GROUP_BY，重新设置值
```sql
set @@sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
set sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
--  或者
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
```
参数说明:
- -p 3306:3306 ：映射容器服务的 3306 端口到宿主机的 3306 端口，外部主机可以直接通过 宿主机ip:3306 访问到 MySQL 的服务。
- MYSQL_ROOT_PASSWORD=123456：设置 MySQL 服务 root 用户的密码。