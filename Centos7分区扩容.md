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
