//
//  PathEngine.h
//  MaoBuTou
//
//  Created by 心冷如灰 on 2017/2/15.
//  Copyright © 2017年 心冷如灰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface PathEngine : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PathEngine);

//获取应用程序路径
+ (NSString *)getApplicationPath;

//获取temp路径
+ (NSString *)getTempPath;

//获取获取document路径
+ (NSString *)getDocumentPath;

//获取cache缓存路径
+ (NSString *)getCachePath;

//获取资源文件
+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type;

//创建路径
+ (BOOL)createPath:(NSString *)path;

//创建文件
+ (BOOL)createFile:(NSString *)fileName;

+ (BOOL)createFile:(NSString *)fileName path:(NSString *)path;

+ (BOOL)writeToFile:(NSData *)data fullName:(NSString *)fullName;

//删除文件
+ (BOOL)removeFile:(NSString *)fileName path:(NSString *)path;

//判断文件是否存在
+ (BOOL)isExistFile:(NSString *)filePath;

//判断文件是否完整
+ (BOOL)isFullFile:(NSString *)filePath size:(long long)size;

//获取文件大小
+ (unsigned long long)getFileSize:(NSString *)filePath;


/**
 获取文件夹下面的所有文件大小
 
 @param folderPath 文件夹 路径 完整
 
 @return 返回多少M
 */
+ (double)getFolderSize:(NSString *)folderPath;


/**
 删除文件夹下面的所有文件
 
 @param folderPath 需要删除文件夹的路径 完整的
 
 */
+(void)removeFolder:(NSString *)folderPath;

/**
 创建同一路径下 存在多个文件夹
 
 @param filePath 路径 相同的路径
 @param directoryArray 同一路径下 存在对个文件夹
 @return 返回成功 失败
 */
+ (BOOL)createFile:(NSString *)filePath directory:(NSArray *)directoryArray;
@end
