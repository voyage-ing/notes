# Git进阶使用教程

## Git初始化本地项目并推送到Git服务器

1. `git init`
2. `git remote add origin <git path>`
3. `git push -u origin master`

## 简单情况下的代码提交

1. `git fetch origin master`：获取最新的master分支
2. `git checkout -b mydev`：创建一个自己写代码的分支并切换
3. `Coding`：开发人员写代码
4. `git add`
5. `git commit -m "commit hints"`
6. `git push origin mydev`：提交到origin的mydev分支
7. 发起PR(Pull Requests)
8. 团队其他人员评论，建议
9. 在本地mydev上根据建议修改代码
10. `git commit --amend` ：修改上次的commit
11. `git push origin -f mydev` ：覆盖上次提交
12. 如果还不通过，循环这个过程。

## Fetch and Pull

Origin 其实是你本地的分支，但他的指向是remote，remote更新代码以后，也就是新增了个提交之后，origin此时还并没有更新到记录。

通过一个小例子来看：

先对远程仓库的分支(这里以master为例)合并一条请求，然后按顺序执行下面的命令：

- `git log origin/master` ：注意查看输出，特别关注第一条
- `git fetch origin` ：更新远程跟踪分支(所有分支)
- `git log origin/master` ：看输出的，跟第一条比较

fetch只是追踪了远程分支的变化，但并没有将变化合并到本地分支。

所以，如果需要更新本地代码：

```bash
git pull origin master    //相当于git fetch 和 git merge
```

## 获取特定代码

### 获取特定分支代码

- 先clone master分支到本地，然后：

```bash
git checkout -b dev origin/dev
```

- **直接获取分支代码**：

```bash
git clone -b <branchname> https://git.url <localfolderpath>
```

> Localfolderpath 一定要是一个文件夹的名字，可以不存在会自己创建。

### 获取历史提交代码

`git checkout -b <branchname> <commitID>`

## 远程仓库已经合并了别人的代码

如果此时你在发起一个合并请求，且你们修改的不是同一个文件，会出现以下现象：

![Xnip2020-06-21_10-41-34](https://tva1.sinaimg.cn/large/007S8ZIlly1gg97jabev1j31ca0d6taa.jpg)

可以通过点击“更新分支”，通过两个commit实现的，先是他人合并到master的提交，接着才是你的提交。

但是推荐下面这种方式，只有一个commit，在你发起一个PR之后发现代码落后的处理。

```bash
git rebase origin/master 	# 如果没冲突是顺利执行的
git commit --amend
git push origin -f hang
```

## 冲突产生原因与解决办法

产生原因：远程仓库已经合并的代码里，修改了与你发起PR的分支中相同的部分。

举例说明：O是master分支，O_0是合并代码前的，A是一个分支，B是另一个分支；A，B都是从O的同一个commit节点中检出的。现在A修改了一些代码并且已经合并到O中了，A合并以后O_0变成了O_1，但是B不知道，B也修改了相同的位置发起了从B到O_0的PR（合并请求），因此导致了冲突。

那么正确的应该是什么？就是B不应该修改，然后fetch下远程O的代码，再checkout B ，修改代码，然后从B发起到O_1的合并请求。

如果你已经没注意这样做了，如何解决？当然也有办法。

```bash
git fetch										# 更新所有分支的代码
git rebase origin/master		# 在B分支下执行，将B变基
```

- rebase之后，冲突的部分会清楚的显示出来具体在那个文件里，而且文件里冲突的部分也会很清晰的标注出来。如下图：

  ![image-20200702101717155](https://tva1.sinaimg.cn/large/007S8ZIlly1ggcg6tcknhj307d041wef.jpg)

- <<<<<<< 和 ======= 之间是你当前分支所修改的内容
- \>>>>>>> 和 ======= 之间是别人的修改，也就是这里不同的修改造成的冲突。
- 解决冲突，需要把这些冲突表示的符号也删掉。

然后完成rebase的过程：

```bash
git rebase --continue
```

也可以中止rebase：`git rebase --abort`，并且分支会回退到rebase开始之前的状态。

rebase完成之后，你按照正常提交代码就可以了。

## 不恰当的多个Commit合并为一个

```bash
git log	# 确认当前所处commit位置
git reset --soft HEAD~1 # 1是你想回退到几次提交前，或者
git reset --hard HEAD~1
```

- --soft：需要保存提交的代码用这个，然后git stash， 再git stash pop 更改变化。
- --hard  恢复到上次提交前，但提交的代码被清空。

再次提交代码的时候：

```bash
git commit --amend
git push origin -f mydev
```

## Git撤销，放弃本地修改

参考来源：https://blog.csdn.net/A_grumpy_Mario/article/details/103282110?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase

1. 未使用git add 提交到暂存区的代码：

```bash
git checkout -- filepathname #放弃单个文件的代码修改
git checkout .							 #放弃所有文件的修改
```

	此命令用来放弃掉所有还没有加入到缓存区（就是 git add 命令）的修改：内容修改与整个文件删除。但是此命令不会 删除掉刚新建的文件。因为刚新建的文件还没已有加入到 git 的管理系统中。所以对于git是未知的。

2. 已经git add 提交到暂存区的代码：

```bash
git reset HEAD filepathname	 #放弃指定文件的缓存
git reset HEAD							 #放弃所有文件的缓存

# 此命令用来清除 git  对于文件修改的缓存。相当于撤销 git add 命令所在的工作在使用本命令后，本地的修改并不会消失，而是回到了如（1）所示的状态。继续用（1）中的操作，就可以放弃本地的修改
```

3. 已经使用了git commit提交了的代码

```bash
git reset --hard HEAD^			 #退到最近一次commit的状态
git reset --hard  commitid	 #恢复到上次提交，提交的代码被清空。
git reset --soft  commitid
#恢复到上次提交，提交的代码还在，然后git stash， 再git stash pop 更改变化。
git log 命令来查看git的提交历史
```

## 更新远程分支列表

```bash
git remote update origin --prune
```

## 代码引用特定行

点开代码仓库某一文件的具体代码，按规则在url后面添加：

指定第30行代码：#L30

指定30～50行的代码：#L30-L50

## 团队协作常用术语

- **WIP** —   Work in progress, do not merge yet. // 进行中，尚未合并。
- **LGTM** —  Looks good to me. // 在我看来很好。(Review 完别人的 PR ，没有问题)
- **PTAL** —  Please take a look. // 帮我看下 (一般都是请别人 review 自己的 PR)
- **CC** —  Carbon copy // 复本 (一般代表抄送别人的意思)
- **RFC**  —  request for comments. // 我觉得这个想法很好, 我们来一起讨论下
- **IIRC**  —  if I recall correctly. // 如果我没记错
- **ACK**  —  acknowledgement. // 我确认了或者我接受了,我承认了
- **NACK/NAK** — negative acknowledgement. // 我不同意
