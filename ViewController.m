//
//  ViewController.m
//  HPLegendTextFieldDemo
//
//  Created by hupeng on 15/6/26.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import "ViewController.h"
#import "HPLegendTextField.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet HPLegendTextField *legendField;

@end

@implementation ViewController

- (IBAction)showErrorButtonClicked:(id)sender
{
    _legendField.status = HPLegendTextFieldStatusError;
}

@end
