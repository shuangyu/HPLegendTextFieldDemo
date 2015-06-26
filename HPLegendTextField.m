//
//  HPLegendTextField.m
//  AnimationDemo
//
//  Created by hupeng on 15/6/24.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//


#define HP_LEGENDFIELD_SELECT_COLOR [UIColor colorWithRed:153.0/255.0 green:189.0/255.0 blue:169.0/255.0 alpha:1.0]
#define HP_LEGENDFIELD_NORMAL_COLOR [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]
#define HP_LEGENDFIELD_ERROR_COLOR  [UIColor colorWithRed:183.0/255.0 green:123.0/255.0 blue:115.0/255.0 alpha:1.0]

#define HP_LEGENDFIELD_ANIMATION_DURATION 0.25

#import "HPLegendTextField.h"
#import "HPAnimationFactory.h"

@implementation HPLegendFieldBorder

- (void)awakeFromNib
{
    self.layer.cornerRadius = 4.0;
    self.layer.borderColor  = HP_LEGENDFIELD_NORMAL_COLOR.CGColor;
    self.layer.borderWidth  = 1.0 ;
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

@property (nonatomic, weak) IBOutlet UITextField *inputField;
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
}

- (void)updateInterface
{
    _inputField.delegate = self;
    
    // 1. prepare place holder view
    NSString *placeHolder = _inputField.placeholder;
    
    _placeHolderLabel = [[UILabel alloc] init];
    _placeHolderLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _placeHolderLabel.font = _inputField.font;
    _placeHolderLabel.text = placeHolder;
    _placeHolderLabel.backgroundColor = [UIColor clearColor];
    _placeHolderLabel.textColor = HP_LEGENDFIELD_NORMAL_COLOR;
    
    CGRect realRect = [placeHolder boundingRectWithSize:_inputField.frame.size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : _placeHolderLabel.font}
                                                context:nil];
    
    realRect.origin.x = _inputField.frame.origin.x;
    realRect.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(realRect)) * 0.5;
    
    _placeHolderLabel.frame = realRect;
    
    [self insertSubview:_placeHolderLabel belowSubview:_inputField];
    
    _inputField.placeholder = nil;
    
    // 2. prepare image view
    
    CGPoint center = _leftView.center;
    CGRect frame = _leftView.frame;
    
    UIImage *image = _leftView.image;
    frame.size = image.size;
    _leftView.frame = frame;
    _leftView.center = center;
    _leftView.contentMode = UIViewContentModeScaleToFill;
    
}

- (void)startGetFocseAnimation
{
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
    float tW_1 = CGRectGetWidth(_leftViewFrame) * 0.5;
    float tH_1 = CGRectGetHeight(_leftViewFrame) * 0.5;
    float tX_1 = CGRectGetMinX(_leftViewFrame);
    float tY_1 = - tH_1 * 0.5 + CGRectGetMinY(_borderView.frame);
    
    float tW_2 = CGRectGetWidth(_placeHolderFrame) * 0.5;
    float tH_2 = CGRectGetHeight(_placeHolderFrame) * 0.5;
    float tX_2 = CGRectGetMinX(_placeHolderFrame) - CGRectGetMinX(_leftViewFrame) * 0.5;
    float tY_2 = - tH_2 * 0.5 + CGRectGetMinY(_borderView.frame);
    
    CGRect toFrame_leftView = CGRectMake(tX_1, tY_1, tW_1, tH_1);
    CGRect toFrame_placeHolderLabel = CGRectMake(tX_2, tY_2, tW_2, tH_2);
    
    CGRect toFrame_textField = CGRectMake(tX_1, CGRectGetMinY(_textFieldFrame), CGRectGetMaxX(_textFieldFrame) - tX_1, CGRectGetHeight(_textFieldFrame));
    
    float offset = 8;
    
    _lineMaskViewCenter =  CGPointMake((CGRectGetMinX(toFrame_leftView) + CGRectGetMaxX(toFrame_placeHolderLabel)) * 0.5, CGRectGetMinY(_borderView.frame));
    
    CGRect toFrame_lineMaskView = CGRectMake(tX_1 - offset, 0, tX_2 + tW_2 - tX_1 + offset * 2, tH_1);
    
    _lineMaskView.center = _lineMaskViewCenter;
    
    [UIView animateWithDuration:HP_LEGENDFIELD_ANIMATION_DURATION animations:^{
        _leftView.frame = toFrame_leftView;
        _placeHolderLabel.frame = toFrame_placeHolderLabel;
        _placeHolderLabel.font = [UIFont fontWithName:_placeHolderLabel.font.fontName size:_placeHolderLabel.font.pointSize * 0.5];
        _lineMaskView.frame = toFrame_lineMaskView;
        _lineMaskView.center = _lineMaskViewCenter;
        _inputField.frame = toFrame_textField;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startLoseFocseAnimation
{
    [UIView animateWithDuration:HP_LEGENDFIELD_ANIMATION_DURATION animations:^{
        _leftView.frame = _leftViewFrame;
        _placeHolderLabel.frame = _placeHolderFrame;
        _lineMaskView.frame = CGRectMake(0, 0, 0, 0);
        _lineMaskView.center = _lineMaskViewCenter;
        _placeHolderLabel.font = _inputField.font;
        _inputField.frame = _textFieldFrame;
    }];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_delegate textFieldShouldReturn:textField];
    }
    return TRUE;
}
@end