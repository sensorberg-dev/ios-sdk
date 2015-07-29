# GBJailbreakDetection

iOS jailbreak detection framework for [GBDeviceInfo](https://github.com/lmirosevic/GBDeviceInfo).

Usage
------------

This is a closed source component of the `GBDeviceInfo` framework, so you would use it as part of `GBDeviceInfo`:

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>

BOOL isJailbroken = [GBDeviceInfo deviceInfo].isJailbroken;
```

Installation
------------

Use CocoaPods, add this to your project's Podfile and run `pod install`:

```
pod 'GBDeviceInfo'
```

Author
------------

[Luka Mirosevic](mailto:luka@goonbee.com) ([@lmirosevic](https://twitter.com/lmirosevic))

Copyright & License
------------

Copyright 2015 Goonbee

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
