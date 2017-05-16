# 平蛮指掌图-bridge


linux bridge是内核网络协议栈的关键模块，从此开始。


## what is linux bridge


### bridge 驱动的初始化

略

### 创建bridge设备


#### 使用ioctl创建bridge

##### brctl
```
brctl addbr br000
```

用strace可以看到关键步骤为
```
[root@kvm1 ~]# strace brctl addbr br000
execve("/usr/sbin/brctl", ["brctl", "addbr", "br000"], [/* 22 vars */]) = 0
brk(0)                                  = 0x2407000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6a0dd7f000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=35140, ...}) = 0
mmap(NULL, 35140, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f6a0dd76000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \34\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=2112384, ...}) = 0
mmap(NULL, 3936832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f6a0d79d000
mprotect(0x7f6a0d954000, 2097152, PROT_NONE) = 0
mmap(0x7f6a0db54000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b7000) = 0x7f6a0db54000
mmap(0x7f6a0db5a000, 16960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f6a0db5a000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6a0dd75000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6a0dd73000
arch_prctl(ARCH_SET_FS, 0x7f6a0dd73740) = 0
mprotect(0x7f6a0db54000, 16384, PROT_READ) = 0
mprotect(0x606000, 4096, PROT_READ)     = 0
mprotect(0x7f6a0dd80000, 4096, PROT_READ) = 0
munmap(0x7f6a0dd76000, 35140)           = 0
socket(PF_LOCAL, SOCK_STREAM, 0)        = 3
ioctl(3, SIOCBRADDBR, 0x7ffee900e74e)   = 0
exit_group(0)                           = ?
+++ exited with 0 +++
socket(PF_LOCAL, SOCK_STREAM, 0)        = 3
ioctl(3, SIOCBRADDBR, 0x7ffee900e74e)   = 0
```

请注意关键部分为
```
socket(PF_LOCAL, SOCK_STREAM, 0)        = 3
ioctl(3, SIOCBRADDBR, 0x7ffee900e74e)   = 0
```

通过ioctl发送了一个SIOCBRADDBR给内核。

##### 入口

在bridge驱动模块初始化方法br_init中，设置了ioctl的hook
```
static int __init br_init(void)
{
    //略
	brioctl_set(br_ioctl_deviceless_stub);
    //略
}

```

##### 初始化
```
int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uarg)
{
	switch (cmd) {
	case SIOCGIFBR:
	case SIOCSIFBR:
		return old_deviceless(net, uarg);

	case SIOCBRADDBR:
	case SIOCBRDELBR:
	{
		char buf[IFNAMSIZ];

		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
			return -EPERM;

		if (copy_from_user(buf, uarg, IFNAMSIZ))
			return -EFAULT;

		buf[IFNAMSIZ-1] = 0;
		if (cmd == SIOCBRADDBR)
			return br_add_bridge(net, buf);

		return br_del_bridge(net, buf);
	}
	}
	return -EOPNOTSUPP;
}
```

所以收到SIOCBRADDBR消息会走到br_add_bridge函数。

##### br_add_bridge

```
int br_add_bridge(struct net *net, const char *name)
{
	struct net_device *dev;
	int res;

	dev = alloc_netdev(sizeof(struct net_bridge), name, NET_NAME_UNKNOWN,
			   br_dev_setup);

	if (!dev)
		return -ENOMEM;

	dev_net_set(dev, net);
	dev->rtnl_link_ops = &br_link_ops;

	res = register_netdev(dev);
	if (res)
		free_netdev(dev);
	return res;
}
```

#####


#### 使用netlink创建bridge

```

[root@kvm1 ~]# strace ip link add name br01 type bridge
execve("/usr/sbin/ip", ["ip", "link", "add", "name", "br01", "type", "bridge"], [/* 22 vars */]) = 0
brk(0)                                  = 0x224a000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd7f351f000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=35140, ...}) = 0
mmap(NULL, 35140, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fd7f3516000
close(3)                                = 0
open("/lib64/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\16\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=19520, ...}) = 0
mmap(NULL, 2109744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fd7f30fb000
mprotect(0x7fd7f30fe000, 2093056, PROT_NONE) = 0
mmap(0x7fd7f32fd000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7fd7f32fd000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \34\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=2112384, ...}) = 0
mmap(NULL, 3936832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fd7f2d39000
mprotect(0x7fd7f2ef0000, 2097152, PROT_NONE) = 0
mmap(0x7fd7f30f0000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b7000) = 0x7fd7f30f0000
mmap(0x7fd7f30f6000, 16960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fd7f30f6000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd7f3515000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd7f3513000
arch_prctl(ARCH_SET_FS, 0x7fd7f3513740) = 0
mprotect(0x7fd7f30f0000, 16384, PROT_READ) = 0
mprotect(0x7fd7f32fd000, 4096, PROT_READ) = 0
mprotect(0x649000, 4096, PROT_READ)     = 0
mprotect(0x7fd7f3520000, 4096, PROT_READ) = 0
munmap(0x7fd7f3516000, 35140)           = 0
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, 0) = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=19493, groups=00000000}, [12]) = 0
sendto(3, " \0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 32, 0, NULL, 0) = 32
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"4\0\0\0\2\0\0\0\0\0\0\0%L\0\0\355\377\377\377 \0\0\0\20\0\5\0\0\0\0\0"..., 8192}], msg_controllen=0, msg_flags=0}, 0) = 52
brk(0)                                  = 0x224a000
brk(0x226b000)                          = 0x226b000
brk(0)                                  = 0x226b000
open("//usr/lib64/ip/link_bridge.so", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
sendmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\20\0\5\0065\n\33Y\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 60}], msg_controllen=0, msg_flags=0}, 0) = 60
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0005\n\33Y%L\0\0\0\0\0\0<\0\0\0\20\0\5\0065\n\33Y"..., 32768}], msg_controllen=0, msg_flags=0}, 0) = 36
exit_group(0)                           = ?
+++ exited with 0 +++

```

关键部分为
```
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, 0) = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=19493, groups=00000000}, [12]) = 0
sendto(3, " \0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 32, 0, NULL, 0) = 32
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"4\0\0\0\2\0\0\0\0\0\0\0%L\0\0\355\377\377\377 \0\0\0\20\0\5\0\0\0\0\0"..., 8192}], msg_controllen=0, msg_flags=0}, 0) = 52
```

创建一个PF_NETLINK socket，发送给内核的NETLINK协议族。

##### 入口

在NETLINK初始化时,rtnetlink的入口为rtnetlink_init , 位于net/core/rtnetlink.c.
```
void __init rtnetlink_init(void)
{
	if (register_pernet_subsys(&rtnetlink_net_ops))
		panic("rtnetlink_init: cannot initialize rtnetlink\n");

	register_netdevice_notifier(&rtnetlink_dev_notifier);

	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink,
		      rtnl_dump_ifinfo, rtnl_calcit);
	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL);
	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL);
	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL);

	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);

	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, NULL);

	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
}

```

为RTM_NEWLINK注册了一个rtnl_newlink事件,rtnl_newlink会调用rtnl_create_link


```seq
renl_newlink -> rtnl_create_link -> alloc_netdev_mqs -> priv_size －> rtnl_link_ops->setup
                              |
                              |-->rtnl_link_ops->newlink

```

在看bridge的br_link_ops
```
struct rtnl_link_ops br_link_ops __read_mostly = {
	.kind			= "bridge",
	.priv_size		= sizeof(struct net_bridge),
	.setup			= br_dev_setup,
	.maxtype		= IFLA_BRPORT_MAX,
	.policy			= br_policy,
	.validate		= br_validate,
	.newlink		= br_dev_newlink,
	.changelink		= br_changelink,
	.dellink		= br_dev_delete,
	.get_size		= br_get_size,
	.fill_info		= br_fill_info,

	.slave_maxtype		= IFLA_BRPORT_MAX,
	.slave_policy		= br_port_policy,
	.slave_changelink	= br_port_slave_changelink,
	.get_slave_size		= br_port_get_slave_size,
	.fill_slave_info	= br_port_fill_slave_info,
};
```

就可以知道，在使用netlink初始化一个bridge设备的时候，netlink框架先后回调br_dev_setup/br_dev_newlink，完成设备初始化。

br_dev_setup   完成bridge_net的成员变量初始化,br_dev_newlink则完成register_netdevice.




### add if


### if发包

### if收报