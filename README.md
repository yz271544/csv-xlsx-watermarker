# split csv file convert to xlsx and add water mark

## simple start

```shell
./watermarker.sh main ./data/receive/test.csv 中文水印
```

## requirement
**csv2xlsx**
- you can download from csv2xlsx from crate.io
- or you may build it from repository `csv2xlsx`, it use rust cargo environment.

**split**
- centos
```shell
yum install coreutils
```

- ubuntu
```shell
apt install coreutils
```

- Arch linux
```shell
pacman -S coreutils
```

**uuidgen**
- centos
```shell
yum install util-linux
```

- ubuntu
```shell
apt install util-linux
```

- Arch linux
```shell
pacman -S util-linux
```

**watermark-cmd-{version}.jar**
- you can use deirect
- or go to the repository `watermarker-cmd` to build
- must use jdk1.8

## issue for chinese garbled
1. 检查字体是否已经安装：

```shell
fc-list
fc-list : lang=zh ---检查中文字体库
```

2. 到 C:\windows\fonts 复制对应字体库，微软雅黑、宋体、黑体等，各文件后缀可能不一样，有的为ttf，有的为ttc，不影响使用

3. 创建/usr/share/fonts/chinese目录，上传刚才复制的字体库到此目录，命令：
```shell
mkdir /usr/share/fonts/chinese          # --创建文件夹
chmod -R 777 /usr/share/fonts/chinese   # --修改字体权限，使root以外的用户可以使用这些字体：使用777 赋予全部权限
```

4. 建立字体缓存：

```shell
mkfontscale //字体扩展, 建立字体索引, 若提示命令找不到, 执行 yum install mkfontscale 安装
mkfontdir //新增字体目录
fc-cache -fv //刷新缓存
```