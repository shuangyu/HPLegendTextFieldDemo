//
//  HPLegendTextField.h
//  AnimationDemo
//
//  Created by hupeng on 15/6/24.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HPLegendTextFieldStatusNormal,
    HPLegendTextFieldStatusFocused,
    HPLegendTextFieldStatusError
    
} HPLegendTextFieldStatus;

@interface HPLegendFieldBorder : UIView

@property (nonatomic, assign) HPLegendTextFieldStatus status;

@end

@interface HPLegendFieldIcon : UIImageView

@property (nonatomic, assign) HPLegendTextFieldStatus status;

@end

@interface HPLegendTextField : UIView<UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet id <UITextFieldDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField *inputField;

@property (nonatomic, assign) HPLegendTextFieldStatus status;

@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, strong) NSString *text;

@end
