//
//  HighLightLabel.h
//  HighLightLabel
//
//  Created by XY on 2016/10/17.
//  Copyright © 2016年 Kfj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighLightLabel : UILabel
{
    NSDataDetector *_detector;
    NSArray *_urlMatches;
    
}

@property (nonatomic,copy) NSString *content;
@property (nonatomic,assign) NSInteger textFontSize;
@property (nonatomic,assign) CGFloat lineSpace;
@property (nonatomic,strong) UIColor *textNormalColor;
@property (nonatomic,strong) UIColor *highLightColor;

+(CGFloat)customCellHeight:(NSString *)text fontSize:(NSInteger)fontSize maxWidth:(CGFloat)maxWidth lineSpace:(CGFloat)lineSpace;

@end
