# 代码仓

# run_test.sh

## 功能
在后台运行指定数量，指定镜像名和快照器的容器

## 用法
```
./run_test.sh 
Usage: ./run_test.sh -i|--images <images_name> [-n|--num <num>] [-s|--snapshotter <snapshotter>] -o|--output <output_dir>
```

-i|--images <images_name>		镜像全称，必选
-n|--num <num>					运行容器数量，可选，默认为 1
-s|--snapshotter <snapshotter>		snapshotter，可选，默认为 overlayer
-o|--output <output_dir>			日志输出目录，必选，默认会清理旧目录，不能为 /root, /home 等初级目录

# calculate_iops.sh

## 功能
计算 run_test.sh 批量并发跑情况下日志的平局值

## 用法
```
./calculate_iops.sh 
Usage: ./calculate_iops.sh -d <log_directory>
```
把 run_test.sh 的 output_dir 作为入参传进去即可


