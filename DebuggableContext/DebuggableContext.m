//
//  DebuggableContext.m
//  ShakeDebug
//
//  Created by jojo on 2018/3/29.
//  Copyright © 2018年 jojo. All rights reserved.
//

#import "DebuggableContext.h"

#pragma mark - DebuggableContextItem
@interface DebuggableContextItem ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) DebuggableAction _Nullable action;
@end

@implementation DebuggableContextItem
- (instancetype)initWithName:(NSString *)name action:(DebuggableAction)action {
    if (self = [super init]) {
        _name = name;
        _action = action;
    }
    return self;
}
@end

#pragma mark - Shake Window
static NSString *const ContextDebugDeviceShakenNotification = @"ContextDebugDeviceShakenNotification";

@implementation ShakeWindow
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ContextDebugDeviceShakenNotification object:nil];
        return;
    }
    [super motionBegan:motion withEvent:event];
}
@end

#pragma marl - Responser
static DebuggableContextResponser *shared = nil;
@implementation DebuggableContextResponser {
    NSMapTable <NSString *, id<DebuggableContext>> *_map;
}
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DebuggableContextResponser alloc] init];
    });
    return shared;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsWeakMemory];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShake:) name:ContextDebugDeviceShakenNotification object:nil];
    }
    return self;
}

- (void)registerDebug:(id<DebuggableContext>)target {
    NSString *key = [target debugName];
    if ([_map objectForKey:key]) {
        key = [NSString stringWithFormat:@"%@-%p",key,target];
    }
    [_map setObject:target forKey:key];
}

- (void)unregisterDebug:(id<DebuggableContext>)target {
    NSArray *keys = [[_map keyEnumerator] allObjects];
    for (NSString *key in keys) {
        id obj = [_map objectForKey:key];
        if ((__bridge void *)obj == (__bridge void *)target) {
            [_map removeObjectForKey:key];
            break;
        }
    }
}

- (void)onShake:(id)sender {
    NSArray <id<DebuggableContext>> *allContexts = [_map objectEnumerator].allObjects;
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    NSMutableArray <id<DebuggableContext>> *validateContexts = [NSMutableArray array];
    BOOL (^filter)(id target) = ^BOOL(id target) {return YES;};
    
    if ([topVC conformsToProtocol:@protocol(DebuggableContext)] && [topVC respondsToSelector:@selector(filterContext:)]) {
        filter = ^BOOL(id target) {
            return [((NSObject<DebuggableContext> *)topVC) filterContext:target];
        };
    }
    
    for (id<DebuggableContext> target in allContexts) {
        if (filter(target)) {
            [validateContexts addObject:target];
        }
    }
    
    if (validateContexts.count == 1) {
        [self showContext:validateContexts[0] onVC:topVC];
    } else {
        [self showContexts:validateContexts onVC:topVC];
    }
}

- (void)showContexts:(NSArray <id<DebuggableContext>> *)contexts onVC:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DebugContext" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (id<DebuggableContext> context in contexts) {
        [alert addAction:[UIAlertAction actionWithTitle:[context debugName] style:UIAlertActionStyleDefault handler:nil]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}

- (void)showContext:(id<DebuggableContext>)context onVC:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[context debugName] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([context debuggableMenus]) {
        for (DebuggableContextItem *item in [context debuggableMenus]) {
            [alert addAction:[UIAlertAction actionWithTitle:item.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                item.action();
            }]];
        }
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}
@end

#pragma mark - UIViewController+Debuggable
@interface UIViewController (Debuggable) <DebuggableContext>
@end

@implementation UIViewController (Debuggable)

- (nonnull NSString *)debugName {
    return NSStringFromClass([self class]);
}

- (nonnull NSArray<DebuggableContextItem *> *)debuggableMenus {
    return nil;
}

- (BOOL)filterContext:(nonnull id<DebuggableContext>)target {
    return true;
}

@end


