#!/usr/bin/env bash
# 检查URL可用性
#方法1：
check_url() {
    HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $1)
    if [ $HTTP_CODE -ne 200 ]; then
        echo "Warning: $1 Access failure!"
    fi
}
#方法2：
check_url() {
if ! wget -T 10 --tries=1 --spider $1 >/dev/null 2>&1; then
#-T超时时间，--tries尝试1次，--spider爬虫模式
        echo "Warning: $1 Access failure!"
    fi
}

# 使用方法：check_url www.baidu.com

