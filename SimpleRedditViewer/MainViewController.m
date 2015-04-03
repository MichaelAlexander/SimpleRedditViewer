//
//  MainViewController.m
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 3/27/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import "MainViewController.h"
#import "RedditItemViewController.h"
#import "RedditCell.h"
#import "AFNetworking.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray *redditItems;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSString *currentSubRedditString;
@property (nonatomic, strong) RedditCell *prototypeCell;
- (void)reloadTableWithSubReddit:(NSString *)subRedditString;
- (NSURL *)getUrlWithSubRedditName:(NSString *)subRedditName;
- (IBAction)didSelectCellOrCellButton:(id)sender;
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

- (RedditCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"RedditCell"];//NSStringFromClass([RedditCell class])];

    }
    return _prototypeCell;
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
    NSURLRequest *request = [NSURLRequest requestWithURL:currentSubReddit];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSDictionary *children = [responseObject valueForKeyPath:@"data.children"];
        
        NSMutableArray *redditObjects = [[NSMutableArray alloc] init];
        
        for (NSDictionary *childDictionary in children) {
            [redditObjects addObject:[childDictionary valueForKey:@"data"]];
        }
        self.redditItems = redditObjects;
        /*
        if ([self.redditItems count] > 0)
        {
            NSLog(@"%@", [self.redditItems objectAtIndex:0]);
        }*/
        
        [self.tableView reloadData];
        
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Reddit Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
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
        NSURLRequest *request = [NSURLRequest requestWithURL:currentSubReddit];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSDictionary *children = [responseObject valueForKeyPath:@"data.children"];
            
            NSMutableArray *redditObjects = [[NSMutableArray alloc] init];
            
            for (NSDictionary *childDictionary in children) {
                [redditObjects addObject:[childDictionary valueForKey:@"data"]];
            }
            [self.redditItems addObjectsFromArray:redditObjects];
            [self.tableView reloadData];
            
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Reddit Data"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        [operation start];

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
    NSString *reuseIdentifier =  @"RedditCell";
    RedditCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.tag = [indexPath row];
    NSDictionary *cellDictionary = [self.redditItems objectAtIndex:[indexPath row]];
    
    if (cellDictionary) {
        cell.thumbView.image = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellDictionary[@"thumbnail"]]];
                                 
                                 UIImage *thumbnail = [[UIImage alloc] initWithData:imageData];
                                 if (thumbnail) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (cell.tag == indexPath.row) {
                                             cell.thumbView.image = thumbnail;
                                             [cell setNeedsLayout];
                                         }
                                     });
                                 }
                                 });
        [cell.title setNumberOfLines:0];
        cell.title.text = [cellDictionary valueForKey:@"title"];
        cell.subLabel.text = [cellDictionary valueForKeyPath:@"subreddit"];
        NSString *commentString = [NSString stringWithFormat:@"%@", [cellDictionary valueForKeyPath:@"num_comments"]];
        [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];
    }
   
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - Navigation

- (IBAction)didSelectCellOrCellButton:(id)sender
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    RedditItemViewController *redditItemViewController = [segue destinationViewController];
    
    NSIndexPath *cellIndex;
    NSDictionary *itemDictionary;
    NSURL *itemURL;
    
    //If the cell is tapped go to the link, otherwise go to the comments URL
    if ([[segue identifier] isEqualToString:@"cellTap"])
    {
        cellIndex = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        itemDictionary = [self.redditItems objectAtIndex:[cellIndex row]];
        itemURL = [NSURL URLWithString:[itemDictionary valueForKey:@"url"]];
    }else{
        RedditCell *cellForButton = (RedditCell *)[[sender superview] superview];
        cellIndex = [self.tableView indexPathForCell:cellForButton];
        itemDictionary = [self.redditItems objectAtIndex:[cellIndex row]];
        NSString *commentURLString = [NSString stringWithFormat:@"http://www.reddit.com%@", [itemDictionary valueForKey:@"permalink"]];
        itemURL = [NSURL URLWithString:commentURLString];
    }
    [redditItemViewController setWebViewURL:itemURL];
}

#pragma mark - Searchbar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self reloadTableWithSubReddit:[searchBar text]];
}


@end
