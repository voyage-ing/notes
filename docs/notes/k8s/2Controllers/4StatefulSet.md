# StatefulSet

有状态服务和无状态服务：

- 无状态应用（Stateless Application）是指应用不会在会话中保存下次会话所需要的客户端数据。每一个会话都像首次执行一样，不会依赖之前的数据进行响应；
- 有状态的应用（Stateful Application）是指应用会在会话中保存客户端的数据，并在客户端下一次的请求中来使用那些数据。



有状态的服务为什么需要statefulset + headless service