#!/usr/bin/env bash
#方法1：利用循环技巧，如果成功就跳出当前循环，否则执行到最后一行
#!/bin/bash
check_url() {
    HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $1)
    if [ $HTTP_CODE -eq 200 ]; then
        continue
    fi
}
URL_LIST="www.baidu.com www.agasgf.com"
for URL in $URL_LIST; do
    check_url $URL
    check_url $URL
    check_url $URL
    echo "Warning: $URL Access failure!"
done

# 方法2：错误次数保存到变量
#!/bin/bash
URL_LIST="www.baidu.com www.agasgf.com"
for URL in $URL_LIST; do
    FAIL_COUNT=0
    for ((i=1;i<=3;i++)); do
        HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $URL)
        if [ $HTTP_CODE -ne 200 ]; then
            let FAIL_COUNT++
        else
            break
        fi
    done
    if [ $FAIL_COUNT -eq 3 ]; then
        echo "Warning: $URL Access failure!"
    fi
done


#方法3：错误次数保存到数组
#!/bin/bash
URL_LIST="www.baidu.com www.agasgf.com"
for URL in $URL_LIST; do
    NUM=1
    while [ $NUM -le 3 ]; do
        HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $URL)
        if [ $HTTP_CODE -ne 200 ]; then
            FAIL_COUNT[$NUM]=$IP  #创建数组，以$NUM下标，$IP元素
            let NUM++
        else
            break
        fi
    done
    if [ ${#FAIL_COUNT[*]} -eq 3 ]; then
        echo "Warning: $URL Access failure!"
        unset FAIL_COUNT[*]    #清空数组
    fi
done