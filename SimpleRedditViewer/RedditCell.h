//
//  RedditCell.h
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 5/14/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedditCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *subLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbView;
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;

@end
