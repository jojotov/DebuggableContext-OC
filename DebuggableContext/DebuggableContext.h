//
//  DebuggableContext.h
//  ShakeDebug
//
//  Created by jojo on 2018/3/29.
//  Copyright © 2018年 jojo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *  Register `self` to debuggable list.
 */
#define REGISTER_DEBUG(target) [[DebuggableContextResponser shared] registerDebug:target];

/**
 *  UnRegister `self` from debuggable list.
 */
#define UNREGISTER_DEBUG(target) [[DebuggableContextResponser shared] unregisterDebug:target];

NS_ASSUME_NONNULL_BEGIN
typedef void(^DebuggableAction)(void);

#pragma mark - DebuggableContextItem Object
/**
 *  `DebuggableContextItem` contains name and action of each debuggable menu
 */
@interface DebuggableContextItem: NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) DebuggableAction _Nullable action;

- (instancetype)initWithName:(NSString *)name action:(DebuggableAction)action;

@end

#pragma mark - DebuggableContext Protocol
@protocol DebuggableContext

@optional

/**
 *  Implement this interface to add menus to the global map of debuggable menus.
 */
- (NSArray <DebuggableContextItem *> *)debuggableMenus;
- (NSString *)debugName;

/**
 *  Filtering the context of debuggable menus. If you have too many displayed debug menus,
 *  implement this methood to show only the specified target's debug menus.
 *  Return `NO` to exclude `target` context.
 */
- (BOOL)filterContext:(id<DebuggableContext>)target;
@end


#pragma mark - Shake Window
@interface ShakeWindow: UIWindow
@end

#pragma mark - Responser
@interface DebuggableContextResponser: NSObject
+ (instancetype)shared;
- (void)registerDebug:(id<DebuggableContext>)target;
- (void)unregisterDebug:(id<DebuggableContext>)target;
@end
NS_ASSUME_NONNULL_END
