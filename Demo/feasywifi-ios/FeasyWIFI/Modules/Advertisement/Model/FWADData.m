//
//	FWADData.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "FWADData.h"

NSString *const kFWADDataImage = @"image";
NSString *const kFWADDataVerion = @"verion";

@interface FWADData ()
@end
@implementation FWADData




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kFWADDataImage] isKindOfClass:[NSNull class]]){
		self.image = dictionary[kFWADDataImage];
	}	
	if(![dictionary[kFWADDataVerion] isKindOfClass:[NSNull class]]){
		self.verion = [dictionary[kFWADDataVerion] integerValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.image != nil){
		dictionary[kFWADDataImage] = self.image;
	}
	dictionary[kFWADDataVerion] = @(self.verion);
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.image != nil){
		[aCoder encodeObject:self.image forKey:kFWADDataImage];
	}
	[aCoder encodeObject:@(self.verion) forKey:kFWADDataVerion];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.image = [aDecoder decodeObjectForKey:kFWADDataImage];
	self.verion = [[aDecoder decodeObjectForKey:kFWADDataVerion] integerValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	FWADData *copy = [FWADData new];

	copy.image = [self.image copy];
	copy.verion = self.verion;

	return copy;
}
@end