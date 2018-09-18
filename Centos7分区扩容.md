### 查看新添加的存储设备是否成功

fdisk -l

### 创建物理卷 pv

pvcreate /dev/vdb

### 查看 VG（Volume Group）

vgs

### 将新创建的物理卷添加到 VG

vgextend VolGroup00 /dev/vdb

### 给 home 分区添加50G 磁盘空间

lvextend -L +50G /dev/VolGroup00/LVhome

### 给var 分区添加400G 磁盘空间

### lvextend -L +50G /dev/VolGroup00/LVvar

## 补充：
某些机器执行 `lvextend` 后，`df -h` 查看容量仍然是之前的。执行`resize2fs /dev/mapper/VolGroup00-LVhome` 提示如下错误： 

"
resize2fs: Bad magic number in super-block while trying to open /dev/mapper/VolGroup00-LVhome
Couldn't find valid filesystem superblock.
"

通过执行命令`xfs_growfs /dev/mapper/VolGroup00-LVhome`后，`df -h`查看，容量为扩容后的。问题解决~~
