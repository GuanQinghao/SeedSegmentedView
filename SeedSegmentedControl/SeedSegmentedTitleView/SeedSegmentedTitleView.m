//
//  SeedSegmentedTitleView.m
//  SeedSegmentedControl
//
//  Created by Hao on 2021/2/24.
//

#import "SeedSegmentedTitleView.h"


@interface SeedSegmentedTitleView ()

/// 分段标签标题滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;
/// 分段标签指示器
@property (nonatomic, strong) UIView *indicator;
/// 分段标签底部的分割线
@property (nonatomic, strong) UIView *separator;
/// 标题按钮
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;
/// 标题分隔符
@property (nonatomic, strong) NSMutableArray<UIView *> *splitterArray;

/// 按钮总宽度
@property (nonatomic, assign) CGFloat totalWidth;
/// 当前按钮下标
@property (nonatomic, assign) NSInteger currentIndex;
/// 按钮是否点击
@property (nonatomic, assign) BOOL clicked;
/// 选中的按钮
@property (nonatomic, strong) UIButton *clickedButton;

@end

@implementation SeedSegmentedTitleView

#pragma mark - public method

/// 设置SeedSegmentedTitleView的图片
/// @param images 默认的图片名称数组
/// @param selectedImages 选中的图片名称数组
/// @param style 图文显示样式
/// @param spacing 图片和文字的间距
- (void)s_setSegmentedTitleViewImages:(NSArray<NSString *> *)images selectedImages:(NSArray<NSString *> *)selectedImages withStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing {
    NSLog(@"");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 默认图片数量
        NSInteger normalImagesCount = images.count;
        // 选中图片数量
        NSInteger selectedImagesCount = selectedImages.count;
        
        if (normalImagesCount < selectedImagesCount) {
            
            NSAssert(YES, @"布局会发生未知问题");
        }
        
        // 默认图片
        [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx > normalImagesCount - 1) {
                
                *stop = YES;
            }
            
            [self setupImage:images[idx] forButton:obj withStyle:style spacing:spacing state:UIControlStateNormal];
        }];
        
        // 选中图片
        [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx > selectedImagesCount - 1) {
                
                *stop = YES;
            }
            
            [self setupImage:selectedImages[idx] forButton:obj withStyle:style spacing:spacing state:UIControlStateSelected];
        }];
    });
}

/// 根据下标设置SeedSegmentedTitleView的图片
/// @param image 默认的图片名称
/// @param selectedImage 选中的图片名称
/// @param index 下标值
/// @param style 图文显示样式
/// @param spacing 图片和文字的间距
- (void)s_setSegmentedTitleViewImage:(NSString *)image selectedImage:(NSString *)selectedImage forIndex:(NSInteger)index withStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing {
    NSLog(@"");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIButton *button = self.buttonArray[index];
        
        if (image) {
            
            [self setupImage:image forButton:button withStyle:style spacing:spacing state:UIControlStateNormal];
        }
        
        if (selectedImage) {
            
            [self setupImage:selectedImage forButton:button withStyle:style spacing:spacing state:UIControlStateSelected];
        }
    });
}

/// 设置按钮图片
/// @param image 按钮图片
/// @param button 按钮
/// @param style 图文样式
/// @param spacing 图文间距
/// @param state 按钮状态
- (void)setupImage:(NSString *)image forButton:(UIButton *)button withStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing state:(UIControlState)state {
    NSLog(@"");
    
    [button s_setTitleGraphicStyle:style spacing:spacing withOperation:^(UIButton * _Nonnull button) {
        
        [button setImage:[UIImage imageNamed:image] forState:state];
    }];
}

/// SegmentedContentView的代理中需要调用的方法
/// @param startIndex 切换开始时的索引值
/// @param endIndex 切换结束时的索引值
/// @param progress 分段内容切换进度
- (void)s_setSegmentedTitleViewIndexFrom:(NSInteger)startIndex to:(NSInteger)endIndex progress:(CGFloat)progress {
    NSLog(@"");
    
    // 取出 startButton 和 endButton
    UIButton *startButton = _buttonArray[startIndex];
    UIButton *endButton = _buttonArray[endIndex];
    
    _currentIndex = endButton.tag;
    _s_selectedIndex = endButton.tag;
    
    //  标题居中处理
    if (_totalWidth > CGRectGetWidth(self.frame)) {
        
        if (!_clicked) {
            
            [self centerButton:endButton];
        }
        
        _clicked = NO;
    }
    
    // 指示器逻辑处理
    if (_s_configure.s_isShowIndicator) {
        
        if (_totalWidth <= CGRectGetWidth(self.bounds)) {
            // 固定样式
            
            if (_s_configure.s_isEquivalent) {
                // 分段标题均分
                
                if (_s_configure.s_indicatorScrollStyle == SeedSegmentedIndicatorScrollStyleDefault) {
                    
                    // 默认样式, 随内容滚动指示器位置发生改变
                    [self fixedTitleViewWithFollowedIndicatorFrom:startButton to:endButton progress:progress];
                } else {
                    
                    // 其他样式, 延后滚动指示器
                    [self fixedTitleViewWithPostponedIndicatorFrom:startButton to:endButton progress:progress];
                }
            } else {
                // 分段标题顺序排列
                
                if (_s_configure.s_indicatorScrollStyle == SeedSegmentedIndicatorScrollStyleDefault) {
                    
                    // 默认样式, 随内容滚动指示器位置发生改变
                    [self mutativeTitleViewWithFollowedIndicatorFrom:startButton to:endButton progress:progress];
                } else {
                    
                    // 其他样式, 延后滚动指示器
                    [self mutativeTitleViewWithPostponedIndicatorFrom:startButton to:endButton progress:progress];
                }
            }
        } else {
            // 可滚动样式
            
            if (_s_configure.s_indicatorScrollStyle == SeedSegmentedIndicatorScrollStyleDefault) {
                
                // 默认样式, 随内容滚动指示器位置发生改变
                [self mutativeTitleViewWithFollowedIndicatorFrom:startButton to:endButton progress:progress];
            } else {
                
                // 其他样式, 延后滚动指示器
                [self mutativeTitleViewWithPostponedIndicatorFrom:startButton to:endButton progress:progress];
            }
        }
    } else {
        
        // 不显示指示器时改变按钮的状态
        [self switchButtonState:endButton];
    }
    
    // 标题文字缩放效果
    UIFont *selectedFont = _s_configure.s_titleSelectedFont;
    UIFont *defaultFont = [UIFont systemFontOfSize:15.0f];
    
    if ([selectedFont isEqual:defaultFont]) {
        
        if (_s_configure.s_canScaleTitle) {
            
            // startButton缩放
            CGFloat startFactor = 1 + (1 - progress) * _s_configure.s_titleScaleFactor;
            startButton.transform =CGAffineTransformMakeScale(startFactor, startFactor);
            
            // endButton缩放
            CGFloat endFactor = 1 + progress * _s_configure.s_titleScaleFactor;
            endButton.transform = CGAffineTransformMakeScale(endFactor, endFactor);
        }
    }
}

/// 固定样式跟随滚动指示器
/// @param startButton 切换开始时的标题按钮
/// @param endButton 切换结束时的标题按钮
/// @param progress 分段内容切换进度
- (void)fixedTitleViewWithFollowedIndicatorFrom:(UIButton *)startButton to:(UIButton *)endButton progress:(CGFloat)progress {
    NSLog(@"");
    
    // 改变按钮状态
    if (progress >= 0.8f) {
        
        // 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
        [self switchButtonState:endButton];
    }
    
    // 按钮宽度
    CGFloat buttonWidth = CGRectGetWidth(self.frame) / _s_titleArray.count;
    // 结束按钮最大X值
    CGFloat endButtonMaxX = (endButton.tag + 1) * buttonWidth;
    // 开始按钮最大X值
    CGFloat startButtonMaxX = (startButton.tag + 1) * buttonWidth;
    
    // 处理指示器
    switch (_s_configure.s_indicatorStyle) {
            
        case SeedSegmentedIndicatorStyleDefault:
        case SeedSegmentedIndicatorStyleCover: {
            // 下划线样式、遮盖样式
            
            // 文字宽度
            CGFloat endTextWidth = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont].width;
            CGFloat startTextWidth = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont].width;
            
            if (!_s_configure.s_canScaleTitle) {
                
                endButtonMaxX = CGRectGetMaxX(endButton.frame);
                startButtonMaxX = CGRectGetMaxX(startButton.frame);
            }
            
            CGFloat endIndicatorX = endButtonMaxX - endTextWidth - 0.5f * (buttonWidth - endTextWidth + _s_configure.s_indicatorSpacing);
            CGFloat startIndicatorX = startButtonMaxX - startTextWidth - 0.5f * (buttonWidth - startTextWidth + _s_configure.s_indicatorSpacing);
            
            // 总偏移量
            CGFloat totalOffset = endIndicatorX - startIndicatorX;
            
            // 计算文字之间差值
            // endButton 文字右边的X值
            CGFloat endButtonTextRightX = endButtonMaxX - 0.5f * (buttonWidth - endTextWidth);
            // startButton 文字右边的X值
            CGFloat startButtonTextRightX = startButtonMaxX - 0.5f * (buttonWidth - startTextWidth);
            CGFloat textDistance = endButtonTextRightX - startButtonTextRightX;
            
            // 计算滚动时的偏移量
            CGFloat offset = totalOffset * progress;
            // 计算滚动时文字宽度的差值
            CGFloat diff = progress * (textDistance - totalOffset);
            
            // 计算指示器新的frame
            [self revise:_indicator x:(startIndicatorX + offset)];
            
            CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + startTextWidth + diff;
            
            if (indicatorWidth >= CGRectGetWidth(endButton.frame)) {
                
                CGFloat x = progress * (endButton.frame.origin.x - startButton.frame.origin.x);
                CGFloat centerX = startButton.center.x + x;
                [self revise:_indicator centerX:centerX];
            } else {
                
                [self revise:_indicator width:indicatorWidth];
            }
        }
            break;
        case SeedSegmentedIndicatorStyleFixed: {
            // 固定样式
            
            CGFloat endIndicatorX = endButtonMaxX - 0.5f * (buttonWidth - _s_configure.s_indicatorFixedWidth) - _s_configure.s_indicatorFixedWidth;
            CGFloat startIndicatorX = startButtonMaxX - 0.5f * (buttonWidth - _s_configure.s_indicatorFixedWidth) - _s_configure.s_indicatorFixedWidth;
            CGFloat offset = endIndicatorX - startIndicatorX;
            CGFloat x = startIndicatorX + progress * offset;
            [self revise:_indicator x:x];
        }
            break;
            
        case SeedSegmentedIndicatorStyleDynamic: {
            // 动态样式
            
            if (startButton.tag <= endButton.tag) {
                
                // 往左滑
                if (progress <= 0.5f) {
                    
                    CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * progress * buttonWidth;
                    
                    [self revise:_indicator width:width];
                } else {
                    
                    CGFloat endIndicatorX = endButtonMaxX - 0.5f * (buttonWidth - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                    CGFloat x = endIndicatorX + 2 * (progress - 1) * buttonWidth;
                    CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * (1 - progress) * buttonWidth;
                    
                    [self revise:_indicator x:x];
                    [self revise:_indicator width:width];
                }
            } else {
                
                // 往右滑
                if (progress <= 0.5f) {
                    
                    CGFloat startIndicatorX = startButtonMaxX - 0.5f * (buttonWidth - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                    CGFloat x = startIndicatorX - 2 * progress * buttonWidth;
                    CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * progress * buttonWidth;
                    
                    [self revise:_indicator x:x];
                    [self revise:_indicator width:width];
                } else {
                    
                    CGFloat x = endButtonMaxX - 0.5f * (buttonWidth - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                    CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * (1 - progress) * buttonWidth;
                    
                    [self revise:_indicator x:x];
                    [self revise:_indicator width:width];
                }
            }
        }
            break;
    }
}

/// 固定样式延后滚动指示器
/// @param startButton 切换开始时的标题按钮
/// @param endButton 切换结束时的标题按钮
/// @param progress 分段内容切换进度
- (void)fixedTitleViewWithPostponedIndicatorFrom:(UIButton *)startButton to:(UIButton *)endButton progress:(CGFloat)progress {
    NSLog(@"");
    
    // 内容滚动一半指示器位置发生改变
    if (_s_configure.s_indicatorScrollStyle == SeedSegmentedIndicatorScrollStyleHalf) {
        
        // 指示器固定样式
        if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleFixed) {
            
            if (progress >= 0.5f) {
                
                [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                    
                    CGFloat centerX = endButton.center.x;
                    [self revise:self.indicator centerX:centerX];
                    
                    [self switchButtonState:endButton];
                }];
            } else {
                
                [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                    
                    CGFloat centerX = startButton.center.x;
                    [self revise:self.indicator centerX:centerX];
                    
                    [self switchButtonState:startButton];
                }];
            }
            
            return;
        }
        
        // 指示器下划线样式、遮盖样式
        if (progress >= 0.5f) {
            
            CGSize size = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont];
            CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                CGFloat width = CGRectGetWidth(endButton.frame);
                
                if (indicatorWidth < width) {
                    
                    width = indicatorWidth;
                }
                
                [self revise:self.indicator width:width];
                [self revise:self.indicator centerX:endButton.center.x];
                
                [self switchButtonState:endButton];
            }];
        } else {
            
            CGSize size = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont];
            CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                CGFloat width = CGRectGetWidth(startButton.frame);
                
                if (indicatorWidth < width) {
                    
                    width = indicatorWidth;
                }
                
                [self revise:self.indicator width:width];
                [self revise:self.indicator centerX:startButton.center.x];
                
                [self switchButtonState:startButton];
            }];
        }
        
        return;
    }
    
    // 内容滚动结束指示器位置发生改变
    // 指示器固定样式
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleFixed) {
        
        if (progress == 1.0f) {
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                [self revise:self.indicator centerX:endButton.center.x];
                
                [self switchButtonState:endButton];
            }];
        } else {
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                [self revise:self.indicator centerX:startButton.center.x];
                
                [self switchButtonState:startButton];
            }];
        }
        
        return;
    }
    
    // 指示器下划线样式、遮盖样式
    if (progress == 1.0f) {
        
        CGSize size = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont];
        CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
        
        [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
            
            CGFloat width = CGRectGetWidth(endButton.frame);
            
            if (indicatorWidth < width) {
                
                width = indicatorWidth;
            }
            
            [self revise:self.indicator width:width];
            [self revise:self.indicator centerX:endButton.center.x];
            
            [self switchButtonState:endButton];
        }];
    } else {
        
        CGSize size = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont];
        CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
        
        [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
            
            CGFloat width = CGRectGetWidth(startButton.frame);
            
            if (indicatorWidth < width) {
                
                width = indicatorWidth;
            }
            
            [self revise:self.indicator width:width];
            [self revise:self.indicator centerX:startButton.center.x];
            
            [self switchButtonState:startButton];
        }];
    }
}

/// 动态样式跟随滚动指示器
/// @param startButton 切换开始时的标题按钮
/// @param endButton 切换结束时的标题按钮
/// @param progress 分段内容切换进度
- (void)mutativeTitleViewWithFollowedIndicatorFrom:(UIButton *)startButton to:(UIButton *)endButton progress:(CGFloat)progress {
    NSLog(@"");
    
    // 改变按钮状态
    if (progress >= 0.8f) {
        
        // 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
        [self switchButtonState:endButton];
    }
    
    // SeedSegmentedIndicatorStyleFixed样式
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleFixed) {
        
        CGFloat endIndicatorX = CGRectGetMaxX(endButton.frame) - 0.5f * (CGRectGetWidth(endButton.frame) - _s_configure.s_indicatorFixedWidth) - _s_configure.s_indicatorFixedWidth;
        CGFloat startIndicatorX = CGRectGetMaxX(startButton.frame) - _s_configure.s_indicatorFixedWidth - 0.5f * (CGRectGetWidth(startButton.frame) - _s_configure.s_indicatorFixedWidth);
        
        CGFloat offset = progress * (endIndicatorX - startIndicatorX);
        [self revise:self.indicator x:(startIndicatorX + offset)];
        
        return;
    }
    
    // SeedSegmentedIndicatorStyleDynamic样式
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleDynamic) {
        
        if (startButton.tag <= endButton.tag) {
            // 往左滑
            
            // targetButton 和 originalButton 中心点的距离
            CGFloat distanceOnCenter = CGRectGetMidX(endButton.frame) - CGRectGetMidX(startButton.frame);
            
            if (progress <= 0.5f) {
                
                CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * progress * distanceOnCenter;
                
                [self revise:self.indicator width:width];
            } else {
                
                CGFloat endIndicatorX = CGRectGetMaxX(endButton.frame) - 0.5f * (CGRectGetWidth(endButton.frame) - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                CGFloat x = endIndicatorX + 2 * (progress - 1) * distanceOnCenter;
                CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * (1 - progress) * distanceOnCenter;
                
                [self revise:self.indicator x:x];
                [self revise:self.indicator width:width];
            }
        } else {
            // 往右滑
            
            // originalButton 和 targetButton 中心点的距离
            CGFloat distanceOnCenter = CGRectGetMidX(startButton.frame) - CGRectGetMidX(endButton.frame);
            
            if (progress <= 0.5f) {
                
                CGFloat startIndicatorX = CGRectGetMaxX(startButton.frame) - 0.5f * (CGRectGetWidth(startButton.frame) - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                CGFloat x = startIndicatorX - 2 * progress * distanceOnCenter;
                CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * progress * distanceOnCenter;
                
                [self revise:self.indicator x:x];
                [self revise:self.indicator width:width];
            } else {
                
                CGFloat endIndicatorX = CGRectGetMaxX(endButton.frame) - 0.5f * (CGRectGetWidth(endButton.frame) - _s_configure.s_indicatorDynamicWidth) - _s_configure.s_indicatorDynamicWidth;
                CGFloat width = _s_configure.s_indicatorDynamicWidth + 2 * (1 - progress) * distanceOnCenter;
                
                // 必须写, 防止滚动结束之后指示器位置由于 progress >= 0.8 导致的偏差
                [self revise:self.indicator x:endIndicatorX];
                [self revise:self.indicator width:width];
            }
        }
        return;
    }
    
    // 下划线样式、遮盖样式
    if (_s_configure.s_canScaleTitle && _s_configure.s_isShowIndicator) {
        
        CGFloat startTextWidth = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont].width;
        CGFloat endTextWidth = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont].width;
        
        // 文字宽度差
        CGFloat textDiff = endTextWidth - startTextWidth;
        // 中心点距离差
        CGFloat diffOnCenter = CGRectGetMidX(endButton.frame) - CGRectGetMidX(startButton.frame);
        // 偏移量
        CGFloat offset = diffOnCenter * progress;
        
        CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + endTextWidth + _s_configure.s_titleScaleFactor * endTextWidth;
        
        CGFloat centerX = CGRectGetMidX(startButton.frame) + offset;
        [self revise:self.indicator centerX:centerX];
        
        CGFloat width = (startTextWidth + textDiff * progress) + _s_configure.s_titleScaleFactor * (startTextWidth + textDiff * progress) + _s_configure.s_indicatorSpacing;
        if (indicatorWidth >= CGRectGetWidth(endButton.frame)) {
            
            width = CGRectGetWidth(endButton.frame) - _s_configure.s_titleScaleFactor * (startTextWidth + textDiff * progress);
        }
        [self revise:self.indicator width:width];
        
        return;
    }
    
    // targetButton 和 originalButton 的MinX差值
    CGFloat offsetMinX = CGRectGetMinX(endButton.frame) - CGRectGetMinX(startButton.frame);
    // targetButton 和 originalButton 的MaxX差值
    CGFloat offsetMaxX = CGRectGetMaxX(endButton.frame) - CGRectGetMaxX(startButton.frame);
    // indicator的X偏移量
    CGFloat indicatorOffsetX = 0.0f;
    // indicator的宽度的差值
    CGFloat diff = 0.0f;
    
    CGFloat endTextWidth = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont].width;
    CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + endTextWidth;
    
    if (indicatorWidth >= CGRectGetWidth(endButton.frame)) {
        
        indicatorOffsetX = offsetMinX * progress;
        diff = progress * (offsetMaxX - offsetMinX);
        
        CGFloat x = CGRectGetMinX(startButton.frame) + indicatorOffsetX;
        CGFloat width = CGRectGetWidth(startButton.frame) + diff;
        
        [self revise:self.indicator x:x];
        [self revise:self.indicator width:width];
    } else {
        
        indicatorOffsetX = offsetMinX * progress + 0.5f * _s_configure.s_titlePadding - 0.5f * _s_configure.s_indicatorSpacing;
        diff = progress * (offsetMaxX - offsetMinX) - _s_configure.s_titlePadding;
        
        CGFloat x = CGRectGetMinX(startButton.frame) + indicatorOffsetX;
        CGFloat width = CGRectGetWidth(startButton.frame) + diff + _s_configure.s_indicatorSpacing;
        
        [self revise:self.indicator x:x];
        [self revise:self.indicator width:width];
    }
}


/// 动态样式延后滚动指示器
/// @param startButton 切换开始时的标题按钮
/// @param endButton 切换结束时的标题按钮
/// @param progress 分段内容切换进度
- (void)mutativeTitleViewWithPostponedIndicatorFrom:(UIButton *)startButton to:(UIButton *)endButton progress:(CGFloat)progress {
    NSLog(@"");
    
    // SeedSegmentedIndicatorScrollStyleHalf样式
    if (_s_configure.s_indicatorScrollStyle == SeedSegmentedIndicatorScrollStyleHalf) {
        
        // SeedSegmentedIndicatorStyleFixed样式
        if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleFixed) {
            
            if (progress >= 0.5f) {
                
                [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                    
                    [self revise:self.indicator centerX:endButton.center.x];
                    
                    [self switchButtonState:endButton];
                }];
            } else {
                
                [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                    
                    [self revise:self.indicator centerX:startButton.center.x];
                    
                    [self switchButtonState:startButton];
                }];
            }
            
            return;
        }
        
        // 指示器下划线样式、遮盖样式
        if (progress >= 0.5f) {
            
            CGSize size = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont];
            CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                CGFloat width = CGRectGetWidth(endButton.frame);
                
                if (indicatorWidth < width) {
                    
                    width = indicatorWidth;
                }
                
                [self revise:self.indicator width:width];
                [self revise:self.indicator centerX:endButton.center.x];
                
                [self switchButtonState:endButton];
            }];
        } else {
            
            CGSize size = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont];
            CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                CGFloat width = CGRectGetWidth(startButton.frame);
                
                if (indicatorWidth < width) {
                    
                    width = indicatorWidth;
                }
                
                [self revise:self.indicator width:width];
                [self revise:self.indicator centerX:startButton.center.x];
                
                [self switchButtonState:startButton];
            }];
        }
        
        return;
    }
    
    // SeedSegmentedIndicatorScrollStyleEnd样式
    // SeedSegmentedIndicatorStyleFixed样式
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleFixed) {
        
        if (progress == 1.0f) {
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                [self revise:self.indicator centerX:endButton.center.x];
                
                [self switchButtonState:endButton];
            }];
        } else {
            
            [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
                
                [self revise:self.indicator centerX:startButton.center.x];
                
                [self switchButtonState:startButton];
            }];
        }
        
        return;
    }
    
    // 指示器下划线样式、遮盖样式
    if (progress == 1.0f) {
        
        CGSize size = [self sizeWithString:endButton.currentTitle font:_s_configure.s_titleDefaultFont];
        CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
        
        [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
            
            CGFloat width = CGRectGetWidth(endButton.frame);
            
            if (indicatorWidth < width) {
                
                width = indicatorWidth;
            }
            
            [self revise:self.indicator width:width];
            [self revise:self.indicator centerX:endButton.center.x];
            
            [self switchButtonState:endButton];
        }];
    } else {
        
        CGSize size = [self sizeWithString:startButton.currentTitle font:_s_configure.s_titleDefaultFont];
        CGFloat indicatorWidth = _s_configure.s_indicatorSpacing + size.width;
        
        [UIView animateWithDuration:_s_configure.s_indicatorAnimationTime animations:^{
            
            CGFloat width = CGRectGetWidth(startButton.frame);
            
            if (indicatorWidth < width) {
                
                width = indicatorWidth;
            }
            
            [self revise:self.indicator width:width];
            [self revise:self.indicator centerX:startButton.center.x];
            
            [self switchButtonState:startButton];
        }];
    }
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"");
    
    if (self = [super initWithFrame:frame]) {
        
        // 设置带透明度的背景色而不影响子视图的透明度
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
        
        // 标题视图属性配置
        _s_configure = [SeedSegmentedTitleViewConfigure s_defaultConfigure];
        
        // 添加分段标签标题滚动视图
        [self addSubview:self.scrollView];
        
        // 添加标题按钮
        [self prepareTitleButtons];
        
        // 添加分隔线
        if (_s_configure.s_isShowSeparator) {
            
            [self addSubview:self.separator];
            [self bringSubviewToFront:self.separator];
        }
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"");
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    // 分段标签滚动视图的frame
    _scrollView.frame = self.bounds;
    
    // 分割线的frame
    if (_s_configure.s_isShowSeparator) {
        
        CGFloat separatorHeight = 1.0f;
        CGFloat separatorX = 0.0f;
        CGFloat separatorY = height - separatorHeight;
        _separator.frame = CGRectMake(separatorX, separatorY, width, separatorHeight);
        _separator.backgroundColor = _s_configure.s_separatorColor;
    }
    
    if (_totalWidth < width) {
        // 标题按钮总宽度小于分段标签宽度, 静止样式
        
        if (_s_configure.s_isEquivalent) {
            // 标题按钮长度均分
            // 等宽布局
            [self fixedWidthLayout];
        } else {
            
            // 从左到右自动顺序布局
            [self autoFlowLayout];
        }
    } else {
        
        // 标题按钮总宽度大于分段标签宽度, 滚动样式
        // 从左到右自动顺序布局
        [self autoFlowLayout];
    }
    
    // 分段标题视图的弹性效果
    _scrollView.bounces = _s_configure.s_bounces;
    
    // 指示器的frame
    if (_s_configure.s_isShowIndicator) {
        
        CGFloat indicatorY = 0.0f;
        CGFloat indicatorHeight = 0.0f;
        
        if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleCover) {
            
            // 指示器样式是覆盖样式
            CGSize size = [self sizeWithString:[[self.buttonArray firstObject] currentTitle] font:_s_configure.s_titleDefaultFont];
            
            if (_s_configure.s_indicatorHeight > height) {
                
                // 指示器高度设置过大
                indicatorY = 0.0f;
                indicatorHeight = height;
            } else if (_s_configure.s_indicatorHeight < size.height) {
                
                // 指示器高度设置过小, 内容无法显示完整
                indicatorY = 0.5f * (height - size.height);
                indicatorHeight = size.height;
            } else {
                
                indicatorY = 0.5f * (height - _s_configure.s_indicatorHeight);
                indicatorHeight = _s_configure.s_indicatorHeight;
            }
        } else {
            
            indicatorY = height - _s_configure.s_indicatorHeight - _s_configure.s_indicatorMargin;
            indicatorHeight = _s_configure.s_indicatorHeight;
        }
        
        [self revise:_indicator y:indicatorY];
        [self revise:_indicator height:indicatorHeight];
        
        // 圆角处理
        CGFloat max = 0.5f * CGRectGetHeight(_indicator.frame);
        _indicator.layer.cornerRadius = (_s_configure.s_indicatorCornerRadius > max) ? max : _s_configure.s_indicatorCornerRadius;
    }
    
    if (self.buttonArray.count > 0) {
        
        // 选中按钮
        [self didClickTitleButton: self.buttonArray[_s_selectedIndex]];
    }
}

/// 等宽布局
- (void)fixedWidthLayout {
    NSLog(@"");
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    // 标题按钮个数
    NSInteger count = _s_titleArray.count;
    
    // 标题按钮X值
    CGFloat buttonX = 0.0f;
    // 标题按钮Y值
    CGFloat buttonY = 0.0f;
    // 标题按钮宽度
    CGFloat buttonWidth = (count > 0) ? (width / count) : 0.0f;
    // 标题按钮高度
    CGFloat buttonHeight = height;
    
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleDefault) {
        
        buttonHeight = height - _s_configure.s_indicatorHeight;
    }
    
    [_buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 标题按钮frame
        obj.frame = CGRectMake(buttonX + buttonWidth * idx, buttonY, buttonWidth, buttonHeight);
    }];
    
    _scrollView.contentSize = CGSizeMake(width, height);
    
    if (_s_configure.s_isShowSplitter) {
        
        // 分隔符
        CGFloat splitterWidth = _s_configure.s_splitterWidth;
        CGFloat splitterHeight = _s_configure.s_splitterHeight;
        CGFloat splitterY = 0.5f * (height - splitterHeight);
        
        [_splitterArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.frame = CGRectMake((idx + 1) * buttonWidth - 0.5f * splitterWidth, splitterY, splitterWidth, splitterHeight);
        }];
    }
}

/// 顺序布局
- (void)autoFlowLayout {
    NSLog(@"");
    
    CGFloat height = CGRectGetHeight(self.frame);
    
    // 标题按钮X值
    __block CGFloat buttonX = 0.0f;
    // 标题按钮Y值
    CGFloat buttonY = 0.0f;
    // 标题按钮高度
    CGFloat buttonHeight = height;
    
    if (_s_configure.s_indicatorStyle == SeedSegmentedIndicatorStyleDefault) {
        
        buttonHeight = height - _s_configure.s_indicatorHeight;
    }
    
    [_buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize size = [self sizeWithString:_s_titleArray[idx] font:_s_configure.s_titleDefaultFont];
        CGFloat buttonWidth = size.width + _s_configure.s_titlePadding;
        obj.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        buttonX += buttonWidth;
    }];
    
    UIButton *lastButton = _buttonArray.lastObject;
    _scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastButton.frame), height);
    
    if (_s_configure.s_isShowSplitter) {
        
        // 分隔符
        CGFloat splitterWidth = _s_configure.s_splitterWidth;
        CGFloat splitterHeight = _s_configure.s_splitterHeight;
        CGFloat splitterY = 0.5f * (height - splitterHeight);
        
        [_splitterArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton *button = _buttonArray[idx];
            CGFloat splitterX = CGRectGetMaxX(button.frame) - 0.5f * splitterWidth;
            obj.frame = CGRectMake(splitterX, splitterY, splitterWidth, splitterHeight);
        }];
    }
}

#pragma mark - target method

/// 点击标题按钮
/// @param sender 标题按钮
- (IBAction)didClickTitleButton:(UIButton *)sender {
    NSLog(@"");
    
    // 改变按钮状态
    [self switchButtonState:sender];
    
    // 滚动样式下选中标题居中处理
    if (self.totalWidth > CGRectGetWidth(_scrollView.frame)) {
        
        _clicked = YES;
        [self centerButton:sender];
    }
    
    // 移动指示器位置
    if (_s_configure.s_showIndicator) {
        
        [self moveIndicatorWithButton:sender];
    }
    
    // 代理
    if ([self.s_delegate respondsToSelector:@selector(s_segmentedTitleView:didSelectIndex:)]) {
        
        [self.s_delegate s_segmentedTitleView:self didSelectIndex:sender.tag];
    }
    
    // 标记下标
    _currentIndex = sender.tag;
    _s_selectedIndex = sender.tag;
}

/// 改变按钮的状态
/// @param button 按钮
- (void)switchButtonState:(UIButton *)button {
    NSLog(@"");
    
    if (!self.clickedButton) {
        
        // 第一次点击
        button.selected = YES;
        self.clickedButton = button;
    } else if ([self.clickedButton isEqual:button]) {
        
        // 第二次点击同一个button
        button.selected = YES;
    } else if (![self.clickedButton isEqual:button]) {
        
        // 第二次点击不同button
        self.clickedButton.selected = NO;
        button.selected = YES;
        self.clickedButton = button;
    }
    
    UIFont *selectedFont = _s_configure.s_titleSelectedFont;
    UIFont *defaultFont = [UIFont systemFontOfSize:15.0f];
    
    if ([selectedFont.fontName isEqualToString:defaultFont.fontName] && (selectedFont.pointSize == defaultFont.pointSize)) {
        
        if (_s_configure.s_canScaleTitle) {
            
            [_buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                obj.transform = CGAffineTransformIdentity;
            }];
            
            // 缩放前的宽度
            CGFloat widthBefore = CGRectGetWidth(button.frame);
            
            // 处理按钮缩放
            CGFloat factor = 1 + _s_configure.s_titleScaleFactor;
            button.transform = CGAffineTransformMakeScale(factor, factor);
            
            // 缩放后的宽度
            CGFloat widthAfter = CGRectGetWidth(button.frame);
            CGFloat diff = widthAfter - widthBefore;
            
            // 处理指示器
            if (_s_configure.s_indicatorSpacing >= diff) {
                
                _s_configure.s_indicatorSpacing = diff;
            }
            
            CGSize size = [self sizeWithString:button.currentTitle font:_s_configure.s_titleDefaultFont];
            CGFloat width = _s_configure.s_indicatorSpacing + factor * size.width;
            
            if (width > CGRectGetWidth(button.frame)) {
                
                width = CGRectGetWidth(button.frame) - _s_configure.s_titleScaleFactor * size.width;
            }
            
            [self revise:_indicator width:width];
            [self revise:_indicator centerX:button.center.x];
        }
    } else {
        
        [_buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.titleLabel.font = _s_configure.s_titleDefaultFont;
        }];
        
        button.titleLabel.font = _s_configure.s_titleSelectedFont;
    }
}

/// 把按钮居中
/// @param button 标题按钮
- (void)centerButton:(UIButton *)button {
    NSLog(@"");
    
    // 计算偏移量
    CGFloat offsetX = CGRectGetMidX(button.frame) - CGRectGetMidX(self.frame);
    CGFloat maxOffsetX = _scrollView.contentSize.width - CGRectGetWidth(self.frame);
    offsetX = (offsetX > maxOffsetX) ? maxOffsetX : ((offsetX < 0.0f) ? 0.0f : offsetX);
    
    // 设置偏移量
    [_scrollView setContentOffset:CGPointMake(offsetX, 0.0f) animated:YES];
}

/// 移动指示器位置
/// @param button 按钮
- (void)moveIndicatorWithButton:(UIButton *)button {
    NSLog(@"");
    
    [UIView animateWithDuration:self.s_configure.s_indicatorAnimationTime animations:^{
        
        switch (self.s_configure.s_indicatorStyle) {
                
            case SeedSegmentedIndicatorStyleDefault:
            case SeedSegmentedIndicatorStyleCover: {
                
                if (!self.s_configure.s_canScaleTitle) {
                    
                    CGSize size = [self sizeWithString:button.currentTitle font:self.s_configure.s_titleDefaultFont];
                    CGFloat width = self.s_configure.s_indicatorSpacing + size.width;
                    if (width > CGRectGetWidth(button.frame)) {
                        
                        width = CGRectGetWidth(button.frame);
                    }
                    
                    [self revise:self.indicator width:width];
                    [self revise:self.indicator centerX:button.center.x];
                }
            }
                break;
            case SeedSegmentedIndicatorStyleFixed: {
                
                [self revise:self.indicator width:self.s_configure.s_indicatorFixedWidth];
                [self revise:self.indicator centerX:button.center.x];
            }
                break;
            case SeedSegmentedIndicatorStyleDynamic: {
                
                [self revise:self.indicator width:self.s_configure.s_indicatorDynamicWidth];
                [self revise:self.indicator centerX:button.center.x];
            }
                break;
        }
    }];
}

#pragma mark - private method

/// 准备标题按钮
- (void)prepareTitleButtons {
    NSLog(@"");
    
    // 移除所有子视图
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 移除子视图, 懒加载置空
    self.indicator = nil;
    
    // 移除按钮
    [self.buttonArray removeAllObjects];
    // 移除分隔符
    [self.splitterArray removeAllObjects];
    
    // 添加指示器
    [self.scrollView insertSubview:self.indicator atIndex:0];
    
    // 标题按钮总宽度
    __block CGFloat totalWidth;
    
    // 标题个数
    NSInteger count = _s_titleArray.count;
    
    [_s_titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize size = [self sizeWithString:obj font:_s_configure.s_titleDefaultFont];
        totalWidth += size.width;
    }];
    
    // 加上标题间距
    totalWidth += _s_configure.s_titlePadding * count;
    totalWidth = ceil(totalWidth);
    _totalWidth = totalWidth;
    
    // 创建标题按钮
    [_s_titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        button.titleLabel.font = _s_configure.s_titleDefaultFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // 标题
        [button setTitle:_s_titleArray[idx] forState:UIControlStateNormal];
        [button setTitle:_s_titleArray[idx] forState:UIControlStateSelected];
        // 颜色
        [button setTitleColor:_s_configure.s_titleDefaultColor forState:UIControlStateNormal];
        [button setTitleColor:_s_configure.s_titleSelectedColor forState:UIControlStateSelected];
        
        // 点击事件
        [button addTarget:self action:@selector(didClickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.buttonArray addObject:button];
        [self.scrollView addSubview:button];
    }];
    
    if (_s_configure.s_isShowSplitter) {
        
        for (NSInteger i = 0; i < count - 1; i++) {
            
            UIView *splitter = [[UIView alloc] init];
            splitter.backgroundColor = _s_configure.s_splitterColor;
            [self.splitterArray addObject:splitter];
            [self.scrollView addSubview:splitter];
        }
    }
}

/// 根据字体计算字符串尺寸
/// @param string 字符串
/// @param font 字体
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font {
    
    NSDictionary *attribute = @{NSFontAttributeName:font};
    return [string boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
}

- (void)revise:(UIView *)view x:(CGFloat)value {
    NSLog(@"");
    
    CGRect frame = view.frame;
    frame.origin.x = value;
    view.frame = frame;
}

- (void)revise:(UIView *)view y:(CGFloat)value {
    NSLog(@"");
    
    CGRect frame = view.frame;
    frame.origin.y = value;
    view.frame = frame;
}

- (void)revise:(UIView *)view width:(CGFloat)value {
    NSLog(@"");
    
    CGRect frame = view.frame;
    frame.size.width = value;
    view.frame = frame;
}

- (void)revise:(UIView *)view height:(CGFloat)value {
    NSLog(@"");
    
    CGRect frame = view.frame;
    frame.size.height = value;
    view.frame = frame;
}

- (void)revise:(UIView *)view centerX:(CGFloat)value {
    NSLog(@"");
    
    CGPoint center = view.center;
    center.x = value;
    view.center = center;
}

- (void)revise:(UIView *)view centerY:(CGFloat)value {
    NSLog(@"");
    
    CGPoint center = view.center;
    center.y = value;
    view.center = center;
}

#pragma mark - setter

- (void)setS_titleArray:(NSArray<NSString *> *)s_titleArray {
    NSLog(@"");
    
    _s_titleArray = s_titleArray;
    
    [self prepareTitleButtons];
    
    // 立即刷新布局
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setS_configure:(SeedSegmentedTitleViewConfigure *)s_configure {
    NSLog(@"");
    
    _s_configure = s_configure;
    
    [self prepareTitleButtons];
    
    // 立即刷新布局
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setS_selectedIndex:(NSInteger)s_selectedIndex {
    NSLog(@"");
    
    _s_selectedIndex = s_selectedIndex;
    [self didClickTitleButton:self.buttonArray[s_selectedIndex]];
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] init];
        
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    return _scrollView;
}

- (UIView *)indicator {
    
    if (!_indicator) {
        
        _indicator = [[UIView alloc] init];
        _indicator.layer.borderColor = _s_configure.s_indicatorBorderColor.CGColor;
        _indicator.layer.borderWidth = _s_configure.s_indicatorBorderWidth;
        _indicator.backgroundColor = _s_configure.s_indicatorColor;
        _indicator.layer.masksToBounds = YES;
    }
    
    return _indicator;
}

- (UIView *)separator {
    
    if (!_separator) {
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = _s_configure.s_separatorColor;
    }
    
    return _separator;
}

- (NSMutableArray<UIButton *> *)buttonArray {
    
    if (!_buttonArray) {
        
        _buttonArray = [NSMutableArray array];
    }
    
    return _buttonArray;
}

- (NSMutableArray<UIView *> *)splitterArray {
    
    if (!_splitterArray) {
        
        _splitterArray = [NSMutableArray array];
    }
    
    return _splitterArray;
}

@end
