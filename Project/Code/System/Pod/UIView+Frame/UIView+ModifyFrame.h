/* 

Before:  
    CGRect frame = myView.frame;
    frame.origin.x = newX;
    myView.frame = frame;

After:  
    myView.x = newX;
 
*/

#import <UIKit/UIKit.h>

@interface UIView (Ext)

@property float x;
@property float y;
@property float width;
@property float height;
@property float bottom;
-(void)setCenterX:(float)x;
-(void)setCenterY:(float)y;

-(float) right;
@end
