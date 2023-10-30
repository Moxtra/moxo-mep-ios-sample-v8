# moxo-mep-ios-sample-v8

iOS moxo sdk integration demo

## Installation

### Clone project or download manually

* ``git clone https://github.com/Moxtra/moxo-mep-ios-sample-v8``

### Pod install

run 'pod install' under 'MoxoDemo' folder:

```
cd moxo-mep-ios-sample-v8/MoxoDemo
pod install
```

### Swift package manager
Swift package is now available for Moxo iOS Dynamic SDK also.
Steps:
1. Open your project in Xcode
2. Go to File > Swift Packages > Add Package Dependency
3. Enter moxo sdk url: https://maven.moxtra.com/repo/mepsdkdylib.git
4. Choose project and sdk version
5. Click 'Add Package'

### Fill environment information:

find 'moxo-mep-ios-sample-v8/MoxoDemo/MoxoDemo/ViewController.swift'
fill below constants before run project:

```
let MOXTRA_DOMAIN = ""
let CLIENT_ID = ""
let CLIENT_SECRET = ""
let ORG_ID = ""
let DEFAULT_UNIQUEID = ""
```

### Run project
open 'moxo-mep-ios-sample-v8/MoxoDemo/MoxoDemo.xcworkspace' with Xcode to run on iOS