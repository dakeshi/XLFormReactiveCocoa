//
//  CurrencyFormatterCell.m
//  XLFormVC
//
//  Created by MoonSangJoon on 2015. 6. 29..

//

#import "CurrencyFormatterCell.h"
#import <UIView+XLFormAdditions.h>
#import <NSObject+XLFormAdditions.h>
#import <XLFormRowDescriptor.h>
#import <ReactiveCocoa.h>
#import <RACEXTScope.h>

#define MAS_SHORTHAND
#import <Masonry.h>

NSString * const XLFormRowDescriptorTypeCurrencyFormatterCell = @"XLFormRowDescriptorTypeCurrencyFormatterCell";


@interface CurrencyFormatterCell()

@property (nonatomic) UILabel * titleLabel;


@end

@implementation CurrencyFormatterCell

+(void)load
{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[CurrencyFormatterCell class] forKey:XLFormRowDescriptorTypeCurrencyFormatterCell];
}


#pragma mark - property setter

-(TSCurrencyTextField *)currencyTextField
{
    if (_currencyTextField) return _currencyTextField;
    
    _currencyTextField = [TSCurrencyTextField autolayoutView];
    _currencyTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    
    _currencyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _currencyTextField.textAlignment = NSTextAlignmentRight;
    _currencyTextField.textColor = [UIColor lightGrayColor];

    return _currencyTextField;
}

-(UILabel *)titleLabel{
    
    if(_titleLabel) return _titleLabel;
    
    _titleLabel = [UILabel autolayoutView];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return _titleLabel;
}

-(void)configure{
    
    [super configure];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.currencyTextField];


    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.top).offset(8);
        make.bottom.equalTo(self.contentView.bottom).offset(-8);
        make.left.equalTo(self.contentView.left).offset(6);
        make.right.equalTo(self.currencyTextField.left).offset(-8);
        make.width.equalTo(@80);
    }];
    

    
    [self.currencyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).offset(-8);
        make.bottom.equalTo(self.contentView.bottom).offset(-8);

        make.top.equalTo(self.contentView.top).offset(8);


    }];
    
    // rowDescriptor.value에 통화표기 symbol 문자열을 제외한 문자열만 전달하기 위해
    // formatter를 설정한다.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    // 1. locale을 ko_KR로 설정
//    NSLocale *customLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    
    NSLocale *customLocale = [NSLocale currentLocale];
    [nf setLocale:customLocale];
    
    
    // 2. 가격표시는 통화 포맷이 사용됨. locale을 한국으로 설정하였으므로,
    // 숫자 앞에 원 표시와 천 단위 숫자 구분점이 나타난다.
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    // 3. 소수점 이하는 표기하지 않는다.
    [nf setMaximumFractionDigits:0];

    
    // Binding rowDescriptor.value with formattedCurrency value
    RAC(self, rowDescriptor.value) =
    
    [self.currencyTextField.rac_textSignal map:^id(NSString *text) {
         
#if DEBUG
         NSLog(@"text = %@", text);
#endif

         // map을 이용해 text에서 sysmbol 문자를 제외한 문자열(숫자값)만 추출한다.
         NSNumber *formattedCurrency = [nf numberFromString:text];
         
         return [formattedCurrency stringValue];
    }];

}

-(void)update
{
    [super update];
    
    self.titleLabel.text = self.rowDescriptor.title;
    
    self.currencyTextField.text = self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText;

    [self.currencyTextField setEnabled:!self.rowDescriptor.isDisabled];
    
    [self.currencyTextField setAlpha:((self.rowDescriptor.isDisabled) ? .6 : 1)];
    
    [self.currencyTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    
}

-(BOOL)formDescriptorCellCanBecomeFirstResponder
{
    return !self.rowDescriptor.isDisabled;
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.currencyTextField becomeFirstResponder];
}

-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    self.currencyTextField.returnKeyType = returnKeyType;
}

-(UIReturnKeyType)returnKeyType
{
    return self.currencyTextField.returnKeyType;
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 50;
}

@end
