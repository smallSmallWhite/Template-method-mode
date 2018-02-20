//
//  People.h
//  Template method mode
//
//  Created by mac on 2018/2/20.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Realm/Realm.h>

@interface People : RLMObject

@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,assign) NSInteger age;

@end
