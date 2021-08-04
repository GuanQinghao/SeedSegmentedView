//
//  SeedSegmentedTitleView.h
//  SeedSegmentedControl
//
//  Created by Hao on 2021/2/24.
//

#import <UIKit/UIKit.h>
#import "UIButton+SeedSegmentedControl.h"
#import "SeedSegmentedTitleViewConfigure.h"
@class SeedSegmentedTitleView;


NS_ASSUME_NONNULL_BEGIN

/// 分段控件标题视图代理
@protocol SeedSegmentedTitleViewDelegate <NSObject>

/// 分段控件选中标题按钮
/// @param segmentedTitleView 分段控件标题按钮视图
/// @param index 选中的下标
- (void)s_segmentedTitleView:(SeedSegmentedTitleView *)segmentedTitleView didSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface SeedSegmentedTitleView : UIView

/// 分段控件标题视图代理
@property (nonatomic, weak) id<SeedSegmentedTitleViewDelegate> s_delegate;

/// 分段控件标题视图配置
@property (nonatomic, strong) SeedSegmentedTitleViewConfigure *s_configure;

/// 分段控件标题
@property (nonatomic, strong) NSArray<NSString *> *s_titleArray;

/// 选中的索引值, 默认 0
@property (nonatomic, assign) NSInteger s_selectedIndex;


/// 设置SeedSegmentedTitleView的图片
/// @param images 默认的图片名称数组
/// @param selectedImages 选中的图片名称数组
/// @param style 图文显示样式
/// @param spacing 图片和文字的间距
- (void)s_setSegmentedTitleViewImages:(NSArray<NSString *> *)images selectedImages:(NSArray<NSString *> *)selectedImages withStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing;

/// 根据下标设置SeedSegmentedTitleView的图片
/// @param image 默认的图片名称
/// @param selectedImage 选中的图片名称
/// @param index 下标值
/// @param style 图文显示样式
/// @param spacing 图片和文字的间距
- (void)s_setSegmentedTitleViewImage:(NSString *)image selectedImage:(NSString *)selectedImage forIndex:(NSInteger)index withStyle:(SeedSegmentedTitleGraphicStyle)style spacing:(CGFloat)spacing;

/// SegmentedContentView的代理中需要调用的方法
/// @param startIndex 切换开始时的索引值
/// @param endIndex 切换结束时的索引值
/// @param progress 分段内容切换进度
- (void)s_setSegmentedTitleViewIndexFrom:(NSInteger)startIndex to:(NSInteger)endIndex progress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
