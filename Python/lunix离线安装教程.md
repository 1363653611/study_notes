## lunix 离线安装教程 ##

1. 下载 lunix 适合版本的安装包:
2. 将 安装包解压到 指定目录 `tar -zxvf Python-3.7.4.tgz -C /usr/local/python`
3. 接着进入`/usr/local/python/Python-3.7.4/`路径，执行 `./configure  --prefix=/usr/local/python`

  * 报错问题:`no acceptable C compiler found in $PATH
See 'config.log' for more details`

  * 解决方案: https://blog.csdn.net/Sky786905664/article/details/83819034
    - __安装rmp包:__
      ```
      mpfr-3.1.1-4.el7.x86_64.rpm
      libmpc-1.0.1-3.el7.x86_64.rpm
      kernel-headers-3.10.0-123.el7.x86_64.rpm
      glibc-headers-2.17-55.el7.x86_64.rpm
      glibc-devel-2.17-55.el7.x86_64.rpm
      cpp-4.8.2-16.el7.x86_64.rpm
      gcc-4.8.2-16.el7.x86_64.rpm
      ```
      - rpm包可以从这两个个地方获取：
        http://mirrors.163.com/centos/6/os/x86_64/Packages/
        http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/

    - __安装:__
      + 分布安装
      ```
      rpm -ivh mpfr-3.1.1-4.el7.x86_64.rpm
      rpm -ivh libmpc-1.0.1-3.el7.x86_64.rpm
      rpm -ivh kernel-headers-3.10.0-123.el7.x86_64.rpm
      rpm -ivh glibc-headers-2.17-55.el7.x86_64.rpm
      rpm -ivh glibc-devel-2.17-55.el7.x86_64.rpm
      rpm -ivh cpp-4.8.2-16.el7.x86_64.rpm
      rpm -ivh gcc-4.8.2-16.el7.x86_64.rpm
      ```
      + 也可以使用如下命令统一安装（我本人是使用统一安装成功的）：
      `rpm -Uvh *.rpm --nodeps --force`

    - __验证__

        都安装成功后，验证:`gcc -v`
4. ` make && make install `
  - 报错问题:` make: 未找到命令`:(_<red>未解决</red>_)
  - 解决方案:https://blog.csdn.net/JENREY/article/details/100116798
    - 安装make:
      + 下载地址:http://ftp.gnu.org/gnu/make/
      + 执行操作:
      ```
        wget http://ftp.gnu.org/gnu/make/make-4.2.tar.gz
        tar -zxvf make-4.2.tar.gz
        cd make-4.2
        ./configure
        make
        make install
        ln -s -f /usr/local/bin/make  /usr/bin/make
      ```
