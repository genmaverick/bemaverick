
today=`date '+%Y-%m-%d %H:%M:%S'`
yesterday=`date -v-1d '+%Y-%m-%d %H:%M:%S'`
echo 'today' $today
echo 'yesterday' $yesterday
git --no-pager log --since yesterday --pretty=format:"%an%x09%s%n" > gitLog.txt

echo -e "Built: $today\n\n$(cat gitLog.txt)" > gitLog.txt

cd ..
plist="$PWD/SupportingFiles/Info-production.plist"
extensionPlist="$PWD/notifications/Info.plist"
messagesPlist="$PWD/Messages/messages-Info.plist"
pListBuddy="/usr/libexec/PlistBuddy"
mainCommit=$(git rev-parse HEAD)
$pListBuddy -c "Add :mainCommit string $mainCommit" "$plist"
$pListBuddy -c "Set :mainCommit $mainCommit" "$plist"

plist="$PWD/SupportingFiles/Info-development.plist"
pListBuddy="/usr/libexec/PlistBuddy"
mainCommit=$(git rev-parse HEAD)
$pListBuddy -c "Add :mainCommit string $mainCommit" "$plist"
$pListBuddy -c "Set :mainCommit $mainCommit" "$plist"

buildVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $plist)
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBuildNumber" $plist)
shortVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $plist)

$pListBuddy -c "Set :CFBundleVersion $buildVersion" "$extensionPlist"
$pListBuddy -c "Set :CFBuildNumber $buildNumber" "$extensionPlist"
$pListBuddy -c "Set :CFBundleShortVersionString $shortVersion" "$extensionPlist"


$pListBuddy -c "Set :CFBundleVersion $buildVersion" "$messagesPlist"
$pListBuddy -c "Set :CFBuildNumber $buildNumber" "$messagesPlist"
$pListBuddy -c "Set :CFBundleShortVersionString $shortVersion" "$messagesPlist"



