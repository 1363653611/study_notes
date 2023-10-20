```sql
# 日期求和
select date_add(current_date(), INTERVAL -5 DAY);

# 全局时区，会话时区
SELECT @@global.time_zone, @@session.time_zone;

# 当前时间对应的月末
select LAST_DAY(current_date);

# 时区转换
select current_timestamp(),convert_tz(current_timestamp,'US/Eastern','UTC');


# 返回日期对应的某个时间
select extract(year from current_timestamp);

# 时间的周几？
SELECT DAYNAME(CURRENT_TIMESTAMP);

# 日志之差
select datediff(current_date,'2009-11-23');


# cast 转换函数
select cast( '2009-11-23' as DATE);
```

