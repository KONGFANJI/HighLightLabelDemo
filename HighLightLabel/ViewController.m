//
//  ViewController.m
//  HighLightLabel
//
//  Created by XY on 2016/10/17.
//  Copyright © 2016年 Kfj. All rights reserved.
//

#import "ViewController.h"
#import "HighLightLabel.h"
#import "UIResponder+Router.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic,strong)HighLightLabel *highLightLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.highLightLabel.frame = CGRectMake(15, 50, ScreenWidth - 30, [HighLightLabel customCellHeight:@"卡的就是你看多 https://www.baidu.com 看少看见到那边打开就是你的能力担当卡的难受大单独啊的爱看的爱的看到了 https://github.com/KONGFANJI?tab=repositories 看见俺等你靠近蓝色经典卡萨的看到垃圾是你的按时打卡机那是打算；控到死大神快来点击那是打开速度来asd阿里斯柯达速度卡 https://www.hao123.com/ 洛斯的" fontSize:14 maxWidth:ScreenWidth - 30 lineSpace:5]);
    
}
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    if ([eventName isEqualToString:@"KHIGHLIGHTLABELTAPNAME"]) {
        NSString *urlString = userInfo[@"url"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{@"url":urlString} completionHandler:^(BOOL success) {
            NSLog(@"跳转成功：%@",urlString);
        }];

    }
}
- (HighLightLabel *)highLightLabel{
    if (!_highLightLabel) {
        _highLightLabel = [[HighLightLabel alloc]init];
        _highLightLabel.textNormalColor = [UIColor blackColor];
        _highLightLabel.highLightColor = [UIColor redColor];
        _highLightLabel.textFontSize = 14;
        _highLightLabel.lineSpace = 5;

        _highLightLabel.content = @"卡的就是你看多 https://www.baidu.com 看少看见到那边打开就是你的能力担当卡的难受大单独啊的爱看的爱的看到了 https://github.com/KONGFANJI?tab=repositories 看见俺等你靠近蓝色经典卡萨的看到垃圾是你的按时打卡机那是打算；控到死大神快来点击那是打开速度来asd阿里斯柯达速度卡 https://www.hao123.com/ 洛斯的";
        
        [self.view addSubview:_highLightLabel];
    }
    return _highLightLabel;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
