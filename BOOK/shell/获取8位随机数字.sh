#!/usr/bin/env bash
# 方法1：23648321
# cksum：打印CRC效验和统计字节
echo $RANDOM |cksum |cut -c 1-8

#方法2：38571131
openssl rand -base64 4 |cksum |cut -c 1-8

#方法3：69024815
date +%N |cut -c 1-8
