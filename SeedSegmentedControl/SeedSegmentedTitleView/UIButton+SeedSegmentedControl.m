//
//  UIButton+SeedSegmentedControl.m
//  SeedSegmentedControl
//
//  Created by Hao on 2020/12/4.
//

#import "UIButton+SeedSegmentedControl.h"


@implementation UIButton (SeedSegmentedControl)

/// 设置标题按钮的图文样式
/// @param style 图文样式
/// @param spacing 图文间距
/// @param operation 图文设置回调(回调中设置图片和文字)
- (void)s_setTitleGraphicStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing withOperation:(void (^)(UIButton * _Nonnull))operation {
    
    if (operation) {
        
        operation(self);
    }
    
    switch (style) {
        case SeedSegmentedTitleGraphicStyleImageOnLeft: {
            
            if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
                
                self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, spacing, 0.0f, 0.0f);
            } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, spacing);
            } else {
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, -0.5f * spacing, 0.0f, 0.5f * spacing);
                self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.5 * spacing, 0.0f, -0.5 * spacing);
            }
        }
            break;
        case SeedSegmentedTitleGraphicStyleImageOnRight: {
            
            CGFloat imageWidth = self.imageView.image.size.width;
            CGFloat titleWidth = self.titleLabel.frame.size.width;
            
            if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, titleWidth + spacing, 0.0f, 0.0f);
                self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -imageWidth, 0.0f, 0.0f);
            } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -titleWidth);
                self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, imageWidth + spacing);
            } else {
                
                CGFloat imageOffset = titleWidth + 0.5f * spacing;
                CGFloat titleOffset = imageWidth + 0.5f * spacing;
                self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, imageOffset, 0.0f, -imageOffset);
                self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -titleOffset, 0.0f, titleOffset);
            }
        }
            break;
        case SeedSegmentedTitleGraphicStyleImageOnTop: {
            
            CGFloat imageWidth = self.imageView.frame.size.width;
            CGFloat imageHeight = self.imageView.frame.size.height;
            CGFloat titleIntrinsicContentSizeWidth = self.titleLabel.intrinsicContentSize.width;
            CGFloat titleIntrinsicContentSizeHeight = self.titleLabel.intrinsicContentSize.height;
            
            self.imageEdgeInsets = UIEdgeInsetsMake(-titleIntrinsicContentSizeHeight - spacing, 0.0f, 0.0f, -titleIntrinsicContentSizeWidth);
            self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -imageWidth, -imageHeight - spacing, 0.0f);
        }
            break;
        case SeedSegmentedTitleGraphicStyleImageOnBottom: {
            
            CGFloat imageWidth = self.imageView.frame.size.width;
            CGFloat imageHeight = self.imageView.frame.size.height;
            CGFloat titleIntrinsicContentSizeWidth = self.titleLabel.intrinsicContentSize.width;
            CGFloat titleIntrinsicContentSizeHeight = self.titleLabel.intrinsicContentSize.height;
            
            self.imageEdgeInsets = UIEdgeInsetsMake(titleIntrinsicContentSizeHeight + spacing, 0.0f, 0.0f, -titleIntrinsicContentSizeWidth);
            self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -imageWidth, imageHeight + spacing, 0.0f);
        }
            break;
    }
}

@end
