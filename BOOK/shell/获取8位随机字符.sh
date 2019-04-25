#获取随机8位字符串：
#!/bin/bash
#方法1：471b94f2
echo $RANDOM |md5sum |cut -c 1-8

#方法2：vg3BEg==
openssl rand -base64 4

#方法3：ed9e032c
cat /proc/sys/kernel/random/uuid |cut -c 1-8
