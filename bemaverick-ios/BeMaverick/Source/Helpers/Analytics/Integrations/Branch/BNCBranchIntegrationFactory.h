#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegrationFactory.h>

@interface BNCBranchIntegrationFactory : NSObject<SEGIntegrationFactory>

+ (instancetype)instance;

@end
