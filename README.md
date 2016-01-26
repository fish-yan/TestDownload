# TestDownload
NSSession下载
其实系统提供的下载并不算困难, 也许以前使用NSURLConnection确实有点麻烦, 但是苹果推出的NSSURLSession并不复杂,用起来也比较简单. 

- 1.首先用到一个代理就是NSURLSessionDownloadDelegate
   通过初始化NSURLSessionConfiguration来配置sesson
   
``` Objective-C
NSURL *url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    //初始sesson化配置对象
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //初始化sesson
    self.sessons = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //创建下载任务
    self.downLoadTask = [self.sessons downloadTaskWithURL:url];
```

- 2.当然sessons并不能自动启动下载, 需要手动启动,通过[self.downLoadTask resume];的方法启动

需要用到的两个代理方法,其他的代理方法可以自己去研究
```objective-C
/**
 *  下载过程,多次调用,存储下载状态
 *
 *  @param bytesWritten              每次下载的字节数
 *  @param totalBytesWritten         当前下载的总字节数
 *  @param totalBytesExpectedToWrite 下载的文件的总字节数
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    //创建文件存储路径,downloadTask.response.suggestedFilename为所下载的文件名
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager moveItemAtPath:location.path toPath:file error:nil];
    //下载完成提示框(UIAlertView再Xcode7后就废除了)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载完成" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];

}
```
- 3.还有两个方法用来控制暂停和重新开始
暂停下载
[self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            //resumeData存储的下载状态,当恢复下载时候需要使用
        }];
重新开始下载
self.downLoadTask = [self.sessons downloadTaskWithResumeData:self.resumData];
[self.downLoadTask resume];
```objective-c
- (IBAction)pushOrPlay:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        //判断是否是恢复下载
        if (self.myPregress.progress != 0) {
            //恢复下载是调用的方法
        self.downLoadTask = [self.sessons downloadTaskWithResumeData:self.resumData];
        }
        [self.downLoadTask resume];
        [sender setTitle:@"暂停" forState:(UIControlStateNormal)];
    }else{
        //暂停下载时调用的block块
        __weak typeof (self) weakSelf = self;
        [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            //resumeData存储的下载状态,当恢复下载时候需要使用
            weakSelf.resumData = resumeData;
        }];
        [sender setTitle:@"下载" forState:(UIControlStateNormal)];
    }
}
```
  ![效果图](http://img.blog.csdn.net/20160126160147486)
  
   - 4.github地址:https://github.com/757094197/TestDownload
  请多多支持
