## Brouter-ios 
=====
#一款iOS路由处理组件

## Install
直接将Brouter文件夹拖拽到工程中

## Usage

注册：
<pre>
<code>
    //url 中不包含参数
    [Brouter route:@"test://foo/bar" toHandler:^(BrouterContext * _Nonnull context) {
        NSLog(@"%@",context);
    }];
    // url 中包含参数， 并且用正则表达式规定参数的格式
    [Brouter route:@"test://foo/channel/{channel:[\\w]+}/post/{postId:[0-9]+}" toHandler:^(BrouterContext * _Nonnull context) {
        NSLog(@"%@",context.params);
    }];
</code>
</pre>

调取：
<pre>
<code>
    [Brouter openUrl:@"test://foo/bar?p=123"];
    [Brouter openUrl:@"test://foo/channel/brouter/post/1002"];
</code>
</pre>
