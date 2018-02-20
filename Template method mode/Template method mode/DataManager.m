//
//  DataManager.m
//  Template method mode
//
//  Created by mac on 2018/2/20.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "DataManager.h"
#import <Realm/Realm.h>

#warning 每次RLMObject的变动，提交审核时此版本加一
uint64_t const CacheDataCurrentVersion = 3;
NSString *const CacheDataEncryptionKey = @"com.coderPeng.data";

@implementation DataManager

+ (void)onfonigDataManager {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docPath objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"text.realm"];
    config.fileURL = [NSURL URLWithString:filePath];
    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    config.schemaVersion = CacheDataCurrentVersion;
    // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < config.schemaVersion) {
            // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
        }
    };
#if TARGET_IPHONE_SIMULATOR //由于iOS10 的模拟器bug 不支持非共享的keychain 所以在模拟器环境直接加密
    
    NSString *encryptionString = @"htG7k5iRidTSUq9rSkKD3b7jEs/ftJUfJ9iis4CXxRTkfFapFxA6q29EMxjbMAcqgosqMMLvwk4eqtvmJjsq7A==";
    NSData *encryptionData = [[NSData alloc] initWithBase64EncodedString:encryptionString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    config.encryptionKey = encryptionData;
    
#else
    //真机环境随机生成密钥并存于keychain中
    NSData *data = [BKKeychain valueForKey:CacheDataEncryptionKey];
    if(data) {
        
        config.encryptionKey = data;
        
    } else {
        // 产生随机密钥
        NSMutableData *key = [NSMutableData dataWithLength:64];
        (void)SecRandomCopyBytes(kSecRandomDefault, key.length, (uint8_t *)key.mutableBytes);
        
        [BKKeychain setObject:key forKey:CacheDataEncryptionKey];
        
        config.encryptionKey = key;
    }
    
#endif
    
    config.readOnly = NO;
    // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
    [RLMRealmConfiguration setDefaultConfiguration:config];
    // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
    [RLMRealm defaultRealm];
}

-(instancetype)init {
    
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

+(instancetype)shareInstance {
    
    static DataManager *dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        //配置realm相关配置
        [DataManager onfonigDataManager];
        dataManager = [[DataManager alloc] init];
    });
    return dataManager;
}
- (RLMRealm *)defaultRealm {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    return realm;
}

-(void)addObject:(__kindof RLMObject *)obj {
    
    RLMRealm *realm = [self defaultRealm];
    [realm transactionWithBlock:^{
       
        [realm addObject:obj];
    }];
}

-(void)addOrUpdateObject:(__kindof RLMObject *)obj {
    
    RLMRealm *realm = [self defaultRealm];
    [realm transactionWithBlock:^{
        
        [realm addOrUpdateObject:obj];
    }];
}

-(void)addObjects:(id<NSFastEnumeration>)objs {
    
    RLMRealm *realm = [self defaultRealm];
    [realm beginWriteTransaction];
    [realm addObjects:objs];
    [realm commitWriteTransaction];
}

-(void)deleteObject:(__kindof RLMObject *)obj {
    
    RLMRealm *realm = [self defaultRealm];
    [realm transactionWithBlock:^{
       
        [realm deleteObject:obj];
    }];
}

-(void)deleteObjects:(id)array {
    
    RLMRealm *realm = [self defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:array];
    [realm commitWriteTransaction];
}

-(void)deleteAllObjects:(Class)cls {
    
    if (![self isSubclassOfCacheObjectClass:cls]) {
        return;
    }
    RLMResults *results = [self search:cls];
    
    [self deleteObjects:results];
    
}

-(RLMResults*)search:(Class)cls {
    return [self search:cls predicate:nil sorted:nil ascending:YES];
}

-(RLMResults*)search:(Class)cls sorted:(NSString*)sorted ascending:(BOOL)ascending {
    return [self search:cls predicate:nil sorted:sorted ascending:ascending];
}

-(RLMResults*)search:(Class)cls predicate:(NSString*)predicate {
    return [self search:cls predicate:predicate sorted:nil ascending:YES];
}

-(RLMResults*)search:(Class)cls predicate:(NSString*)predicate sorted:(NSString*)sorted ascending:(BOOL)ascending {
    if(![self isSubclassOfCacheObjectClass:cls]) {
        return nil;
    }
    
    RLMResults *results;
    if(predicate) {
        results = [cls objectsWhere:predicate];
    } else {
        results = [cls allObjects];
    }
    
    if(results && results.count > 0) {
        if(sorted) {
            [results sortedResultsUsingKeyPath:sorted ascending:ascending];
        }
    }
    
    return results;
}

#pragma mark ==================helper method==================
-(BOOL)isSubclassOfCacheObjectClass:(Class)cls {
    if(![cls isSubclassOfClass:[RLMObject class]]) {
        NSLog(@"错误：%@不是RLMObject类", cls);
        return NO;
    }
    return YES;
}


@end
