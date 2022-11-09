 ## 2.0.2

- 🐛 Fix windows callback verification ([#22](https://github.com/ThexXTURBOXx/flutter_web_auth_2/issues/22))

## 2.0.1

- 🌹 Merge upstream changes (most notably troubleshooting documentation)
- 🌹 Added `redirectOriginOverride` for web implementations (By [Rexios80](https://github.com/Rexios80))
- 🌹 Fix some documentation and changelogs

## 2.0.0

- 💥 Full two-package federated plugin refactor

## 1.1.2

- 🌹 Support `win32` versions `2.7.0` until `3.x`

## 1.1.1

- 🐛 Fix Windows support and support for future platforms
- 🐛 Fix example on Windows
- 🌹 `127.0.0.1` is now also a supported callback URL host on Windows
- 🌹 Cleaned up platform implementations

## 1.1.0

- 🌹 Tested `flutter_web_auth_2` with Flutter `3.3.0`, seems to work!
- 🌹 Update `win32` to `3.0.0` (relevant only for Windows users)
- 🌹 Add `android:exported` tag to documentation *before* users start to complain
- 🌹 Overhauled example layout

## 1.0.1

- 🐛 Remove path dependency
- 🌹 Add migration guide README
- 🌹 Add more documentation

## 1.0.0

- 💥 Old project, new maintainers! Due to the lack of updates in the main project, we forked the project and will update it as time passes!
- 💥 Update to Flutter 3 ([#118](https://github.com/LinusU/flutter_web_auth/pull/118))
- 💥 Federated plugin refactor ([#98](https://github.com/LinusU/flutter_web_auth/pull/98))
- 💥 Windows support (By [Jon-Salmon](https://github.com/Jon-Salmon/flutter_web_auth/tree/windows-implementation))
- 🎉 Add support for ephemeral sessions on MacOS ([#112](https://github.com/LinusU/flutter_web_auth/pull/112))

## 0.4.1

- 🎉 Add support for Flutter "add to app" ([#106](https://github.com/LinusU/flutter_web_auth/pull/106))

## 0.4.0

- 💥 Upgrade to Android V2 embedding ([#87](https://github.com/LinusU/flutter_web_auth/pull/87))

  Migration guide:

  Make sure that you are running a recent version of Flutter before upgrading.

## 0.3.2

- 🎉 Add Web support ([#77](https://github.com/LinusU/flutter_web_auth/pull/77))

## 0.3.1

- 🎉 Add support for Android Plugin API v2 ([#67](https://github.com/LinusU/flutter_web_auth/pull/67))
- 🎉 Add support for ephemeral sessions ([#64](https://github.com/LinusU/flutter_web_auth/pull/64))
- 🌹 Avoid deprecated RaisedButton in example ([#75](https://github.com/LinusU/flutter_web_auth/pull/75))
- 🌹 Cleanup metadata

## 0.3.0

- 💥 Add null safety support ([#60](https://github.com/LinusU/flutter_web_auth/pull/60))

  Migration guide:

  This version drops support for Flutter 1.x, please upgrade to Flutter 2 for continued support.

## 0.2.4

- 🐛 Fix building on iOS ([#36](https://github.com/LinusU/flutter_web_auth/pull/36))

## 0.2.3

- 🐛 Remove NoHistory flag ([#33](https://github.com/LinusU/flutter_web_auth/pull/33))
- 🐛 Fix building on iOS 8, 9, and 10 ([#29](https://github.com/LinusU/flutter_web_auth/pull/29))
- 🐛 Always terminate 'authenticate' callbacks on Android ([#28](https://github.com/LinusU/flutter_web_auth/pull/28))

## 0.2.2

- 🐛 Fix propagation of "CANCELED" error on iOS ([#31](https://github.com/LinusU/flutter_web_auth/pull/31))

## 0.2.1

- 🐛 Fix AndroidX build issues ([#27](https://github.com/LinusU/flutter_web_auth/pull/27))

## 0.2.0

- 💥 Add macOS support ([#20](https://github.com/LinusU/flutter_web_auth/pull/20))

  Migration guide:

  This version drops support for Flutter 1.9 and older, please upgrade to Flutter 1.12 for continued support.

## 0.1.3

- 🎉 Update the kotlin plugin version to 1.3.61

## 0.1.2

- 🎉 Add support for iOS 13

## 0.1.1

- 🐛 Add swift_version to the Podspec
- 🐛 Update Gradle and Kotlin versions
- 🐛 Add missing link in readme

## 0.1.0

- 🎉 Add initial implementation
