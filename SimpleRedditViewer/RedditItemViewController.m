//
//  RedditItemViewController.m
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 4/21/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import "RedditItemViewController.h"

@interface RedditItemViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *itemURL;
- (void)loadWebView;

@end

@implementation RedditItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWebView];
}

- (void)setWebViewURL:(NSURL *)url
{
    self.itemURL = url;
}

- (void)loadWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.itemURL];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
}

@end
