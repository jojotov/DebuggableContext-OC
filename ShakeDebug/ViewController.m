//
//  ViewController.m
//  ShakeDebug
//
//  Created by jojo on 2018/3/29.
//  Copyright © 2018年 jojo. All rights reserved.
//

#import "ViewController.h"
#import "DebuggableContext.h"

@interface ViewController () <DebuggableContext>

@end

@implementation ViewController

#if DEBUG
- (NSArray <DebuggableContextItem *> *)debuggableMenus {
    return @[
             [[DebuggableContextItem alloc] initWithName:@"Log self" action:^{
                 NSLog(@"%@",self);
             }]
             ];
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
#if DEBUG
    REGISTER_DEBUG(self);
#endif
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
