//
//  RedditCell.m
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 5/14/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import "RedditCell.h"

@implementation RedditCell

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    self.title.preferredMaxLayoutWidth = CGRectGetWidth(self.title.frame);
}

/*
- (void)awakeFromNib
{
 
    // Initialization code
    thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, 2.0, 40.0, 40.0)];
    [self.contentView addSubview:thumbView];
    
    commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(278.0, 2.0, 40.0, 40.0)];
    [self.contentView addSubview:commentsLabel];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 2.0, 232.0, 30.0)];
    UIFont *titleFont = [UIFont fontWithName:@"Helvetic" size:14.0];
    [title setFont:titleFont];
    [self.contentView addSubview:title];
    
    subLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 34.0, 232.0, 10.0)];
    UIFont *subLabelFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    [subLabel setFont:subLabelFont];
    [self.contentView addSubview:subLabel];
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
