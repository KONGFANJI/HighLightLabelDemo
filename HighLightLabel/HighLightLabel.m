//
//  HighLightLabel.m
//  HighLightLabel
//
//  Created by XY on 2016/10/17.
//  Copyright © 2016年 Kfj. All rights reserved.
//

#import "HighLightLabel.h"
#import <CoreText/CoreText.h>
#import "UIResponder+Router.h"

@interface HighLightLabel ()
@property (nonatomic,strong) UILabel *textLabel;
@end
@implementation HighLightLabel

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        [self addSubview:_textLabel];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        [self addSubview:_textLabel];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    _textLabel.frame = self.bounds;
}

-(void)setLineSpace:(CGFloat)lineSpace{
    _lineSpace = lineSpace;
}
- (void)setTextNormalColor:(UIColor *)textNormalColor{
    _textNormalColor = textNormalColor;
    _textLabel.textColor = textNormalColor;
}
- (void)setHighLightColor:(UIColor *)highLightColor{
    _highLightColor = highLightColor;
}
-(void)setTextFontSize:(NSInteger)textFontSize{
    _textFontSize = textFontSize;
    _textLabel.font = [UIFont systemFontOfSize:textFontSize];
}
- (void)setContent:(NSString *)content{
    _content = content;
    _urlMatches = [_detector matchesInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:self.content];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:_lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [self.content length])];
    [_textLabel setAttributedText:attributedString];
    [self highlightLinksWithIndex:NSNotFound];
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_textLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink || [match resultType] == NSTextCheckingTypeReplacement) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:_textNormalColor range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:_highLightColor range:matchRange];
            }
            
            //            if (IS_OS_8_OR_LATER) {
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
            //            }
        }
    }
    
    _textLabel.attributedText = attributedString;
}
- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [self.textLabel.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.textLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.textLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.textLabel.font range:NSMakeRange(0, [self.textLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.textLabel.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.textLabel.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.textLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.textLabel.numberOfLines > 0 ? MIN(self.textLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}
-(void)bubbleViewPressed:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:_textLabel];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [self routerEventWithName:@"KHIGHLIGHTLABELTAPNAME" userInfo:@{@"url":match.URL.absoluteString}];
                
                break;
            }
        } else if ([match resultType] ==  NSTextCheckingTypeReplacement) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                //                [self routerEventWithName:kRouterEventMenuTapEventName userInfo:@{KMESSAGEKEY:self.model, @"text":match.replacementString}];
                break;
            }
        }
    }
}
+(CGFloat)customCellHeight:(NSString *)text fontSize:(NSInteger)fontSize maxWidth:(CGFloat)maxWidth lineSpace:(CGFloat)lineSpace{
    CGSize textBlockMinSize = {maxWidth, CGFLOAT_MAX};
    
    CGSize size;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    
    size = [text boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle}context:nil].size;
    
    return size.height;
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
