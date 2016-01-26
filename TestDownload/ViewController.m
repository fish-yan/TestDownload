//
//  ViewController.m
//  TestDownload
//
//  Created by 薛焱 on 16/1/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *myPregress;
@property (nonatomic,strong) NSMutableData* fileData;
@property (nonatomic, copy) NSFileHandle *writeHandle;
@property (nonatomic, assign) long long currentLength;
@property (nonatomic, strong) NSURLSessionDownloadTask *downLoadTask;
@property (nonatomic, strong) NSURLSession *sessons;
@property (weak, nonatomic) IBOutlet UILabel *jindu;
@property (nonatomic, strong) NSData *resumData;
/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    
    NSURL *url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    //初始sesson化配置对象
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //初始化sesson
    self.sessons = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //创建下载任务
    self.downLoadTask = [self.sessons downloadTaskWithURL:url];
    
}

//下载过程,多次调用,存储下载状态
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    self.myPregress.progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    self.jindu.text = [NSString stringWithFormat:@"%.2f%%", self.myPregress.progress * 100];
}
//完成下载,缓存文件才tmp文件中,下载完成后自动删除,所以需要手动将下载的文件移到caches文件夹下,
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //创建文件存储路径,downloadTask.response.suggestedFilename为所下载的文件名
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager moveItemAtPath:location.path toPath:file error:nil];
    //下载完成提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载完成" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];

}
//下载按钮
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


@end
