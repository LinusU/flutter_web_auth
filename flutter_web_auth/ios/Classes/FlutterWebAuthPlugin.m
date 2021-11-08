#import "FlutterWebAuthPlugin.h"
#import <flutter_web_auth/flutter_web_auth-Swift.h>

@implementation FlutterWebAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWebAuthPlugin registerWithRegistrar:registrar];
}
@end
