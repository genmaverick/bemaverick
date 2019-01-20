# BeMaverick for iOS
Hello, world

## Getting Started

Clone repository (recursive to fetch a submodule) and then fetch the CocoaPod dependencies
```sh
$ git clone https://github.com/BeMaverickCo/bemaverick-ios.git
$ cd bemaverick-ios
$ git checkout develop
$ git submodule update --init
$ cd BeMaverick
$ pod install
```

Open `BeMaverick.xcworkspace`

## Fastlane Actions

| Command | Options  | Description|
|--|--|--|
|**com.bemaverick.bemaverick-ios**|
|fastlane prod  |beta:true/false| if true, sends compiled app to Crashlytics beta|
|fastlane prod|slack:true/false|if true, sends release notes to #internalteam Slack channel|
|fastlane prod|store:true/false|if true, sends the compiled app to iTunes Connect
|**com.bemaverick.bemaverick-ios-dev**|
|fastlane dev  |beta:true/false| if true, sends compiled app to Crashlytics beta|
|fastlane dev|slack:true/false|if true, sends release notes to #internalteam Slack channel|




## Developer Account

We use a single apple developer account through fastlane that manages signing and provisioning.  This account is tied to the email address: dev@bemaverick.com

In order to do any building or development you will need to log in through this account, to get the password and github repo passphrase for the signing, contact garrett@bemaverick.com

