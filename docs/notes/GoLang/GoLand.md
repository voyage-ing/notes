

[TOC]

每次打开务必检查下面两个插件是否开启。

### fmt

1. ![image-20200625095125456](https://tva1.sinaimg.cn/large/007S8ZIlly1gg9am1ut7lj30hs0vkjyf.jpg)

2. ```bash
   go get -u golang.org/x/lint/golint	
   ```

   `go list -f {{.Target}} golang.org/x/lint/golint` 查找golint装在那里

   

   

   ![image-20200625095254382](https://tva1.sinaimg.cn/large/007S8ZIlly1gg9am8tif0j31330u0n7p.jpg)

   -  `fometaliner`，用来在保存代码时，对代码作语法检查
   - `goimports`可以自动对代码中的依赖包进行管理，如果有用到，就会自动import，也会对没有用到的包进行自动删除。
   - -set_exit_status $FilePath$
   - GOROOT=$GOROOT$;GOPATH=$GOPATH$;PATH=$GoBinDirs$
   - ![image-20200625105323948](https://tva1.sinaimg.cn/large/007S8ZIlly1gg9amb46tnj30vd0u00xt.jpg)