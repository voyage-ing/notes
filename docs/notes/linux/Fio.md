# Fio使用和结果分析

感谢，参考自：https://blog.51cto.com/qixue/1906768；

官方说明文档，很有用：https://fio.readthedocs.io/en/latest/index.html；

## fio参数解释

在此基础上添加一些知识；

```bash
fio -filename=/dev/nvme0n1 -direct=1 -iodepth  32 -iodepth_batch 1 -iodepth_batch_complete 16 -rw=randread -ioengine=libaio -bs=16k -size=400G -numjobs=1 -runtime=600 -group_reporting -time_based -ramp_time=60 -name=nvme0 >> nvme0-4k-randread.out
```

参数注解（可以自行查看man文档对比下）：

- filename: 
      为该测试用例设置生成的文件名，方便各个jobs共享，如/dev/sdb;

  > 注意对系统盘直接测试会损坏系统分区造成无法启动系统；可以在系统盘下创建folder来测试，并用directory指定文件夹路径来替换掉filename；

- directory: 测试路径；和filename对应；

- direct：是否使用io缓存，相当于直接io或者裸io，文件内容直接写到磁盘设备上，不经过缓存，direct=1；
  
- iodepth：队列深度，在异步io模式模拟一次丢给系统处理的io请求数量；同步系统由于串行，一般小于1；
  
- iodepth_batch：io队列请求丢过来后，攒积到这些请求后，立即提交，默认是iodepth的值；
  
- iodepth_batch_complete：io请求过来后，能retrieve获得的最多请求数；
  
- ipdepth_low：io请求达到这个水平线后，开始尝试去补充和获取请求，默认是iodepth的值；
  
> ```bash
  > -iodepth  32 -iodepth_batch 1 -iodepth_batch_complete 16
  > ```
  >
  > 一次模拟生成32个io请求，一次处理能接受16个请求，异步模式下，1个请求来了直接提交;
  >
> 
  >
  > libaio引擎会用这个iodepth值来调用io_setup准备个可以一次提交iodepth个IO的上下文，同时申请个io请求队列用于保持IO。 在压测进行的时候，系统会生成特定的IO请求，往io请求队列里面扔，当队列里面的IO个数达到iodepth_batch值的时候，就调用io_submit批次提交请求，然后开始调用io_getevents开始收割已经完成的IO。 每次收割多少呢？由于收割的时候，超时时间设置为0，所以有多少已完成就算多少，最多可以收割iodepth_batch_complete值个。随着收割，IO队列里面的IO数就少了，那么需要补充新的IO。 什么时候补充呢？当IO数目降到iodepth_low值的时候，就重新填充，保证OS可以看到至少iodepth_low数目的io在电梯口排队着。
  >
  > ```yaml
  > -iodepth=16 -iodepth_batch=8 -iodepth_low=8 -iodepth_batch_complete=8
  > ```
  >
  > 
  
- rw：模拟当前的读写模式，模式有randread,randwrite,randrw(可以指定rwmixread或者rwmixwrite来指定比例，默认50）,read,write,rw；
  
- thread：fio默认会使用fork()创建job，如果这个选项设置的话，fio将使用pthread_create来创建线程;

- ioengine：说明job处理io请求的调度方式，一般测试使用libaio（Linux native asynchronous I/O）；也可以psync；
  
- bs：一次io的实际块大小；
  
- size：每个job的测试大小，到这里才会结束io请求测试；
  
- numjobs：同时并行运行的工作jobs数，相当于一个job克隆，具有相同workload（负载）；
  
- runtime：运行的时间（s）; 如果不设置time_based，runtime设置的就算很大，那么io大小到size后就会立即停止，而不是到runtime设置的时间；
  
- group_reporting：当设置这个值的时候，会把所有的jobs一起统计汇总平均值等信息，否则会按照每个jobs分别统计;
  
- time_based:  `-time_based`：如果设置这个值，即使io大小到达size后还未结束的情况，仍然会继续模拟相同的负载，直至这个时间runtime结束;
  
- ramp_time：ramp本意是坡度，相当于预热，意思是跑每个job之前会跑多久的预热，预热时间不算进runtime;
  
- name：给job起这个名字而不是使用默认的名称;

## fio结果解读

```bash
fio -filename=/dev/vdb -direct=1 -iodepth 32 -thread -rw=randrw -rwmixread=70 -ioengine=libaio -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=testfio
```

```bash
testfio: (g=0): rw=randrw, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=32
...
fio-3.7
Starting 10 threads
Jobs: 8 (f=8): [m(4),_(1),m(3),_(1),m(1)][91.9%][r=677MiB/s,w=291MiB/s][r=43.4k,w=18.6k IOPS][eta 00m:03s]
testfio: (groupid=0, jobs=10): err= 0: pid=3335: Thu Sep 24 04:25:36 2020
   read: IOPS=26.6k, BW=416MiB/s (436MB/s)(13.0GiB/34469msec)
    slat (usec): min=2, max=375533, avg=40.79, stdev=1058.36
    clat (usec): min=65, max=455661, avg=8296.62, stdev=12218.78
     lat (usec): min=76, max=455669, avg=8338.53, stdev=12297.28
    clat percentiles (usec):
     |  1.00th=[   955],  5.00th=[  1745], 10.00th=[  2245], 20.00th=[  2868],
     | 30.00th=[  3556], 40.00th=[  4228], 50.00th=[  4948], 60.00th=[  5735],
     | 70.00th=[  7177], 80.00th=[ 10159], 90.00th=[ 17957], 95.00th=[ 26608],
     | 99.00th=[ 51643], 99.50th=[ 63177], 99.90th=[147850], 99.95th=[189793],
     | 99.99th=[287310]
   bw (  KiB/s): min=  768, max=128736, per=9.86%, avg=41984.49, stdev=31169.50, samples=678
   iops        : min=   48, max= 8046, avg=2623.95, stdev=1948.09, samples=678
  write: IOPS=11.4k, BW=178MiB/s (187MB/s)(6149MiB/34469msec)
    slat (usec): min=2, max=397853, avg=44.61, stdev=1202.15
    clat (usec): min=135, max=455595, avg=8322.44, stdev=12370.30
     lat (usec): min=148, max=455605, avg=8368.17, stdev=12458.54
    clat percentiles (usec):
     |  1.00th=[   947],  5.00th=[  1762], 10.00th=[  2245], 20.00th=[  2868],
     | 30.00th=[  3556], 40.00th=[  4228], 50.00th=[  4948], 60.00th=[  5735],
     | 70.00th=[  7177], 80.00th=[ 10290], 90.00th=[ 17957], 95.00th=[ 26870],
     | 99.00th=[ 51643], 99.50th=[ 62653], 99.90th=[162530], 99.95th=[193987],
     | 99.99th=[421528]
   bw (  KiB/s): min=  288, max=53120, per=9.86%, avg=18002.25, stdev=13353.37, samples=678
   iops        : min=   18, max= 3320, avg=1125.06, stdev=834.58, samples=678
  lat (usec)   : 100=0.01%, 250=0.01%, 500=0.06%, 750=0.45%, 1000=0.62%
  lat (msec)   : 2=6.00%, 4=30.00%, 10=42.44%, 20=12.12%, 50=7.23%
  lat (msec)   : 100=0.88%, 250=0.18%, 500=0.02%
  cpu          : usr=1.74%, sys=3.50%, ctx=47684, majf=0, minf=10
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwts: total=917210,393510,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=416MiB/s (436MB/s), 416MiB/s-416MiB/s (436MB/s-436MB/s), io=13.0GiB (15.0GB), run=34469-34469msec
  WRITE: bw=178MiB/s (187MB/s), 178MiB/s-178MiB/s (187MB/s-187MB/s), io=6149MiB (6447MB), run=34469-34469msec

Disk stats (read/write):
  vdb: ios=914415/392173, merge=0/0, ticks=5986235/2577115, in_queue=7910956, util=65.39%
```

witting for learning :https://www.cnblogs.com/zero-gg/p/9296603.html

IOPS: 每秒的输入输出量(或读写次数)，是衡量磁盘性能的主要指标之一；

Bw: 带宽；

```bash
slat (usec): min=2, max=397853, avg=44.61, stdev=1202.15
clat (usec): min=135, max=455595, avg=8322.44, stdev=12370.30
lat (usec): min=148, max=455605, avg=8368.17, stdev=12458.54
```

- I/O延迟包括三种：slat，clat，lat：关系是 lat = slat + clat；
  - slat 表示fio submit某个I/O的延迟；
  - clat 表示fio complete某个I/O的延迟；
  - lat 表示从fio将请求提交给内核，再到内核完成这个I/O为止所需要的时间；

```bash
  lat (usec)   : 100=0.01%, 250=0.01%, 500=0.06%, 750=0.45%, 1000=0.62%
  lat (msec)   : 2=6.00%, 4=30.00%, 10=42.44%, 20=12.12%, 50=7.23%
  lat (msec)   : 100=0.88%, 250=0.18%, 500=0.02%
```

- usec：微秒；msec：毫秒；1ms=1000us；
- 这组数据表明lat(latency：延迟 )的分布；有0.01%的request延迟<100us，有0.01%的 100us < request lat < 250us，有0.06%的 250us < request lat < 500us，以此类推；

```bash
 cpu          : usr=1.74%, sys=3.50%, ctx=47684, majf=0, minf=10
```

- usr：表示用户空间进程；
- sys：表示内核空间进程；
- 因为上下文切换导致的主要和次要页面失败的用户/系统 CPU使用百分比。因为测试被配置的使用直接IO，因此有很少的页面失败：；

```bash
 IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
```

- iodepth设置用来控制在任何时间有多少IO分发给系统。这完全是应用方面的，意味着它和设备的IO队列做不同的事情，iodepth设置为1因此IO深度在100%的时间里一直是一个1；

```bash
Run status group 0 (all jobs):
   READ: bw=416MiB/s (436MB/s), 416MiB/s-416MiB/s (436MB/s-436MB/s), io=13.0GiB (15.0GB), run=34469-34469msec
  WRITE: bw=178MiB/s (187MB/s), 178MiB/s-178MiB/s (187MB/s-187MB/s), io=6149MiB (6447MB), run=34469-34469msec
```

- bw=这组进程的总带宽，每个线程的带宽（设置了numjobs>1这里会很明显）；
- io=这组总io大小；
- 线程的最小和最大时间；

Util: The disk utilizatio，磁盘利用率. A value of 100% means we kept the disk busy constantly, 50% would be a disk idling half of the time；

