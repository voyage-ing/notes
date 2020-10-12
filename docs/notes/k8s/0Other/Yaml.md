# Yaml语法

感谢：https://blog.csdn.net/weixin_40367126/article/details/103855531

另外在不知道yaml语法是什么意思的时候可以使用yaml-json在线转换工具：https://www.bejson.com/json/json2yaml

`|`：多行字符串可以使用`|`保留换行符；

```yaml
this: |
  Foo
  Bar
# { this: 'Foo\nBar\n' }
```

`>`：使用`>`折叠换行;

```yaml
that: >
  Foo
  Bar
# { this: 'Foo Bar\n' }
```

`|+` 保留文字块末尾换行；

```yaml
this: |+
  Foo
  Bar
# { this: 'Foo\nBar\n' }，效果和｜类似
```

`|-`：删除文字块末尾的换行；

```yaml
this: |-
  Foo
  Bar
# { this: 'Foo\nBar' }
```

