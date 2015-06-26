#import "FloatLabeledTextFieldCell.h"
#import <UIView+XLFormAdditions.h>
#import <JVFloatLabeledTextField.h>
#import <NSObject+XLFormAdditions.h>

#import <ReactiveCocoa.h>
#import <RACEXTScope.h>

#define MAS_SHORTHAND
#import <Masonry.h>

NSString * const XLFormRowDescriptorTypeFloatLabeledTextField = @"XLFormRowDescriptorTypeFloatLabeledTextField";

const static CGFloat kFloatingLabelFontSize = 11.0f;

@interface FloatLabeledTextFieldCell () <UITextFieldDelegate>
@property (nonatomic) JVFloatLabeledTextField * floatLabeledTextField;
@property (nonatomic) UIImageView *mandatoryImageView;
@property (nonatomic) UIImageView *validationImageView;

@end

@implementation FloatLabeledTextFieldCell

@synthesize floatLabeledTextField =_floatLabeledTextField;

+(void)load
{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[FloatLabeledTextFieldCell class] forKey:XLFormRowDescriptorTypeFloatLabeledTextField];
}

#pragma mark - property setter

-(JVFloatLabeledTextField *)floatLabeledTextField
{
    if (_floatLabeledTextField) return _floatLabeledTextField;
    
    _floatLabeledTextField = [JVFloatLabeledTextField autolayoutView];
    _floatLabeledTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _floatLabeledTextField.floatingLabel.font = [UIFont boldSystemFontOfSize:kFloatingLabelFontSize];

    _floatLabeledTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return _floatLabeledTextField;
}


-(UIImageView *)mandatoryImageView{
    
    if(!_mandatoryImageView){
        
        _mandatoryImageView = [UIImageView autolayoutView];
        _mandatoryImageView.clipsToBounds = YES;
        _mandatoryImageView.contentMode = UIViewContentModeScaleToFill;
        
    }
    return _mandatoryImageView;
}

-(UIImageView *)validationImageView{
    
    if(!_validationImageView){
        
        _validationImageView = [UIImageView autolayoutView];
        _validationImageView.clipsToBounds = YES;
        _validationImageView.contentMode = UIViewContentModeScaleToFill;
        
    }
    return _validationImageView;
}


#pragma mark - setupMandatoryImageView

- (void)setupMandatoryImageView {
    
    UIImage *asterixImage = [UIImage imageNamed:@"asterix"];
    
    self.mandatoryImageView.image = asterixImage;
    self.mandatoryImageView.hidden = NO;
    
    [self.mandatoryImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(asterixImage.size.width));
        make.height.equalTo(@(asterixImage.size.height));
        make.centerY.equalTo(self.contentView.centerY);
        make.left.equalTo(self.contentView.left).offset(4);
        make.right.equalTo(self.floatLabeledTextField.left).offset(-4);

    }];
}

#pragma mark - setupValidationImageView
- (void)setupValidationImageView {
    
    UIImage *exclamationMarkImage = [UIImage imageNamed:@"exclamationMark"];
    
    self.validationImageView.image = exclamationMarkImage;
    self.validationImageView.hidden = NO;
    
    [self.validationImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(exclamationMarkImage.size.width));
        make.height.equalTo(@(exclamationMarkImage.size.height));
        make.centerY.equalTo(self.contentView.centerY);
        make.right.equalTo(self.contentView.right).offset(-4);
        make.left.equalTo(self.floatLabeledTextField.right).offset(4);
        
    }];
}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView addSubview:self.mandatoryImageView];
    [self.contentView addSubview:self.floatLabeledTextField];
    [self.contentView addSubview:self.validationImageView];
    
    [self setupMandatoryImageView];
    [self setupValidationImageView];
    

    [self.floatLabeledTextField mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.contentView.top).offset(8);
        make.bottom.equalTo(self.contentView.bottom).offset(-8);

    }];
    
    // binding textfield signal
    RAC(self, rowDescriptor.value) = self.floatLabeledTextField.rac_textSignal;
    
    // create validationSignal
    RACSignal *validProductTitleSignal =
    [self.floatLabeledTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidTitle:text]);
     }];
    
    // change validationImageView image as validation result
    RAC(self.validationImageView, image) =
    [validProductTitleSignal
     map:^id(NSNumber *titleValid) {
        return [titleValid boolValue] ?
         [UIImage imageNamed:@"checkmark"]:
         [UIImage imageNamed:@"exclamationMark"];
    }];
    
}


/**
 *  productTitle's length must be less than 50,  be not the whiteSpace characters.
 *
 *  @param text textField input
 *
 *  @return return BOOL validation OK is YES, otherwise NO
 */
-(BOOL)isValidTitle :(NSString *)text{
    
    return (text.length < 50 && (text.length > 1 && [self isNotWhiteSpace : text]));

}

/**
 *  whitespace checker
 *
 *  @param text textField input
 *
 *  @return return BOOL only whitespace is NO, otherwise YES
 */
-(BOOL)isNotWhiteSpace :(NSString *)text {
    
    // 입력값 전체가 공백일 경우를 확인한다.
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:charSet];
    if ([trimmedString isEqualToString:@""]) {
        // it contains only white spaces
        return NO;
    }else{
        return YES;
    }
}


-(void)update
{
    [super update];
    
    self.floatLabeledTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:self.rowDescriptor.title
                                    attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
//    self.floatLabeledTextField.text = self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText;
    [self.floatLabeledTextField setEnabled:!self.rowDescriptor.isDisabled];
    
    self.floatLabeledTextField.floatingLabelTextColor = [UIColor lightGrayColor];
    
    [self.floatLabeledTextField setAlpha:((self.rowDescriptor.isDisabled) ? .6 : 1)];
    

}

-(BOOL)formDescriptorCellCanBecomeFirstResponder
{
    return !self.rowDescriptor.isDisabled;
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.floatLabeledTextField becomeFirstResponder];
}


-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    self.floatLabeledTextField.returnKeyType = returnKeyType;
}

-(UIReturnKeyType)returnKeyType
{
    return self.floatLabeledTextField.returnKeyType;
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 55;
}



@end
