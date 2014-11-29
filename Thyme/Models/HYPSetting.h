@interface HYPSetting : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^action)();

- (instancetype)initWithTitle:(NSString *)title action:(void (^)())action;

@end
