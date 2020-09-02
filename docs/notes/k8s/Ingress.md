```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress1
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: www1.westos.org
    http:
      paths:
      - path: /
        backend:
          serviceName: myservice
          servicePort: 80
  - host: www2.westos.org
    http:
      paths:
      - path: /		访问www2.westos.com 时，走 myservice2 这个svc
        backend:
          serviceName: myservice2
          servicePort: 80
```

