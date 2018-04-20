# DebuggableContext-OC
The Objective-C version of [onevcat's DebuggableContext](https://github.com/onevcat/DebuggableContext)

## Usage 

1. Implement `DebuggableContext` protocol

    ```objc
    @interface UIViewController (Debuggable) <DebuggableContext>

    #if DEBUG
    - (nonnull NSArray<DebuggableContextItem *> *)debuggableMenus {
        return @[
                [[DebuggableContextItem alloc] initWithName:@"Debuggable" action:^{
                    NSLog(@"Debuggable");
                }],
                [[DebuggableContextItem alloc] initWithName:@"Debuggable" action:^{
                    NSLog(@"Debuggable");
                }]
                ];
    }
    #endif
    ```

2. Register at proper time. 

    ```objc
    - (void)viewDidLoad {
        [super viewDidLoad];
        REGISTER_DEBUG(self);
    }
    ```

3. Replace the main `UIWindow` to `ShakeWindow` at `AppDelegate`.

    ```objc
    - (UIWindow *)window {
    #if DEBUG
        return [self shakeWindow];
    #else
        if (!_window) {
            _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        return _window;
    #endif
    }

    - (ShakeWindow *)shakeWindow {
        if (!_shakeWindow) {
            _shakeWindow = [[ShakeWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _shakeWindow.backgroundColor = [UIColor redColor];
        }
        return _shakeWindow;
    }
    ```

4. Trigger shake gesture at runtime (`Cmd+Ctrl+Z` for simulator)


## Notice

If too much displayed `DebuggableContextItem`, and you only need to show a bit of them, implement `filterContext:` to filter it.

```objc
- (BOOL)filterContext:(id<DebuggableContext>)target {
    return [NSStringFromClass([target class]) isEqualTo:NSStringFromClass([self class])]
}
```
