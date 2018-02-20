//
//  ViewController.m
//  Template method mode
//
//  Created by mac on 2018/2/20.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import <Realm.h>
#import "DataManager.h"
#import "People.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //将所有的数据都删除
//    [[DataManager shareInstance] deleteAllObjects:[Person class]];
    //存储数据
    for (int i = 0; i < 100; i++) {
         People *person = [[People alloc] init];
        person.gender = [NSString stringWithFormat:@"性别%d",i];
        person.sex = @"男";
        person.name = [NSString stringWithFormat:@"张三%d",i];
        person.age = i;
        [[DataManager shareInstance] addObject:person];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    RLMResults<People*> *results = [[DataManager shareInstance] search:[People class]];
    if(results.count > 0) {
       
        People *person = results[0];
        RLMRealm *realim = [RLMRealm defaultRealm];
        [realim beginWriteTransaction];
        person.name = @"里斯";
        [realim commitWriteTransaction];
    }
    
     People *person = results[0];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
