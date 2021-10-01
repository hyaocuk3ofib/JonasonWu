//
//  NotesView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NotesView.h"
#import "NoteCell.h"
#import "NoteEditingView.h"
#import "GLGitlab.h"
#import "Note.h"
#import "Tools.h"
#import "CreationInfoCell.h"
#import "IssueDescriptionCell.h"

@interface NotesView ()

@property (nonatomic, strong) NoteCell *prototypeCell;

@end

static NSString * const NoteCellId = @"NoteCell";
static NSString * const CreationInfoCellId = @"CreationInfoCell";
static NSString * const IssueDescriptionCellId = @"IssueDescriptionCell";

@implementation NotesView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[NoteCell class] forCellReuseIdentifier:NoteCellId];
    [self.tableView registerClass:[CreationInfoCell class] forCellReuseIdentifier:CreationInfoCellId];
    [self.tableView registerClass:[IssueDescriptionCell class] forCellReuseIdentifier:IssueDescriptionCellId];
    
    _notes = [Note getNotesForIssue:_issue page:1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评论"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(editComment)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _notes.count == 0? 1: 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return _notes.count;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {return 41;}
        else {return 450;}
    } else {
        if (!self.prototypeCell) {
            self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NoteCellId];
        }
        
        [self configureNoteCell:self.prototypeCell forRowInSection:indexPath.row];
        
        [self.prototypeCell layoutIfNeeded];
        CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%lu条评论", (unsigned long)_notes.count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0) {return nil;}
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    UITextView *titleText = [UITextView new];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.font = [UIFont boldSystemFontOfSize:13];
    [headerView addSubview:titleText];
    titleText.translatesAutoresizingMaskIntoConstraints = NO;
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleText]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(titleText)]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[titleText]-8-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(titleText)]];
    
    
    if (section == 0) {
        titleText.text = _issue.title;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        CreationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CreationInfoCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [Tools setPortraitForUser:_issue.author view:cell.portrait cornerRadius:2.0];
        NSString *timeInterval = [Tools intervalSinceNow:_issue.createdAt];
        NSString *creationInfo = [NSString stringWithFormat:@"%@在%@创建该问题", _issue.author.name, timeInterval];
        [cell.creationInfo setText:creationInfo];
        
        return cell;
    } else if (section == 0 && row == 1) {
        IssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:IssueDescriptionCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"user-scalable=no, width=device-width\"></head><body>%@</body><html>", _issue.issueDescription];
        
        [cell.issueDescription loadHTMLString:html baseURL:nil];
        
        return cell;
    } else {
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NoteCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self configureNoteCell:cell forRowInSection:indexPath.row];
        
        return cell;
    }
}

- (void)configureNoteCell:(NoteCell *)noteCell forRowInSection:(NSInteger)row
{
    GLNote *note = [_notes objectAtIndex:row];
    
    [Tools setPortraitForUser:note.author view:noteCell.portrait cornerRadius:2.0];
    [noteCell.author setText:note.author.name];
    noteCell.body.text = [Tools flattenHTML:note.body];
    [noteCell.time setAttributedText:[Tools getIntervalAttrStr:note.createdAt]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        UITextView *titleView = [UITextView new];
        titleView.text = _issue.title;
        titleView.font = [UIFont boldSystemFontOfSize:13];
        
        CGSize size = [titleView sizeThatFits:CGSizeMake(330, MAXFLOAT)];
        
        return size.height;
    }
    return 35;
}

#pragma mark - 编辑评论
- (void)editComment
{
    NoteEditingView *noteEditingView = [[NoteEditingView alloc] init];
    noteEditingView.issue = _issue;
    [self.navigationController pushViewController:noteEditingView animated:YES];
}


@end
