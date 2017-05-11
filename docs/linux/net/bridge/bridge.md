# 平蛮指掌图-bridge


linux bridge是内核网络协议栈的关键模块，从此开始。


## what is linux bridge


### bridge 驱动的初始化

略

### 创建bridge设备


#### 使用ioctl创建bridge

##### brctl
```
brctl addbr br01
```

用strace可以看到关键步骤为
```
strace brctl addr br00


```


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
strace ip link add name br01 type bridge
```


##### 入口

### add if


### if发包

### if收报