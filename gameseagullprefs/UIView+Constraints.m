#include "UIView+Constraints.h"

@implementation UIView (fconstraints)
-(void)anchorTop:(NSLayoutAnchor <NSLayoutYAxisAnchor *> *)top 
         leading:(NSLayoutAnchor <NSLayoutXAxisAnchor *> *)leading 
          bottom:(NSLayoutAnchor <NSLayoutYAxisAnchor *> *)bottom 
        trailing:(NSLayoutAnchor <NSLayoutXAxisAnchor *> *)trailing 
         padding:(UIEdgeInsets)insets 
            size:(CGSize)size {

    self.translatesAutoresizingMaskIntoConstraints = NO;

    if (top != nil) {
        [self.topAnchor constraintEqualToAnchor:top constant:insets.top].active = YES;
    }

    if (leading != nil) {
        [self.leadingAnchor constraintEqualToAnchor:leading constant:insets.left].active = YES;
    }

    if (bottom != nil) {
        [self.bottomAnchor constraintEqualToAnchor:bottom constant:-insets.bottom].active = YES;
    }

    if (trailing != nil) {
        [self.trailingAnchor constraintEqualToAnchor:trailing constant:-insets.right].active = YES;
    }

    if (size.width != 0) {
        [self.widthAnchor constraintEqualToConstant:size.width].active = YES;
    }

    if (size.height != 0) {
        [self.heightAnchor constraintEqualToConstant:size.height].active = YES;
    }

}

-(void)anchorSizeToView:(UIView *)view {
    [self.widthAnchor constraintEqualToAnchor:view.widthAnchor].active = YES;
    [self.heightAnchor constraintEqualToAnchor:view.heightAnchor].active = YES;
}

-(void)centerInView:(UIView *)view {
    [self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = YES;
    [self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = YES;
}

-(void)heightWidthAnchorsEqualToSize:(CGSize)size {
    if (size.width != 0) {
        [self.widthAnchor constraintEqualToConstant:size.width].active = YES;
    }

    if (size.height != 0) {
        [self.heightAnchor constraintEqualToConstant:size.height].active = YES;
    }
}

-(void)fillSuperview {
    [self anchorTop:self.superview.topAnchor leading:self.superview.leadingAnchor bottom:self.superview.bottomAnchor trailing:self.superview.trailingAnchor padding:UIEdgeInsetsZero size:CGSizeZero];
}

@end
