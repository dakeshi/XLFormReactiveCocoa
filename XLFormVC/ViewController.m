//
//  ViewController.m
//  XLFormVC
//
//  Created by MoonSangJoon on 2015. 6. 25..

//

#import "ViewController.h"
#import "FloatLabeledTextFieldCell.h"
#import "XLFormImageSelectorCell.h"
#import "CurrencyFormatterCell.h"
#import <XLForm.h>


@interface ViewController ()

@end

NSString *const kCustomRowFloatLabeledTextFieldTag = @"customRowFloatLabeledTextFieldTag";
NSString *const kCurrency = @"customCurrencyTag";
NSString *const kButton = @"resultButton";
NSString *const kCustomImgCellTag = @"customImgCellTag";

@implementation ViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"Custom Rows"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    

    section = [XLFormSectionDescriptor formSectionWithTitle:@"* : Required Info"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCustomRowFloatLabeledTextFieldTag rowType:XLFormRowDescriptorTypeFloatLabeledTextField title:NSLocalizedString(@"ProductName", nil)];
    [section addFormRow:row];
    
    // 판매가격. Custom CurrencyFormmaterCell
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCurrency rowType:XLFormRowDescriptorTypeCurrencyFormatterCell title:NSLocalizedString(@"Price", @"with currency")];
    row.value = @"0";
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kButton rowType:XLFormRowDescriptorTypeButton title:@"Results"];
    [row.cellConfig setObject:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forKey:@"textLabel.textColor"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    
//    XLFormRowDescriptor *customRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:kCustomImgCellTag rowType:kFormImageSelectorCellDefaultImage];
//    customRowDescriptor.cellClass = [XLFormImageSelectorCell class];
//    [section addFormRow:customRowDescriptor];
    
    self.form = form;

    
}

-(void)didTouchButton:(XLFormRowDescriptor *)sender
{
    NSString *result = [self.form formRowWithTag:kCustomRowFloatLabeledTextFieldTag].value;

    NSString *price = [self.form formRowWithTag:kCurrency].value;
#if DEBUG
    NSLog(@"ProductName is : %@\nAnd price is = %@", result, price);
#endif
    [self deselectFormRow:sender];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
