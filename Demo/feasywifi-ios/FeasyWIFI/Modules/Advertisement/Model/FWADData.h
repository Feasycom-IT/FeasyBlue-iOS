#import <UIKit/UIKit.h>

@interface FWADData : NSObject

@property (nonatomic, strong) NSString * image;
@property (nonatomic, assign) NSInteger verion;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end