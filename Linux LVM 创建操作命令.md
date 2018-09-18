本文总结了Linux系统LVM工具管理物理卷PV、卷组VG、逻辑卷LV的常用命令，并附加应用实例。同时提供了AIX与Linux LVM的命令对比，为Linux、AIX系统管理员创建、删除、扩容、查看及修改PV/VG/LV提供参考。

## 物理卷（PV）管理

### 初始化成为物理卷

pvcreate PhysicalVolume [PhysicalVolume...]

注释：使用pvcreate命令将一个块设备初始化为一个PV。PhysicalVolume参数可以是一个磁盘分区，整个磁盘，meta磁盘设备。当整个磁盘作为一个PV时，磁盘必须没有分区列表，擦除分区表可以通过以下命令将第一个扇区写0：dd if=/dev/zero of=PhysicalVolume bs=512 count=1

命令示例：

#pvcreate /dev/sdd1 /dev/sde1 /dev/sdf1

 

### 显示物理卷

pvdisplay  PhysicalVolumePath [PhysicalVolumePath...] 

注释：使用pvdisplay命令显示一个或多个物理卷的属性

命令示例：

#pvdisplay

  --- Physical volume ---

  PV Name               /dev/sdc1

  VG Name               new_vg

  PV Size               17.14 GB / not usable 3.40 MB

  Allocatable           yes

  PE Size (KByte)       4096

  Total PE              4388

  Free PE               4375

  Allocated PE          13

  PV UUID               Joqlch-yWSj-kuEn-IdwM-01S9-XO8M-mcpsVe

 

### 扫描物理卷

pvscan

注释：在系统LVM块设备中检索PV

命令示例：

#pvscan

PV /dev/sdb2   VG vg0   lvm2 [964.00 MB / 0   free]

PV /dev/sdc1   VG vg0   lvm2 [964.00 MB / 428.00 MB free]

PV /dev/sdc2            lvm2 [964.84 MB]

Total: 3 [2.83 GB] / in use: 2 [1.88 GB] / in no VG: 1 [964.84 MB]

 

### 改变物理卷的分配许可

pvchange -x n PhysicalVolumePath

注释：允许用户改变一个或多个物理卷的分配许可

命令示例：

#pvchange -x n /dev/sdk1

 

### 删除物理卷

pvremove PhysicalVolumePath

注释：将物理卷删除，删除之前必须用vgreduce命令把它从卷组中移除

命令示例：

pvremove /dev/sdb2

 

## 卷组（VG）管理

### 创建卷组

pvcreate [–s PhysicalExtentSize] [ –p MaxLogicalVolumes] [-l MaxLogicalVolumes] VolumeGroupNamePhysicalVolumePath [PhysicalVolumePath...] 

注释：卷组将多个物理卷组成一个整体，屏蔽了底层物理卷细节。在卷组上创建逻辑卷时无需考虑具体的物理卷信息。

选项：

-s：设置物理卷的PE大小，默认为megabytes

-p：卷组中允许添加的最大物理卷数

-l：卷组上允许创建的最大逻辑卷数

命令示例：

vgcreate myvg /dev/sdb1 /dev/sdb2 

 

### 扫描并显示系统中的卷组

vgscan

注释：查找系统中存在的LVM卷组，仅显示找到的卷组名称和LVM元数据类型，要得到卷组的详细信息需使用vgdisplay命令。

命令示例：

#vgscan    

Found volume group "vg2000" using metadata type lvm2 

Found volume group "vg1000" using metadata type lvm2

 

### 显示卷组属性

vgdisplay VolumeGroupName

注释：显示LVM卷组的元数据信息，如不指定卷组参数，则显示所有卷组属性。

命令示例：

# vgdisplay new_vg

  --- Volume group ---

  VG Name               new_vg

  System ID

  Format                lvm2

  Metadata Areas        3

  Metadata Sequence No  11

  VG Access             read/write

  VG Status             resizable

  MAX LV                0

  Cur LV                1

  Open LV               0

  Max PV                0

  Cur PV                3

  Act PV                3

  VG Size               51.42 GB

  PE Size               4.00 MB

  Total PE              13164

    Alloc PE / Size       13 / 52.00 MB

  Free  PE / Size       13151 / 51.37 GB

VG UUID               jxQJ0a-ZKk0-OpMO-0118-nlwO-wwqd-fD5D32

 

 

### 增加PV到现有卷组

vgextend VolumeGroupName PhysicalVolumePath [PhysicalVolumePath...] 

注释：动态添加一个或多个PV到卷组

命令示例：

#vgextend myvg /dev/sdb2 

 

 

### 从卷组中删除PV

vgreduce [-a] VolumeGroupName [PhysicalVolumePath...] 

注释：从卷组中删除一个或多个无用的PV，在使用之前，需通过pvmove把PV上的LV移动到其他PV上。

选项：

-a：如果命令行中没有指定删除的物理卷，则删除所有的空物理卷

命令示例：

#vgreduce myvg /dev/hda1

 

### 改变卷组属性

vgchange [-a {y|n}] [-l MaxLogicalVolumes] VolumeGroupName

注释：设置卷组为活动状态或非活动状态，或改变卷组的最大LV数量。

选项：

-a：设置卷组的活动状态

-l：改变一个当前非活动卷组的最大逻辑卷数

命令示例：

#vgchange –a y myvg

#vgchange –l 128 /dev/vg00

 

### 删除卷组

vgremove VolumeGroupName [VolumeGroupName...]

注释：删除一个或多个卷组。卷组上必须没有逻辑卷并且为非活动状态。当卷组上已创建了逻辑卷时，vgremove需要进行确认删除。

命令示例：

# vgremove myvg

 

 

### 分割卷组

vgsplit  ExistingVolumeGroupName NewVolumeGroupName PhysicalVolumePath[PhysicalVolumePath...] 

注释：把卷组的PV分成两部分，并建立新的VG。被分割到新的VG的PV必须不包括LV的一部分，即：LV不能跨组。

命令示例：

# vgsplit bigvg smallvg /dev/ram15

 

### 合并卷组

vgmerge  DestinationVolumeGroupName SourceVolumeGroupName

注释：把非活动状态的源卷组合并到活动或非活动状态的目标卷组中。

命令示例：

#vgmerge -v databases myvg

 

## 逻辑卷（LV）管理

### 创建逻辑卷

lvcreate [-l LogicalExtentsNumber] [-L LogicalVolumeSize] [-n LogicalVolumeName] VolumeGroupName[PhysicalVolumePath...]

注释：创建LVM的逻辑卷。

选项：

-L：指定逻辑卷的大小

-l：指定逻辑卷的大小（LE数）

-n：创建逻辑卷的名称

命令示例：

#lvcreate -L 1500 -ntestlv testvg /dev/sdg1


### 收缩逻辑卷空间

lvreduce [-l [-]LogicalExtentsNumber] [–L [-]LogicalVolumeSize] LogicalVolumePath

注释：减少逻辑卷占用的空间大小，此命令有可能会删除逻辑卷上的已有数据，操作之前必须确认。

选项：

-l：指定逻辑卷的大小（LE数）

-L：指定逻辑卷的大小

命令示例：

#lvreduce -l -3 /dev/vg00/lvol1

 

### 改变逻辑卷参数

lvchange [-a {y|n}] [-p r|rw] LogicalVolumePath [LogicalVolumePath...] 

注释：改变逻辑卷参数，或激活/禁止某个逻辑。

选项：

-a：设置逻辑卷的活动状态

-p：访问权限为只读或可读写

命令示例：

#lvchange –a n /dev/vg00/lvol1

 

### 删除逻辑卷

lvremove LogicalVolumePath [LogicalVolumePath...] 

注释：删除一个或多个非活动的逻辑卷。如果逻辑卷已用mount指令加载，则不能用lvremove删除。需使用umount卸载后，方可被删除。

命令示例：

#lvremove /dev/vg00/lv01

 

### 显示逻辑卷属性

lvdisplay LogicalVolumePath [LogicalVolumePath...] 

注释：显示逻辑卷空间大小、读写状态和快照信息等属性。如果缺省逻辑卷参数，则显示所有逻辑卷属性。

命令示例：

#lvdisplay -v /dev/vg00/lvol2

 

### 扫描逻辑卷

lvscan

注释：扫描系统中所有存在的逻辑卷。

命令示例：

#lvscan

 

### 扩展逻辑卷

lvextend {-l [+]LogicalExtentsNumber}{ -L [+]LogicalVolumeSize] LogicalVolumePath[PhysicalVolumePath...] 

注释：在线扩展逻辑卷空间大小，可以指定扩展后的大小，也可以指定增量。

选项：

-l：扩展后的大小或增量，以LE为单位

-L：扩展后的大小或增量

命令示例：

#lvextend -L +100M /dev/vg1000/lvol0
