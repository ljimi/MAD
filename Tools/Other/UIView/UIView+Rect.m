

#import "UIView+Rect.h"

#define COMMON_STATEMENT_WITH_DIFFERENCE(STATEMENT) {CGRect frame = self.frame;STATEMENT;self.frame = frame;}

@implementation UIView (Rect)

- (CGFloat)x {
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x {
    COMMON_STATEMENT_WITH_DIFFERENCE(frame.origin.x = x);
}

- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
     COMMON_STATEMENT_WITH_DIFFERENCE(frame.origin.y = y);
}

- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
     COMMON_STATEMENT_WITH_DIFFERENCE(frame.size.width = width);
}

- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    COMMON_STATEMENT_WITH_DIFFERENCE(frame.size.height = height);
}

- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

-(CGSize)size{
    return self.frame.size;
}


-(void)setSize:(CGSize)size{
    COMMON_STATEMENT_WITH_DIFFERENCE(frame.size = size);
}

- (CGFloat)maxX {
    return self.frame.origin.x + self.frame.size.width;
}
- (void)setMaxX:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)maxY {
    return self.frame.origin.y + self.frame.size.height;
}
- (void)setMaxY:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


@end
