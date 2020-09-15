





Pod 声明中需要提供卷的类型 (`.spec.volumes` 字段)和卷挂载的位置 (`.spec.containers.volumeMounts` 字段).

deployment指定volumes 直接把host的folder挂到容器里

      volumes:
      - name: conf
        hostPath:
          path: /etc/nginx
          type: Directory
      - name: opt
        hostPath:
          path: /opt
          type: Directory