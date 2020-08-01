## easticsearch windows 版安装教程

### 背景

  springboot2.x 版本的 `spring-boot-starter-data-elasticsearch` 的java api 版本不兼容 7.0 一下版本的elasticsearch. 启动和查询时报错. 所以需要安装 7.0 以上版本的es.  
  本安装教程时基于 `v7.5.2` 版本的.

### 安装过程

1. 下载 windows 版本的 es 安装包. 下载地址:https://www.elastic.co/cn/downloads/elasticsearch
2. 解压 下载的zip包  `elasticsearch-7.5.2-windows-x86_64.zip`
3. 修改 elasticsearch.yml, 路径为: `elasticsearch-7.5.2\config\elasticsearch.yml`
  - 文件后加入:
    ```yml
    action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*
    http.cors.enabled: true
    http.cors.allow-origin: "*"
    node.master: true
    node.data: true
    ```
  - 放开network.host: 192.168.0.1的注释并改为network.host: 0.0.0.0（这里如果不修改的话，外网无法访问与是否安装head无关）
  - 放开cluster.name；node.name；http.port的注释
  - 放开 `discovery.seed_hosts: ["127.0.0.1","[::1]"]`
  - 放开 `cluster.initial_master_nodes: ["node-1"]`

4. 进入bin 目录，运行 `elasticsearch.bat`
5. 浏览器输入 localhost:9200/ 出现一下界面，ElasticSearch 我们已经成功安装了

### 安装 中文分词器
- 官方貌似没有中文分词器,大神自己开源的一个. github地址为:https://github.com/medcl/elasticsearch-analysis-ik
- 需要自己clone 源代码.
- 然后在此目录下打开dos窗口，执行命令mvn clean package进行打包.然后进入`\target\releases`下可以看到打的zip包
- 在你所安装es的所在目录下的的plugins下创建analysis-ik文件夹
- 将上面打的zip包拷贝到analysis-ik文件夹下并将zip压缩包解压到此
![拷贝文件](./imgs/2019050819183991.png)
- 最后重新启动elasticsearch，可以启动说明安装成功
- 不需要修改Elasticsearch配置文件。Elasticsearch的配置文件路径为elasticsearch.yml,之前的老版本需要在文件最后加入如下内容：index.analysis.analyzer.ik.type : "ik"，新的版本不需要
- 测试ik分词是否安装成功时，使用的是ik_smart而不是ik。查看文档，现在支持ik_smart与ik_max_word。

### 安装 header

略

### 参考

- 官方安装说明: https://www.elastic.co/guide/en/elasticsearch/reference/7.5/install-elasticsearch.html
