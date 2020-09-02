```yaml
apiVersion: v1
data:
  BOND: br-eth1
  BOOT: disk
  CPUS: "1"
  MEM: "512"
  NICS: "0"
  VRAMS: "16"
  XARGS: -cpu host
kind: ConfigMap
metadata:
  annotations:
    qvmMeta: '{"state":"start","base":"registry.k3s/vm/openwrt:19.07.3","qos":"RequestRAM","disks":[{"pvc":"pvc-local-wrt2-0-d0","size":"6G"}]}'
  creationTimestamp: "2020-06-29T05:25:27Z"
  labels:
    liveit100.com/app: qvm
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:BOND: {}
        f:BOOT: {}
        f:CPUS: {}
        f:MEM: {}
        f:NICS: {}
        f:VRAMS: {}
        f:XARGS: {}
      f:metadata:
        f:annotations:
          .: {}
          f:qvmMeta: {}
        f:labels:
          .: {}
          f:liveit100.com/app: {}
    manager: qvm
    operation: Update
    time: "2020-06-29T05:29:30Z"
  name: wrt2-0
  namespace: project1
  resourceVersion: "21469566"
  selfLink: /api/v1/namespaces/project1/configmaps/wrt2-0
  uid: 81935967-911c-42e1-8c31-c8178b44d6d0
```

