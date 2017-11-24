//
//  PathEngine.m
//  MaoBuTou
//
//  Created by 心冷如灰 on 2017/2/15.
//  Copyright © 2017年 心冷如灰. All rights reserved.
//

#import "PathEngine.h"

@implementation PathEngine

SYNTHESIZE_SINGLETON_FOR_CLASS(PathEngine);

//获取应用程序路径
+ (NSString *)getApplicationPath {
    return NSHomeDirectory();
}

//获取temp路径
+ (NSString *)getTempPath {
    return NSTemporaryDirectory();
}

//获取获取document路径
+ (NSString *)getDocumentPath {
    return NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

//获取cache缓存路径
+(NSString *)getCachePath {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type {
    return [[NSBundle mainBundle] pathForResource:name ofType:type];
}

//创建路径
+ (BOOL)createPath:(NSString *)path {
    NSAssert((path != nil), @"path can't be nil!");
    BOOL ret = [PathEngine isExistFile:path];
    if ( !ret ) {
        __block NSMutableString *tmpPath = [[NSMutableString alloc] initWithCapacity:1];
        NSArray *dirs = [path componentsSeparatedByString:@"/"];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ( ![obj isEqualToString:@""] ) {
                [tmpPath appendFormat:@"/%@", obj];
                if ( ![PathEngine isExistFile:tmpPath] ) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
            }
        }];
        ret = [PathEngine isExistFile:tmpPath];
    }
    return ret;
}

//创建文件
+ (BOOL)createFile:(NSString *)fileName {
    NSAssert((fileName != nil), @"fileName can't be nil!");
    return [PathEngine createFile:[fileName lastPathComponent] path:[fileName stringByDeletingLastPathComponent]];
}

+ (BOOL)createFile:(NSString *)fileName path:(NSString *)path {
    NSAssert((fileName != nil), @"fileName can't be nil!");
    NSAssert((path != nil), @"path can't be nil!");
    BOOL ret = NO;
    NSString *fullFile = [NSString stringWithFormat:@"%@/%@", path, fileName];
    if ( [PathEngine isExistFile:fullFile] ) {
        NSLog(@"%@ is exist, so can't create again!", fullFile);
        ret = NO;
    } else {
        if ( [PathEngine createPath:path] ) {
            ret = [[NSFileManager defaultManager] createFileAtPath:fullFile contents:nil attributes:nil];
        } else {
            NSLog(@"%@ path create error!", path);
            ret = NO;
        }
    }
    return ret;
}

+ (BOOL)writeToFile:(NSData *)data fullName:(NSString *)fullName {
    NSAssert((data != nil), @"data can't be nil!");
    NSAssert((fullName != nil), @"fullName can't be nil!");
    
    BOOL ret = NO;
    NSString *pathStr = fullName.stringByDeletingLastPathComponent;
    if ( [PathEngine createPath:pathStr] ) {
        ret = [data writeToFile:fullName atomically:YES];
    }
    return ret;
}

//删除文件
+ (BOOL)removeFile:(NSString *)fileName path:(NSString *)path {
    BOOL ret = NO;
    NSString *fullFile = [NSString stringWithFormat:@"%@/%@", path, fileName];
    if ( [PathEngine isExistFile:fullFile] ) {
        ret = [[NSFileManager defaultManager] removeItemAtPath:fullFile error:nil];
    } else {
        NSLog(@"%@ isn't exist, so can't remove!", fullFile);
    }
    return ret;
}

//判断文件是否存在
+ (BOOL)isExistFile:(NSString *)fileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
}

//判断文件是否完整
+ (BOOL)isFullFile:(NSString *)filePath size:(long long)size {
    BOOL ret = NO;
    if ( [PathEngine isExistFile:filePath] && (size == [PathEngine getFileSize:filePath]) ) {
        ret = YES;
    }
    return ret;
}

//获取文件大小
+ (unsigned long long)getFileSize:(NSString *)filePath {
    return [[NSFileHandle fileHandleForWritingAtPath:filePath] seekToEndOfFile];
}

// =============================================================================================

+ (double)getFolderSize:(NSString *)folderPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
        
    }
    return folderSize/1024.0/1024.0;
}

+ (void)removeFolder:(NSString *)folderPath {
    if (![self isExistFile:folderPath]) {
        return;
    }
    NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        [self removeFile:fileName path:folderPath];
    }
    
}

+ (BOOL)createFile:(NSString *)filePath directory:(NSArray *)directoryArray {
    NSAssert((filePath != nil), @"filePath can't be nil!");
    NSAssert((directoryArray != nil), @"directoryArray can't be nil!");
    BOOL ret = [self createPath:filePath];
    
    if (ret) {
        for (NSInteger i = 0; i < directoryArray.count; i++) {
            ret =  [self createPath:[NSString stringWithFormat:@"%@/%@",filePath,directoryArray[i]]];
            if (!ret) {
                return ret;
            }
        }
    }
    return ret;
}



- (instancetype)init {
    self = [super init];
    if ( self ) {
        
    }
    return self;
}

@end
