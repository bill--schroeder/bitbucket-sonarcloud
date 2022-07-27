
$sourcePath = "c:\Workspaces\bitbucket"
$destinationPath = "c:\Workspaces\SonarScanner"


Write-Host "Copying folders & files ..."
Remove-Item -LiteralPath $destinationPath -Force -Recurse
Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse


# Prepare the files for code scanning
Write-Host "Preparing files ..."
Get-ChildItem $sourcePath -Recurse | ? { $_.Extension -like ".cs" } | % `
{
   # get the source file and path
   $file = $_.PSPath.Split(":", 3)[2]
   Write-Host $file

   $destinationFile = [Regex]::Replace(`
     $file, `
     [regex]::Escape($sourcePath), `
     $destinationPath, `
     [System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
   Write-Host $destinationFile
   Write-Host ""

   # get the contents of the file
   $text = Get-Content $file -Encoding UTF8

   $containsWord = $text | %{$_ -match " All rights reserved."}
   if ($containsWord -contains $true) 
   {
      # remove the copyright lines at the top of the file
      $text = Get-Content $file | select -Skip 6
   }

   $destinationFolder = [System.IO.Path]::GetDirectoryName($destinationFile)
   New-Item -Path $destinationFolder -ItemType "directory" -Force

   Out-File -FilePath $destinationFile -Encoding UTF8 -InputObject $text
}


# Scan the code

$sonarScannerPath = "C:\Apps\SonarScanner\sonar-scanner-msbuild-5.7.1.49528-net46\"
If ($Env:PATH -notlike "*" + $sonarScannerPath + "*")
{
    $Env:PATH += ";" + $sonarScannerPath
}
$javaPath = "C:\Apps\SonarScanner\jdk\"
If ($Env:PATH -notlike "*" + $javaPath + "*")
{
    $Env:PATH += ";" + $javaPath
}
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath)

$openCoverPath = "C:\Apps\SonarScanner\opencover.4.7.1221\"
If ($Env:PATH -notlike "*" + $openCoverPath + "*")
{
    $Env:PATH += ";" + $openCoverPath
}

$vsbasePath = "C:\Program Files\Microsoft Visual Studio\2022\Community"
$msbuildPath = $vsbasePath + "\MSBuild\Current\Bin\"
If ($Env:PATH -notlike "*" + $msbuildPath + "*")
{
    $Env:PATH += ";" + $msbuildPath
}
$vstestPath = $vsbasePath + "\Common7\IDE\CommonExtensions\Microsoft\TestWindow\"
If ($Env:PATH -notlike "*" + $vstestPath + "*")
{
    $Env:PATH += ";" + $vstestPath
}

#Write-Host $Env:PATH


#$codeCoverageExe = "CodeCoverage.exe"
$codeCoverageExe = "OpenCover.Console.exe"


$SONAR_TOKEN = "SONAR_TOKEN"

$BUILD_SOLUTION = $destinationPath + "\Projects.sln"
Write-Host "BUILD_SOLUTION: " $BUILD_SOLUTION


$testResultsPath = $destinationPath + "\TestResults\"
#Write-Host "testResultsPath: " $testResultsPath
New-Item -ItemType "directory" -Path $testResultsPath
$vscoveragexml = $testResultsPath + "**.xml"
$reportsPaths = $testResultsPath + "**.trx"


SonarScanner.MSBuild.exe begin /k:"product_key" /o:"organization_key" /d:sonar.login=$SONAR_TOKEN /d:sonar.sourceEncoding="UTF-8" /d:sonar.inclusions="**/*.cs" /d:sonar.exclusions="**/*.Attributes.cs,**/AssemblyInfo.cs" /d:sonar.cs.opencover.reportsPaths=$vscoveragexml /d:"sonar.host.url=https://sonarcloud.io"


MSBuild.exe /t:Rebuild /p:Configuration=Debug /consoleloggerparameters:ErrorsOnly $BUILD_SOLUTION



Write-Host " "
Write-Host "Running code coverage"

$files = ""
Get-ChildItem $destinationPath -Recurse | ? { $_.DirectoryName -like "*\bin\*" } | ? { $_.Name -like "*.tests.dll" } | % `
{
   # get the source file and path
   $file = $_.PSPath.Split(":", 3)[2]
   Write-Host "Tests: " $file

   &$codeCoverageExe  -target:"vstest.console.exe" -targetargs:$file -output:$testResultsPath"\"$_".CoverageResults.xml"

   $files += "'" + $file + "' "
}

Get-ChildItem $destinationPath -Recurse | ? { $_.DirectoryName -like "*\bin\*" } | ? { $_.Name -like "*.test.dll" } | % `
{
   # get the file and path
   $file = $_.PSPath.Split(":", 3)[2]
   Write-Host "Test: " $file

   &$codeCoverageExe  -target:"vstest.console.exe" -targetargs:$file -output:$testResultsPath"\"$_".CoverageResults.xml"

   $files += "'" + $file + "' "
}

#Write-Host "Test Files: " $files
#vstest.console.exe $file /Logger:trx /ResultsDirectory:$testResultsPath


SonarScanner.MSBuild.exe end /d:sonar.login=$SONAR_TOKEN
