#import "FlutterWebAuthPlugin.h"
#import <flutter_web_auth_2/flutter_web_auth_2-Swift.h>

@implementation FlutterWebAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWebAuthPlugin registerWithRegistrar:registrar];
}
@end
