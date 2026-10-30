$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $PSScriptRoot
$env:PUB_CACHE = 'E:\DEPI\flutter_pub_cache'
$env:JAVA_HOME = 'E:\App\android-studio\New folder\jbr'
$env:TEMP = 'C:\jtmp'
$env:TMP = 'C:\jtmp'
$env:GRADLE_USER_HOME = 'C:\Users\CompuMarts\.gradle'
$env:Path = "$env:JAVA_HOME\bin;E:\App\android-studio\android-sdk\platform-tools;$env:Path"

Push-Location $project
try {
  flutter devices
  flutter run -d emulator-5554 --no-pub
}
finally {
  Pop-Location
}
