---
title: elasticsearch 安装
date: 2021-01-13 12:14:10
tags:
  - docker
categories:
  - docker
reward: true
---


# elasticsearch 安装

## 拉去镜像 

- docker pull elasticsearch

### 查看版本

```shell
docker image inspect nginx:latest | grep -i version
```

发现是 latest 版本是5.6 的，所以指定版本拉去`docker pull elasticsearch:7.6.2`



## docker 单机版启动

### 制作配置文件

```shell
http.host: 0.0.0.0
# Uncomment the following lines for a production cluster deployment
#transport.host: 0.0.0.0
#discovery.zen.minimum_master_nodes: 1
# 跨域配置
http.cors.enabled: true
http.cors.allow-origin: "*"
```

### 启动命令

```shell
docker run -d --name zbcn-es -p 9200:9200 -p 9300:9300 -v /home/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data:/usr/share/elasticsearch/data -e "discovery.type=single-node" -e "ES_JAVA_OPTS=-Xms64m -Xmx256m" elasticsearch:7.6.2
```

### es 的中文分词

```shell
# 进入docker 容器
docker exec -it zbcn-es /bin/bash
# 下载中文分词(注意要和es 版本统一)
./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
```

- 安装中文分词报错

```shell
# 问题现象
-> Installing https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
-> Downloading https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
[=================================================] 100%??
-> Failed installing https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
-> Rolling back https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
-> Rolled back https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
Exception in thread "main" java.lang.IllegalStateException: duplicate plugin: - Plugin information:
Name: analysis-ik
Description: IK Analyzer for Elasticsearch
Version: 7.6.2
Elasticsearch Version: 7.6.2
Java Version: 1.8
Native Controller: false
Extended Plugins: []
 * Classname: org.elasticsearch.plugin.analysis.ik.AnalysisIkPlugin
        at org.elasticsearch.plugins.PluginsService.readPluginBundle(PluginsService.java:405)
        at org.elasticsearch.plugins.PluginsService.findBundles(PluginsService.java:386)
        at org.elasticsearch.plugins.PluginsService.getPluginBundles(PluginsService.java:379)
        at org.elasticsearch.plugins.InstallPluginCommand.jarHellCheck(InstallPluginCommand.java:844)
        at org.elasticsearch.plugins.InstallPluginCommand.loadPluginInfo(InstallPluginCommand.java:821)
        at org.elasticsearch.plugins.InstallPluginCommand.installPlugin(InstallPluginCommand.java:866)
        at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:254)
        at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:224)
        at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86)
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:125)
        at org.elasticsearch.cli.MultiCommand.execute(MultiCommand.java:91)
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:125)
        at org.elasticsearch.cli.Command.main(Command.java:90)
        at org.elasticsearch.plugins.PluginCli.main(PluginCli.java:47)


# 问题原因:时多次安装中文分词导致重复导致

# 解决方案
# 删除 /usr/share/elasticsearch/plugins/.installing-XXXXXXXXXXXXXXXXXXX. 文件
ll -al # 查看文件,包含隐藏文件
# 删除隐藏文件
rm -rf .installing-XXXXXXXXXXXXXXXXXXX
# 重新安装

# 参考
- https://cloudnull.io/2018/12/fixing-duplicate-plugin-issues-in-elasticsearch/

```



- 重启 es 容器

## 启动异常

```shell
# 错误截取信息
"stacktrace": ["org.elasticsearch.bootstrap.StartupException: ElasticsearchException[failed to bind service]; nested: AccessDeniedException[/usr/share/elasticsearch/data/nodes];",
# 原因是 elasticsearch/data 文件夹的权限不够导致
# 解决方案(赋值最高权限)
chmod -777 /elasticsearch/data
```



## 查看ElasticSearch内部信息

```shell
docker inspect zbcn-es 
```



## docker 集群模式启动

### 制作配置文件

- 配置文件位置`/usr/share/elasticsearch/data`

- Master 节点

```yml
http.host: 0.0.0.0
#集群名称 所有节点要相同
cluster.name: "estest"
#本节点名称
node.name: master
#作为master节点
node.master: true
#是否存储数据
node.data: true
bootstrap.system_call_filter: false
transport.host: 0.0.0.0  
discovery.zen.minimum_master_nodes: 1
```

- slave 节点

```yml
http.host: 0.0.0.0
#集群名称 所有节点要相同 
cluster.name: "estest"
#子节点名称
node.name: salve1
#不作为master节点
node.master: false
node.data: true
bootstrap.system_call_filter: false
transport.host: 0.0.0.0  
discovery.zen.minimum_master_nodes: 1  
# 注意salve节点的discovery.zen.ping.unicast.hosts设置为esmaster:9300,这里的esmaster是master节点的docker容器名字
discovery.zen.ping.unicast.hosts: ["esmaster:9300"]
```



### master 启动容器

```shell
docker run -d --name esmaster --ulimit nofile=65536:131072 -p 9200:9200 -p 9300:9300 -v /home/docker/elasticsearch/elasticsearchmaster.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data/master:/usr/share/elasticsearch/data -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" elasticsearch
```



```shell
--name es # 容器名称
# 避免容器启动时会报bootstrap checks failed异常
--ulimit nofile=65536:131072
# 端口映射：暴露出容器的9200,9300端口到宿主机的9200,9300端口
-p 9200:9200 -p 9300:9300

# 挂载卷到容器中，其实就是设置容器配置文件关联上面写好的配置文件，容器存储数据关联到宿主机的外部文件中
-v /home/docker/elasticsearch/elasticsearchmaster.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data/master:/usr/share/elasticsearch/data

# 设置容器内Java虚拟机的内存大小
-e "ES_JAVA_OPTS=-Xms512m -Xmx512m"
# 以上命令也可以写为如下，经测试不会出问题
-e ES_JAVA_OPTS="-Xms512m -Xmx512m"
```

### salve 容器启动

```shell
docker run -d --name essalve1 --ulimit nofile=65536:131072 --link esmaster:esmaster -v C:/work/docker_volume/elasticsearch/elasticsearchsalve1.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v C:/work/docker_volume/elasticsearch/data/salve1:/usr/share/elasticsearch/data -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" elasticsearch
```

- 主要是使用--link esmaster:esmaster指令，来连接master容器，别的和master容器启动参数基本一样。



# elasticsearch 头 ElasticSearch-Head

为什么要安装`ElasticSearch-Head`呢，原因是需要有一个管理界面进行查看`ElasticSearch`相关信息

## 拉去镜像

```shell
docker pull mobz/elasticsearch-head:5
```

## 运行容器

```shell
docker run -d --name es_admin -p 9100:9100 mobz/elasticsearch-head:5
```

# 安装 Kinaba

- 下载解压安装包，一定要装与ES相同的版本

## 拉去镜像

```shell
docker pull kibana

docker pull kibana:7.6.2
```

## 运行容器

```shell
docker run --name zbcn-kibana -e ELASTICSEARCH_HOSTS=http://服务器地址:9200 -p 5601:5601 -d kibana

docker run --name zbcn-kibana -e ELASTICSEARCH_HOSTS=http://服务器地址:9200 -p 5601:5601 -d kibana:7.6.2

docker run --name zbcn-kibana -v /home/kibana/kibana.yml:/usr/share/kibana/config/kibana.yml
 -e ELASTICSEARCH_HOSTS=http://服务器地址:9200 -p 5601:5601 -d kibana:7.6.2


```

## 运行

访问： http://自己的IP地址:5601/app/kibana



# 添加用户名密码

## es 的elasticsearch.yml文件添加权限信息

```shell
# 开启登录验证(可选)
http.cors.allow-headers: Authorization
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
```

## 添加用户名密码

### 执行设置用户名和密码的命令,这里需要为4个用户分别设置密码: elastic, kibana, logstash_system,beats_system

```shell
# 执行方式
bin/elasticsearch-setup-passwords interactive

# 展示
Initiating the setup of passwords for reserved users elastic,kibana,logstash_system,beats_system.
You will be prompted to enter passwords as the process progresses.
Please confirm that you would like to continue [y/N]y
Enter password for [elastic]: 
passwords must be at least [6] characters long
Try again.
Enter password for [elastic]: 
Reenter password for [elastic]: 
Passwords do not match.
Try again.
Enter password for [elastic]: 
Reenter password for [elastic]: 
Enter password for [kibana]: 
Reenter password for [kibana]: 
Enter password for [logstash_system]: 
Reenter password for [logstash_system]: 
Enter password for [beats_system]: 
Reenter password for [beats_system]: 
Changed password for user [kibana]
Changed password for user [logstash_system]
Changed password for user [beats_system]
Changed password for user [elastic]
```

### 修改用户名密码

```shell
curl -H "Content-Type:application/json" -XPOST -u elastic 'http://127.0.0.1:9200/_xpack/security/user/elastic/_password' -d '{ "password" : "123456" }'
```



## 修改kibana配置

```shell
vim ../config/kibana.yml
elasticsearch.username: "elastic"
elasticsearch.password: "passwd"
```

说明: 外部配置文件的在 配置文件的 kibana.yml 中

#  参考：

- https://www.imooc.com/article/49888?block_id=tuijian_wz
- https://www.cnblogs.com/balloon72/p/13177872.html
- https://blog.csdn.net/luckyxl029/article/details/80066412
- 添加校验权限:https://blog.csdn.net/QiaoRui_/article/details/97375237





