//
//  CurrencyFormatterCell.h
//  XLFormVC
//
//  Created by MoonSangJoon on 2015. 6. 29..

//

#import <UIKit/UIKit.h>
#import <XLFormBaseCell.h>
#import <TSCurrencyTextField.h>

extern NSString * const XLFormRowDescriptorTypeCurrencyFormatterCell;

@interface CurrencyFormatterCell : XLFormBaseCell


@property (nonatomic) TSCurrencyTextField * currencyTextField;

@end
