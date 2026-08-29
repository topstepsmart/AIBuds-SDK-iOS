#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileImportVideoComparisonController : UIViewController
- (instancetype)initWithOriginalURL:(NSURL *)originalURL
                      stabilizedURL:(NSURL *)stabilizedURL;
@end

NS_ASSUME_NONNULL_END
