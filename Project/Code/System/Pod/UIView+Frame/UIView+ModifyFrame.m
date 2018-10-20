#import "UIView+ModifyFrame.h"

@implementation UIView (Ext)

-(float) x {
    return self.frame.origin.x;
}

-(void) setX:(float) newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

-(float) y {
    return self.frame.origin.y;
}

-(void) setY:(float) newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

-(float) width {
    return self.frame.size.width;
}

-(float) bottom {
    return self.frame.size.height + self.frame.origin.y;
}

-(void)setBottom:(float)bottom
{
    CGRect rect = self.frame;
    rect.origin.y = bottom - self.frame.size.height;
    self.frame = rect;
}

-(void) setWidth:(float) newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

-(float) height {
    return self.frame.size.height;
}

-(void) setHeight:(float) newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

-(void)setCenterX:(float)x
{
    CGPoint point = self.center;
    point.x = x;
    self.center = point;
}

-(void)setCenterY:(float)y
{
    CGPoint point = self.center;
    point.y = y;
    self.center = point;
}

-(float) right {
    return self.frame.size.width + self.frame.origin.x;
}
@end
