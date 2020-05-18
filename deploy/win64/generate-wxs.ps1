
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$redist_parent_dir = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\"

$redists = (Get-ChildItem -Path $redist_parent_dir -Name -Include 14.* -Attributes Directory)

if (!$redists) {
    echo "ERROR: No 14.x redistributable directories found under $redist_parent_dir"
    exit 1
}

$redist_ver = $redists[-1]

$version = (Get-Content version.h) -replace '#define SV_VERSION ','' -replace '"','' -replace '-pre.*',''
$wxs = "deploy\win64\sonic-visualiser.wxs"

$in = "$wxs.in"

$redist_dir="$redist_parent_dir\$redist_ver\x64\Microsoft.VC142.CRT"

echo "Generating $wxs..."
echo " ...for SV version $version"
echo " ...for redist version $redist_ver"
echo " ...from $in"
echo ""

if (!(Test-Path -Path $redist_dir -PathType Container)) {
    echo "ERROR: Redistributable directory $redist_dir not found"
    exit 1
}

if (!(Test-Path -Path $in -PathType Leaf)) {
    echo "ERROR: Input file $in not found"
    exit 1
}

(Get-Content $in) -replace '@VERSION@', $version -replace '@REDIST_VER@', $redist_ver -replace '@W@', '<!-- DO NOT EDIT THIS FILE: it is auto-generated -->' | Out-File -encoding ASCII $wxs

echo "Done"
