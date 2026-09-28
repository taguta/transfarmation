# Transfarmation app inventory
# Run in PowerShell:  powershell -ExecutionPolicy Bypass -File .\app_inventory.ps1
# Read-only: it only reads your project and writes one text file. Review the output before sharing it.
param(
  [string]$Root = "C:\Flutter_Projects\transfarmation",
  [string]$Out  = "C:\Flutter_Projects\transfarmation\docs\Transafarmation_brd_latest\06_App_Comparison\app_inventory.txt"
)
$ErrorActionPreference = 'SilentlyContinue'
New-Item -ItemType Directory -Force -Path (Split-Path $Out) | Out-Null
$sb = New-Object System.Text.StringBuilder
function Add-Line($t) { [void]$sb.AppendLine($t) }
function Add-Section($t) { Add-Line ""; Add-Line ("=" * 70); Add-Line $t; Add-Line ("=" * 70) }

Add-Section "GENERATED"
Add-Line (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Line "Root: $Root"

Add-Section "PUBSPEC (name, sdk, dependencies)"
Add-Line (Get-Content "$Root\pubspec.yaml" -Raw)

$dart = Get-ChildItem "$Root\lib" -Filter *.dart -Recurse -File
Add-Section "DART SIZE"
Add-Line ("Dart files in lib: {0}" -f $dart.Count)
$lines = 0; foreach ($f in $dart) { $lines += (Get-Content $f.FullName | Measure-Object -Line).Lines }
Add-Line ("Total lines in lib: {0}" -f $lines)
$tests = Get-ChildItem "$Root\test" -Filter *_test.dart -Recurse -File
Add-Line ("Test files: {0}" -f $tests.Count)

Add-Section "LIB FOLDER TREE (depth 3, with dart file counts)"
Get-ChildItem "$Root\lib" -Directory -Recurse -Depth 2 | ForEach-Object {
  $rel = $_.FullName.Substring($Root.Length + 1)
  $n = (Get-ChildItem $_.FullName -Filter *.dart -File).Count
  Add-Line ("{0}  ({1} dart files)" -f $rel, $n)
}

Add-Section "STATE MANAGEMENT SIGNALS (match counts)"
$signals = [ordered]@{
  "GetxController / Get.put / Get.find" = "GetxController|Get\.put|Get\.find|Get\.lazyPut"
  "Bloc / Cubit"                         = "extends Bloc|extends Cubit|BlocProvider"
  "Riverpod"                             = "ConsumerWidget|ref\.watch|ProviderScope"
  "Provider / ChangeNotifier"            = "ChangeNotifier|ChangeNotifierProvider|context\.watch"
}
foreach ($k in $signals.Keys) {
  $c = ($dart | Select-String -Pattern $signals[$k] | Measure-Object).Count
  Add-Line ("{0}: {1}" -f $k, $c)
}

Add-Section "FIREBASE AND BACKEND SIGNALS (match counts)"
$fb = [ordered]@{
  "FirebaseFirestore"     = "FirebaseFirestore"
  "FirebaseAuth"          = "FirebaseAuth"
  "cloud_functions call"  = "FirebaseFunctions|httpsCallable"
  "Firebase Storage"      = "FirebaseStorage"
  "App Check"             = "FirebaseAppCheck"
  "Firebase Messaging"    = "FirebaseMessaging"
  "snapshots() listeners" = "\.snapshots\("
  "runTransaction"        = "runTransaction"
  "Supabase"              = "Supabase|supabase"
  "sqflite / drift / isar / hive" = "sqflite|drift|isar|hive"
}
foreach ($k in $fb.Keys) {
  $c = ($dart | Select-String -Pattern $fb[$k] | Measure-Object).Count
  Add-Line ("{0}: {1}" -f $k, $c)
}

Add-Section "FIRESTORE COLLECTION NAMES USED IN CODE"
$pattern = "collection\(\s*['""]([^'""]+)['""]"
$cols = $dart | Select-String -Pattern $pattern -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$cols | ForEach-Object { Add-Line $_ }

Add-Section "ROUTES (named routes found)"
$routes = $dart | Select-String -Pattern "name:\s*['""](/[^'""]*)['""]|['""](/[a-zA-Z0-9_/\-]+)['""]\s*:\s*\(" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Sort-Object -Unique
$routes | Select-Object -First 150 | ForEach-Object { Add-Line $_ }

Add-Section "MODELS AND SERVICES (file names)"
Get-ChildItem "$Root\lib" -Recurse -File -Include "*model*.dart","*service*.dart","*repository*.dart","*controller*.dart" |
  ForEach-Object { Add-Line ($_.FullName.Substring($Root.Length + 1)) }

Add-Section "LOCALISATION"
Add-Line ("l10n / translations files: {0}" -f (Get-ChildItem "$Root" -Recurse -Include "*.arb","*translations*.dart" -File | Where-Object { $_.FullName -notmatch "\\build\\|\\.dart_tool\\" } | Measure-Object).Count)
Add-Line ("Mentions of Shona / Ndebele / 'sn' / 'nd' locale: {0}" -f (($dart | Select-String -Pattern "Shona|Ndebele|Locale\('sn'|Locale\('nd'" | Measure-Object).Count))

Add-Section "BACKEND FILES PRESENT"
foreach ($p in @("firebase.json","firestore.rules","firestore.indexes.json","storage.rules","functions","supabase","docs")) {
  Add-Line ("{0}: {1}" -f $p, (Test-Path "$Root\$p"))
}

Add-Section "FIRESTORE RULES (first 200 lines)"
if (Test-Path "$Root\firestore.rules") { Get-Content "$Root\firestore.rules" -TotalCount 200 | ForEach-Object { Add-Line $_ } }

Add-Section "CLOUD FUNCTIONS (exported names)"
if (Test-Path "$Root\functions") {
  Get-ChildItem "$Root\functions" -Recurse -Include "*.ts","*.js" -File | Where-Object { $_.FullName -notmatch "node_modules|\\lib\\" } |
    Select-String -Pattern "export (const|async function|function) (\w+)" -AllMatches |
    ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Sort-Object -Unique | ForEach-Object { Add-Line $_ }
}

Add-Section "GIT (last 20 commits)"
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) { git -C $Root log --oneline -n 20 | ForEach-Object { Add-Line $_ } }

$sb.ToString() | Out-File -FilePath $Out -Encoding utf8
Write-Host "Wrote $Out"
