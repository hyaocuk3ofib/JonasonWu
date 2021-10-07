//
//  ProjectsTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectsTableController.h"
#import "ProjectCell.h"
#import "FilesTableController.h"
#import "NavigationController.h"
#import "ProjectDetailsView.h"
#import "GLGitlab.h"
#import "Project.h"
#import "Tools.h"

@interface ProjectsTableController ()

@property BOOL isLoadOver;
@property BOOL isLoading;

@end

@implementation ProjectsTableController
@synthesize projectsArray;
//@synthesize loadingMore;

static NSString * const cellId = @"ProjectCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:(NavigationController *)self.navigationController
                                                                                action:@selector(showMenu)];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:cellId];
    self.navigationController.navigationBar.translucent = NO;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _isLoadOver = NO;
    
    self.projectsArray = [NSMutableArray new];
    [self.projectsArray addObjectsFromArray:[self loadProjectsPage:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 表格显示及操作

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GLProject *project = [self.projectsArray objectAtIndex:indexPath.row];
    
    [Tools setPortraitForUser:project.owner view:cell.portrait cornerRadius:5.0];
    cell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
    cell.projectDescriptionField.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
    cell.languageField.text = project.language? project.language: @"Unknown";
    cell.forksCount.text = [NSString stringWithFormat:@"%i", project.forksCount];
    cell.starsCount.text = [NSString stringWithFormat:@"%i", project.starsCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row < self.projectsArray.count) {
        GLProject *project = [projectsArray objectAtIndex:row];
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] init];
            projectDetails.project = project;
            if (_projectsType > 2) {
                [self.navigationController pushViewController:projectDetails animated:YES];
            } else {
                [self.parentViewController.navigationController pushViewController:projectDetails animated:YES];
            }
        }
    }
}


#pragma mark - 基本数值设置

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projectsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isLoadOver) {return;}
    
    // 下拉到最底部时显示更多数据
	if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
	{
        BOOL reload = NO;
        NSUInteger page = projectsArray.count/20 + 1;
        [self.projectsArray addObjectsFromArray:[self loadProjectsPage:page]];
        reload = YES;
        
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
	}
}


#pragma mark - 刷新

- (void)refreshView:(UIRefreshControl *)refreshControl
{
    // http://stackoverflow.com/questions/19683892/pull-to-refresh-crashes-app helps a lot
    
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        [self.projectsArray removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.projectsArray addObjectsFromArray:[self loadProjectsPage:1]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                
                refreshInProgress = NO;
            });
        });
    }
}

- (void)reloadType:(NSInteger)NewProjectsType
{
    _projectsType = NewProjectsType;
    [self.projectsArray removeAllObjects];
    _isLoadOver = NO;
    
    [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:_projectsType onPage:1]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (NSArray *)loadProjectsPage:(NSUInteger)page
{
    NSArray *projects;
    
    if (_projectsType < 3) {
        projects = [Project loadExtraProjectType:_projectsType onPage:page];
    } else if (_projectsType == 3) {
        projects = [Project getOwnProjectsOnPage:page];
    } else if (_projectsType == 4) {
        projects = [Project getStarredProjectsForUser:_userID];
    } else if (_projectsType == 5) {
        projects = [Project getWatchedProjectsForUser:_userID];
    } else {
        projects = [Project getProjectsForLanguage:_languageID page:page];
    }
    
    if (projects.count < 20) {
        _isLoadOver = YES;
    }
    
    return projects;
}

@end
