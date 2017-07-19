//
//  ViewController.m
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/3/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JSTrade/JSExportManager.h>


#import "OCModel.h"
#import "OCModel1.h"


@interface ViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, retain) WKWebView *webView;
@property (nonatomic, strong) JSExportManager* jsExport;
@end

@implementation ViewController

-(JSExportManager *)jsExport {
    if (!_jsExport) {
        _jsExport = [[JSExportManager alloc] init];
    }
    return _jsExport;
}

-(void)dealloc {
//    WKUserContentController * controller = self.webView.configuration.userContentController;
//    [controller removeAllScriptMessageHandlerModel];
}

-(WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController.jsExportManager = self.jsExport;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.view insertSubview:_webView atIndex:0];
    }
    return _webView;
}

-(WKUserScript*)adjustScreenSizeAndZooming:(BOOL)zooming {
    // 自适应屏幕宽度js
    NSString *adjustString;
    if (zooming) {
        adjustString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    }else{
        adjustString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'); document.getElementsByTagName('head')[0].appendChild(meta);";
    }
    WKUserScript *adjustScript = [[WKUserScript alloc] initWithSource:adjustString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    return adjustScript;
}

- (void)jsExportSet {
    self.jsExport[@"ocModel"] = [[OCModel alloc] init];
    self.jsExport[@"ocModel1"] = [[OCModel1 alloc] init];
    self.jsExport[@"jsHandler"] =  ^int(int i){
        NSLog(@"%d", i);
        return 11;
    };
    self.jsExport[@"jsHandlerCB"] = ^(NSString *str, JSExportCallBack cb){
        NSLog(@"%@", str);
        cb(@"aa");
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.backgroundColor = [UIColor whiteColor];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    [self jsExportSet];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}


- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    NSLog(@"prompt %@",prompt);
    completionHandler(@"");
}


@end
