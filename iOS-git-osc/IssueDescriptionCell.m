//
//  IssueDescriptionCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueDescriptionCell.h"

@implementation IssueDescriptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
        [self setAutoLayout];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Subviews and Layout

- (void)initSubviews
{
    _issueDescription = [UIWebView new];
    _issueDescription.scrollView.scrollEnabled = NO;
    _issueDescription.scrollView.bounces = NO;
    _issueDescription.opaque = NO;
    _issueDescription.backgroundColor = [UIColor clearColor];
    //_issueDescription.scalesPageToFit = YES;
    [self.contentView addSubview:_issueDescription];
}

- (void)setAutoLayout
{
    [_issueDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_issueDescription]-(8)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_issueDescription)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_issueDescription]-(8)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_issueDescription)]];
}


@end