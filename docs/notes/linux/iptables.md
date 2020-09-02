# Iptables使用





-t 参数用来，内建的规则表有三个，分别是：nat、mangle 和 filter，当未指定规则表时，则一律视为是 filter。个规则表的功能如下：

nat：此规则表拥有 PREROUTING 和 POSTROUTING 两个规则链，主要功能为进行一对一、一对多、多对多等网址转换工作（SNAT、DNAT），这个规则表除了作网址转换外，请不要做其它用途。

mangle：此规则表拥有 PREROUTING、FORWARD 和 POSTROUTING 三个规则链。除了进行网址转换工作会改写封包外，在某些特殊应用可能也必须去改写封包（TTL、TOS）或者是设定 MARK（将封包作记号，以进行后续的过滤），这时就必须将这些工作定义在 mangle 规则表中，由于使用率不高，我们不打算在这里讨论 mangle 的用法。

filter： 这个规则表是默认规则表，拥有 INPUT、FORWARD 和 OUTPUT 三个规则链，这个规则表顾名思义是用来进行封包过滤的处理动作（例如：DROP、 LOG、 ACCEPT 或 REJECT），我们会将基本规则都建立在此规则表中。

