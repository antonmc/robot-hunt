#import <UIKit/UIKit.h>
#import "Help.h"

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *subtext;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *descriptionText;
@property UIImage *image;
@property Help *help;

@end
