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
@property (nonatomic) NSNumberFormatter *currencyNumberFormatter;


@end

@implementation CurrencyFormatterCell
@synthesize titleLabel = _titleLabel, currencyNumberFormatter = _currencyNumberFormatter;


+(void)load
{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[CurrencyFormatterCell class] forKey:XLFormRowDescriptorTypeCurrencyFormatterCell];
}


#pragma mark - property setter/getter

-(UITextField *)currencyTextField
{
    if (_currencyTextField) return _currencyTextField;
    
    _currencyTextField = [UITextField autolayoutView];
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
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor lightGrayColor];
    
    return _titleLabel;
}

-(NSNumberFormatter *)currencyNumberFormatter{
    
    if(!_currencyNumberFormatter) _currencyNumberFormatter = [[NSNumberFormatter alloc] init];
    
    return _currencyNumberFormatter;
}


#pragma mark - configure customCell in XLForm
-(void)configure{
    
    [super configure];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.currencyTextField];


    // configure autoLayout
    
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
    
    
    // set specific locale
//    NSLocale *customLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];

    // 1. configure currencyNumberFormatter
    
    // set locale with currentLocale value
    NSLocale *customLocale = [NSLocale currentLocale];
    [self.currencyNumberFormatter setLocale:customLocale];

    [self.currencyNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    [self.currencyNumberFormatter setMinimumFractionDigits:0];
    [self.currencyNumberFormatter setMaximumFractionDigits:0];

    // 2. convert Textfield input to currency format string
    RAC(self.currencyTextField, text) = [[self.currencyTextField.rac_textSignal ignore:nil]
                                         map:^id(NSString *text) {
                                             
                                             NSString *currencyString = [self.currencyNumberFormatter stringFromNumber: [self stringToCurrency: text]];
                                             
                                             return currencyString;
                                             
                                         }];
    
    
    // 3. Binding rowDescriptor.value with formattedCurrency value
    RAC(self, rowDescriptor.value) =
    
    [[self.currencyTextField.rac_textSignal ignore:nil] map:^id(NSString *text) {

         // remove currency symbol
         NSNumber *formattedCurrency = [self.currencyNumberFormatter numberFromString:text];
         
         return [formattedCurrency stringValue];
    }];
    
    
    [self.currencyTextField setKeyboardType:UIKeyboardTypeDecimalPad];

}

#pragma mark - update
-(void)update
{
    [super update];
    
    // set titleLabel with rowDescriptor.title.
    self.titleLabel.text = self.rowDescriptor.title;
    
    self.currencyTextField.text = self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText;

    [self.currencyTextField setEnabled:!self.rowDescriptor.isDisabled];
    
    [self.currencyTextField setAlpha:((self.rowDescriptor.isDisabled) ? .6 : 1)];
    
    
}

/**
 *  @brief convert textField input to NSNumber with currency format
 *
 *  @param string textFiled input
 *
 *  @return NSNumber NSNumber with currencyNumberFormat
 */

- (NSNumber*) stringToCurrency : (NSString*) string
{

    NSString* digitString = [[string componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString: @""];
    
    NSInteger fd = self.currencyNumberFormatter.minimumFractionDigits;
    

    NSNumber* n = [NSNumber numberWithDouble: [digitString doubleValue] / pow(10.0, fd) ];
    
    return n;
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
