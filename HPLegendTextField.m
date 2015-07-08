//
//  HPLegendTextField.m
//  AnimationDemo
//
//  Created by hupeng on 15/6/24.
//  Copyright (c) 2015年 hupeng. All rights reserved.

#define HP_LEGENDFIELD_SELECT_COLOR [UIColor colorWithRed:53.0/255.0 green:183.0/255.0 blue:127.0/255.0 alpha:1.0]
#define HP_LEGENDFIELD_NORMAL_COLOR [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0]
#define HP_LEGENDFIELD_ERROR_COLOR  [UIColor colorWithRed:242.0/255.0 green:109.0/255.0 blue:95.0/255.0 alpha:1.0]

#define HP_LEGENDFIELD_ANIMATION_DURATION .25

#import "HPLegendTextField.h"
#import "HPAnimationFactory.h"

@implementation HPLegendFieldBorder

- (void)awakeFromNib
{
    self.layer.cornerRadius = 2.0;
    self.layer.borderColor  = HP_LEGENDFIELD_NORMAL_COLOR.CGColor;
    self.layer.borderWidth  = 1.0;
}

- (void)setStatus:(HPLegendTextFieldStatus)status
{
    if (_status == status) {
        return;
    }
    _status = status;
    switch (_status) {
        case HPLegendTextFieldStatusNormal:
            self.layer.borderColor = HP_LEGENDFIELD_NORMAL_COLOR.CGColor;
            break;
        case HPLegendTextFieldStatusFocused:
            self.layer.borderColor = HP_LEGENDFIELD_SELECT_COLOR.CGColor;
            break;
        case HPLegendTextFieldStatusError:
            self.layer.borderColor = HP_LEGENDFIELD_ERROR_COLOR.CGColor;
            [HPAnimationFactory applyWagAnimationToView:self];
            break;
        default:
            break;
    }
}

@end

@interface HPLegendFieldIcon ()
{
    UIImage *_originalImage;
}
@end

@implementation HPLegendFieldIcon

- (void)awakeFromNib
{
    _originalImage = self.image;
}

- (void)setStatus:(HPLegendTextFieldStatus)status
{
    if (_status == status) {
        return;
    }
    
    _status = status;
    switch (_status) {
        case HPLegendTextFieldStatusNormal:
            self.image = _originalImage;
            break;
        case HPLegendTextFieldStatusFocused: {
            UIImage *imageForRendering = [_originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.image = imageForRendering;
            [UIView animateWithDuration:HP_LEGENDFIELD_ANIMATION_DURATION animations:^{
                self.tintColor = HP_LEGENDFIELD_SELECT_COLOR;
            }];
            break;
        }
        case HPLegendTextFieldStatusError:
            self.tintColor = HP_LEGENDFIELD_ERROR_COLOR;
            break;
        default:
            break;
    }
}

@end

@interface HPLegendTextField ()
{
    UILabel *_placeHolderLabel;
    UIView *_lineMaskView;
    
    CGRect _leftViewFrame;
    CGRect _placeHolderFrame;
    CGRect _textFieldFrame;
    CGPoint _lineMaskViewCenter;
}

@property (nonatomic, weak) IBOutlet HPLegendFieldIcon *leftView;
@property (nonatomic, weak) IBOutlet HPLegendFieldBorder *borderView;

@end

@implementation HPLegendTextField

- (void)awakeFromNib
{
    [self updateInterface];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super init]) {
        [self updateInterface];
    }
    return self;
}

- (void)setStatus:(HPLegendTextFieldStatus)status
{
    if (_status == status) {
        return;
    }
    _status = status;
    
    if (_status == HPLegendTextFieldStatusNormal) {
        _placeHolderLabel.textColor = HP_LEGENDFIELD_NORMAL_COLOR;
    } else if (_status == HPLegendTextFieldStatusFocused) {
        _placeHolderLabel.textColor = HP_LEGENDFIELD_SELECT_COLOR;
    } else if (_status == HPLegendTextFieldStatusError) {
        _placeHolderLabel.textColor = HP_LEGENDFIELD_ERROR_COLOR;
    }
    _borderView.status = _status;
    _leftView.status   = _status;
    
    _inputField.textColor = status == HPLegendTextFieldStatusError ? HP_LEGENDFIELD_ERROR_COLOR : [UIColor blackColor];
}

- (void)updateInterface
{
    _inputField.delegate = self;
    
    // 1. prepare place holder view
    
    _placeHolderLabel = [[UILabel alloc] init];
    _placeHolderLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _placeHolderLabel.font = _inputField.font;
    
    _placeHolderLabel.backgroundColor = [UIColor clearColor];
    _placeHolderLabel.textColor = HP_LEGENDFIELD_NORMAL_COLOR;
    
    [self refreshPlaceHolderLabel];
    
    [self insertSubview:_placeHolderLabel belowSubview:_inputField];
    
    // 2. prepare image view
    
    CGPoint center = _leftView.center;
    CGRect frame = _leftView.frame;
    
    UIImage *image = _leftView.image;
    frame.size = image.size;
    _leftView.frame = frame;
    _leftView.center = center;
    _leftView.contentMode = UIViewContentModeScaleToFill;
}

- (void)refreshPlaceHolderLabel {
    NSString *placeHolder = _inputField.placeholder;
    if (!placeHolder) return;
    
    _inputField.placeholder = nil;
    
    _placeHolderLabel.text = placeHolder;
    CGRect realRect = [placeHolder boundingRectWithSize:_inputField.frame.size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : _placeHolderLabel.font}
                                                context:nil];
    realRect.origin.x = _inputField.frame.origin.x;
    realRect.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(realRect)) * 0.5;
    
    _placeHolderLabel.frame = realRect;
}

- (void)startGetFocseAnimation
{
    
    if (!CGAffineTransformEqualToTransform(_placeHolderLabel.transform, CGAffineTransformIdentity)) return;
    
    [self refreshPlaceHolderLabel];
    
    if (CGRectIsEmpty(_leftViewFrame)) {
        _leftViewFrame    = _leftView.frame;
        _placeHolderFrame = _placeHolderLabel.frame;
        _textFieldFrame   = _inputField.frame;
    }
    
    if (!_lineMaskView) {
        _lineMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _lineMaskView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_lineMaskView];
        [self bringSubviewToFront:_placeHolderLabel];
        [self bringSubviewToFront:_leftView];
    }
    float ratio = 0.8;
    
    float tW_1 = CGRectGetWidth(_leftViewFrame) * ratio;
    float tH_1 = CGRectGetHeight(_leftViewFrame) * ratio;
    float tX_1 = CGRectGetMinX(_leftViewFrame);
    float tY_1 = - tH_1 * 0.5 + CGRectGetMinY(_borderView.frame);
    
    float tW_2 = CGRectGetWidth(_placeHolderFrame) * ratio;
    float tH_2 = CGRectGetHeight(_placeHolderFrame) * ratio;
    float tX_2 = CGRectGetMinX(_placeHolderFrame) - CGRectGetMinX(_leftViewFrame) * (1 - ratio) - (CGRectGetMinX(_placeHolderFrame) - CGRectGetMaxX(_leftViewFrame)) * (1 - ratio);
    float tY_2 = - tH_2 * 0.5 + CGRectGetMinY(_borderView.frame);
    
    CGRect toFrame_leftView = CGRectMake(tX_1, tY_1, tW_1, tH_1);
    CGRect toFrame_placeHolderLabel = CGRectMake(tX_2, tY_2, tW_2, tH_2);
    
    CGRect toFrame_textField = _leftView ? CGRectMake(tX_1, CGRectGetMinY(_textFieldFrame), CGRectGetMaxX(_textFieldFrame) - tX_1, CGRectGetHeight(_textFieldFrame)) : _textFieldFrame;
    
    float offset = _leftView ? 8 : 2;
    
    _lineMaskViewCenter = _leftView ? CGPointMake((CGRectGetMinX(toFrame_leftView) + CGRectGetMaxX(toFrame_placeHolderLabel)) * 0.5, CGRectGetMinY(_borderView.frame)) : CGPointMake((CGRectGetMinX(toFrame_placeHolderLabel) + CGRectGetMaxX(toFrame_placeHolderLabel)) * 0.5, CGRectGetMinY(_borderView.frame));
    
    CGRect toFrame_lineMaskView = _leftView ? CGRectMake(tX_1 - offset, 0, tX_2 + tW_2 - tX_1 + offset * 2, tH_1) : CGRectMake(tX_2, 0, tW_2 + offset * 2, tH_2);
    
    _lineMaskView.center = _lineMaskViewCenter;
    
    CGAffineTransform transform = [self translatedAndScaledTransformUsingViewRect:toFrame_placeHolderLabel fromRect:_placeHolderFrame];
    
    [UIView animateWithDuration:HP_LEGENDFIELD_ANIMATION_DURATION animations:^{
        _leftView.frame = toFrame_leftView;
        _placeHolderLabel.transform = transform;
        _lineMaskView.frame = toFrame_lineMaskView;
        _lineMaskView.center = _lineMaskViewCenter;
        _inputField.frame = toFrame_textField;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect {
    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    CGPoint offset = CGPointMake(CGRectGetMidX(viewRect) - CGRectGetMidX(fromRect), CGRectGetMidY(viewRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y);
}

- (void)startLoseFocseAnimation
{
    if (CGAffineTransformEqualToTransform(_placeHolderLabel.transform, CGAffineTransformIdentity)) return;
    
    [UIView animateWithDuration:HP_LEGENDFIELD_ANIMATION_DURATION animations:^{
        _leftView.frame = _leftViewFrame;
        _placeHolderLabel.transform = CGAffineTransformIdentity;
        _lineMaskView.frame = CGRectMake(0, 0, 0, 0);
        _lineMaskView.center = _lineMaskViewCenter;
        _placeHolderLabel.font = _inputField.font;
        _inputField.frame = _textFieldFrame;
    }];
}


- (void)setText:(NSString *)text {
    _inputField.text = text;
    
    if (text.length == 0) {
        if (![_inputField isFirstResponder]) {
            [self startLoseFocseAnimation];
        }
    } else {
        [self startGetFocseAnimation];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.status = HPLegendTextFieldStatusFocused;
    
    if (!textField.text || textField.text.length == 0) {
        [self startGetFocseAnimation];
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [_delegate textFieldShouldBeginEditing:textField];
    }
    
    return TRUE;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.status = HPLegendTextFieldStatusNormal;
    
    if (!textField.text || textField.text.length == 0) {
        [self startLoseFocseAnimation];
    }
    if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [_delegate textFieldShouldEndEditing:textField];
    }
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_delegate textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return TRUE;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [_delegate textFieldShouldClear:textField];
    }
    return TRUE;
}

@end