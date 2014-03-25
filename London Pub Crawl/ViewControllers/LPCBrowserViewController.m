#import "LPCBrowserViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LPCBrowserViewController ()

@end

@implementation LPCBrowserViewController {
    NSURLRequest *request;
    NSURL *url;
}

- (id)initWithURLString:(NSString *)urlString
{
    url = [[NSURL alloc] initWithString:urlString];
    request = [NSURLRequest requestWithURL:url];
    self = [super initWithNibName:@"LPCBrowserViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (url) {
        [self.webView loadRequest:request];
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

@end
