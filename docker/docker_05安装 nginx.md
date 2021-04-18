# docker 安装 nginx

- 获取镜像`docker pull nginx`
- 查看镜像 `docker images`
- 使用镜像创建容器 `docker run --name nginx -p 80:80 -d nginx`  
```shell
-- name 容器命名
-v 映射目录
-d 设置容器后台运行
-p 本机端口映射 将容器的80端口映射到本机的80端口
```

- 访问相关ip,说明 访问成功

## 将nginx关键目录映射到本机

- 创建目录

```shell
mkdir -p /home/nginx/www /home/nginx/logs /home/nginx/conf
```

>**www**: nginx存储网站网页的目录
>
>**logs**: nginx日志目录
>
>**conf**: nginx配置文件目录

- 查看nginx-test容器id `docker ps -a`
- 将nginx-test容器配置文件copy到本地

```shell
docker cp 00774db6eb8b:/etc/nginx/nginx.conf /home/nginx/conf
```

- 清除以前的示例容器: 

```shell
docker stop id
docker rm id
```



- 创建新nginx容器nginx-web,并将**www,logs,conf**目录映射到本地：

```shell
docker run -d -p 80:80 --name nginx-web -v /home/nginx/www:/usr/share/nginx/html -v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v /home/nginx/logs:/var/log/nginx nginx
```



