//
//  GLEvent.h
//  objc gitlab api
//
//  Created by Jon Staff on 1/28/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseObject.h"
#import "GLUser.h"
#import "GLProject.h"

@interface GLEvent : GLBaseObject

// id
@property (nonatomic, assign) int64_t id;
// target_type
@property (nonatomic, copy) NSString *targetType;
// target_id
@property (nonatomic, assign) int64_t targetId;
// title
@property (nonatomic, copy) NSString *title;
// data
@property (nonatomic, strong) NSDictionary *data;
// project_id
@property (nonatomic, assign) int64_t projectId;
// created_at
@property (nonatomic, strong) NSDate *createdAt;
// updated_at
@property (nonatomic, strong) NSDate *updatedAt;
// action
@property (nonatomic, assign) int action;
// author_id
@property (nonatomic, assign) int64_t authorId;
// public
@property (nonatomic) BOOL public;
// project
@property (nonatomic, strong) GLProject *project;
// user
@property (nonatomic, strong) GLUser *author;
// note
@property (nonatomic, strong) NSString *note;

@end
