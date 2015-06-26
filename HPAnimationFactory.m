//
//  HPAnimationFactory.m
//  AnimationDemo
//
//  Created by hupeng on 15/6/24.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import "HPAnimationFactory.h"

@interface HPAnimationFactory ()
{
    UIDynamicAnimator *_theAnimator;
}
@end

@implementation HPAnimationFactory

+ (instancetype)factory
{
    static HPAnimationFactory *_instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _instance = [[HPAnimationFactory alloc] init];
    });
    return _instance;
}

- (void)applyGravityBehaviourToView:(UIView *)view withBlock:(void (^)(int))block
{
    __block int step = 0;
    _theAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:view];
    UIGravityBehavior *behavior = [[UIGravityBehavior alloc] initWithItems:@[view]];
    behavior.magnitude = 0.1;
    behavior.action = ^(void) {
        
        if (block) {
            block(++step);
        }
        if (step >= 100) {
            [_theAnimator removeAllBehaviors];
        }
    };
    [_theAnimator addBehavior:behavior];
}

+ (void)applyWagAnimationToView:(UIView *)view
{
    int amplitude = 3;
    __block CGRect toFrame = view.frame;
    toFrame.origin.x -= amplitude;
    
    [UIView animateWithDuration:0.025 animations:^{
        view.frame = toFrame;
    } completion:^(BOOL finished) {
        toFrame.origin.x += 2 * amplitude;
        [UIView animateWithDuration:0.075 animations:^{
            view.frame = toFrame;
        } completion:^(BOOL finished) {
            
            toFrame.origin.x -= 2 * amplitude;
            [UIView animateWithDuration:0.075 animations:^{
                view.frame = toFrame;
            } completion:^(BOOL finished) {
                
                toFrame.origin.x += 2 * amplitude;
                [UIView animateWithDuration:0.075 animations:^{
                    view.frame = toFrame;
                } completion:^(BOOL finished) {
                    toFrame.origin.x -= amplitude;
                    [UIView animateWithDuration:0.025 animations:^{
                        view.frame = toFrame;
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
                
            }];
            
        }];
    }];
}

@end
