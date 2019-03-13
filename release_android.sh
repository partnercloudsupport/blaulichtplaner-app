#!/bin/bash

buildNumber=$(<last_release_android.txt)
buildNumber=$((buildNumber+1))

git tag -a android_v$buildNumber -m "prepare android build $buildNumber"
echo "$buildNumber" > last_release_android.txt
flutter build apk --release --build-number $buildNumber --build-name 1.$buildNumber
