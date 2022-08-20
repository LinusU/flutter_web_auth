//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_web_auth_2/FlutterWebAuth2Plugin.h>)
#import <flutter_web_auth_2/FlutterWebAuth2Plugin.h>
#else
@import flutter_web_auth_2;
#endif

#if __has_include(<url_launcher_ios/FLTURLLauncherPlugin.h>)
#import <url_launcher_ios/FLTURLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterWebAuth2Plugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterWebAuth2Plugin"]];
  [FLTURLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTURLLauncherPlugin"]];
}

@end
