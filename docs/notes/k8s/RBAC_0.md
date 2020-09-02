# RBAC: K8s基于角色的权限控制

[TOC]

Role-Based Access Control 

Learning

https://www.icode9.com/content-4-510472.html

https://www.qikqiak.com/k8s-book/docs/30.RBAC.html

## ServiceAccount、Role、RoleBinding

每个namespace都会创建默认的sa，名为default

### Step 1：创建一个ServiceAccount，指定namespace

ServiceAccount 会生成一个 Secret 对象和它进行映射，这个 Secret 里面包含一个 token。

```bash
kubectl create sa test-sa -n rbac-learning
```

```bash
$ kubectl describe sa -n rbac-learning sa-test
Name:                sa-test
Namespace:           rbac-learning
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   sa-test-token-9n9mm		# secret
Tokens:              sa-test-token-9n9mm
Events:              <none>
```

### Step 2：创建Role，设置权限



```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: role-test
  namespace: rbac-learning
rules:
  - apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

#### apiGroups，resource的对应关系

```bash
kubectl api-resources
```

![image-20200707124806936](https://tva1.sinaimg.cn/large/007S8ZIlly1ggibgia3uuj31bu0l078a.jpg)

> 如果APIGROUP是空的，则说明使用的是Core APIGROUP，使用空字符：""

#### verbs常用权限组合

读取权限：` ["get", "list", "watch"]`

读/写权限：`["get", "list", "watch", "create", "update", "patch", "delete"]`

指定特定名称资源的权限：

```yaml
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-config"]
  verbs: ["get"]
```

### Step 3：创建RoleBinding

将创建的sa和role进行绑定：

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sa-rolebinding-test
  namespace: rbac-learning
subjects:
- kind: ServiceAccount
  name: test-sa
  namespace: rbac-learning
roleRef:
  kind: Role
  name: role-test
  apiGroup: rbac.authorization.k8s.io
```

## ServiceAccount、ClusterRole、ClusterRoleBinding

如果我们现在创建一个新的 ServiceAccount，需要他操作的权限作用于所有的 namespace，这个时候我们就需要使用到 ClusterRole 和 ClusterRoleBinding 这两种资源对象了。

### 快速创建一个集群最高权限管理员

```bash
admin="admin"
kubectl create serviceaccount ${admin} -n kube-system
kubectl create clusterrolebinding ${admin} --clusterrole=cluster-admin --serviceaccount=kube-system:${admin}
```

### 通过SA、ClusterRole、ClusterRoleBinding创建

Step 1：创建一个ServiceAccount

```bash
kubectl create sa -n kube-system clusteradmin
```

Step 2：创建RoleBinding

 cluster-admin 是`Kubernetes`集群内置的 ClusterRole 对象，我们可以使用`kubectl get clusterrole` 和`kubectl get clusterrolebinding`查看系统内置的一些集群角色和集群角色绑定.

这里我们使用的 cluster-admin 这个集群角色是拥有最高权限的集群角色，所以一般需要谨慎使用该集群角色。

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: sa-clusterrolebinding-test
subjects:
- kind: ServiceAccount
  name: admin-sa
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

