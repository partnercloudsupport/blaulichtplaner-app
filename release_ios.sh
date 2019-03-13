#!/bin/bash

buildNumber=$(<last_release_ios.txt)
buildNumber=$((buildNumber+1))

cp ios/Runner/GoogleService-Info-Prd.plist ios/Runner/GoogleService-Info.plist
git tag -a ios_v$buildNumber -m "prepare ios build $buildNumber"
echo "$buildNumber" > last_release_ios.txt
flutter build ios --release --build-number $buildNumber --build-name 1.$buildNumber

echo ""
read -p "Bitte jetzt Archiv erstellen und hochladen. Weiter mit ENTER."

cp ios/Runner/GoogleService-Info-Test.plist ios/Runner/GoogleService-Info.plist
