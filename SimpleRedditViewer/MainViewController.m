//
//  MainViewController.m
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 3/27/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import "MainViewController.h"
#import "RedditItemViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray *redditItems;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSString *currentSubRedditString;
- (void)reloadTableWithSubReddit:(NSString *)subRedditString;
- (NSURL *)getUrlWithSubRedditName:(NSString *)subRedditName;
- (IBAction)loadMoreButtonPressed:(id)sender;

@end

@implementation MainViewController

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (NSMutableArray *)redditItems
{
    if (!_redditItems) {
        _redditItems = [[NSMutableArray alloc] init];
    }
    return _redditItems;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loadMoreButton setFrame:CGRectMake(100.0, 0.0, 120.0, 40.0)];
        [loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
        [loadMoreButton addTarget:self action:@selector(loadMoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:loadMoreButton];
    }
    return _footerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
     
- (void)reloadTableWithSubReddit:(NSString *)subRedditString
{
    self.currentSubRedditString = subRedditString;
    NSURL *currentSubReddit = [self getUrlWithSubRedditName:subRedditString];
    
    NSURLSessionTask  *task = [self.session dataTaskWithURL:currentSubReddit completionHandler:
                               ^(NSData *data, NSURLResponse *response, NSError *error){
                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                                   
                                   if (error)
                                   {
                                       NSLog(@"Error! %@", error);
                                       return;
                                   }
                                   
                                   NSError *jsonError;
                                   NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&jsonError];
                                   NSDictionary *children = [jsonDictionary valueForKeyPath:@"data.children"];
                                   
                                   NSMutableArray *redditObjects = [[NSMutableArray alloc] init];
                                   
                                   for (NSDictionary *childDictionary in children) {
                                       [redditObjects addObject:[childDictionary valueForKey:@"data"]];
                                   }
                                   
                                   //NSDictionary *testDictionary = [redditObjects objectAtIndex:24];
                                   //NSLog(@"%@", testDictionary);
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       self.redditItems = redditObjects;
                                       [self.tableView reloadData];
                                   });
                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               }];
    [task resume];
}

- (NSURL *)getUrlWithSubRedditName:(NSString *)subRedditName
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.reddit.com/r/%@/.json", subRedditName];
    NSURL *subRedditUrl = [NSURL URLWithString:urlString];
    return subRedditUrl;
}

- (IBAction)loadMoreButtonPressed:(id)sender;
{
    if ([self.redditItems count] > 0) {
        NSInteger lastItem = [self.redditItems count] - 1;
        NSString *lastItemName = [[self.redditItems objectAtIndex:lastItem] valueForKey:@"name"];
        NSString *urlString = [NSString stringWithFormat:@"http://www.reddit.com/r/%@/.json?limit=25&after=%@", self.currentSubRedditString, lastItemName];
        NSURL *currentSubReddit = [NSURL URLWithString:urlString];
        
        NSURLSessionTask  *task = [self.session dataTaskWithURL:currentSubReddit completionHandler:
                                   ^(NSData *data, NSURLResponse *response, NSError *error){
                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                                       
                                       if (error)
                                       {
                                           NSLog(@"Error! %@", error);
                                           return;
                                       }
                                       
                                       NSError *jsonError;
                                       NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&jsonError];
                                       NSDictionary *children = [jsonDictionary valueForKeyPath:@"data.children"];
                                       
                                       NSMutableArray *redditObjects = [[NSMutableArray alloc] init];
                                       
                                       for (NSDictionary *childDictionary in children) {
                                           [redditObjects addObject:[childDictionary valueForKey:@"data"]];
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.redditItems addObjectsFromArray:redditObjects];
                                           [self.tableView reloadData];
                                       });
                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                   }];
        [task resume];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.redditItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"RedditItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.tag = [indexPath row];
    NSDictionary *cellDictionary = [self.redditItems objectAtIndex:[indexPath row]];
    
    if (cellDictionary) {
        cell.imageView.image = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellDictionary[@"thumbnail"]]];
                                 
                                 UIImage *thumbnail = [[UIImage alloc] initWithData:imageData];
                                 if (thumbnail) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (cell.tag == indexPath.row) {
                                             cell.imageView.image = thumbnail;
                                             [cell setNeedsLayout];
                                         }
                                     });
                                 }
                                 });
        
        cell.textLabel.text = [cellDictionary valueForKey:@"title"];
    }
   
    return cell;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RedditItemViewController *redditItemViewController = [segue destinationViewController];
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    NSDictionary *itemDictionary = [self.redditItems objectAtIndex:[cellIndex row]];
    NSURL *itemURL = [NSURL URLWithString:[itemDictionary valueForKey:@"url"]];
    [redditItemViewController setWebViewURL:itemURL];
}

#pragma mark - Searchbar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self reloadTableWithSubReddit:[searchBar text]];
}


@end
