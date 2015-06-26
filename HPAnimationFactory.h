//
//  HPAnimationFactory.h
//  AnimationDemo
//
//  Created by hupeng on 15/6/24.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPAnimationFactory : NSObject

+ (instancetype)factory;

- (void)applyGravityBehaviourToView:(UIView *)view withBlock:(void(^)(int step))block;

+ (void)applyWagAnimationToView:(UIView *)view;

@end
