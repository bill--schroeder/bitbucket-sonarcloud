REM https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/sonarscanner-for-net/

  
SET PATH=%PATH%;C:\Apps\SonarScanner\sonar-scanner-msbuild-5.5.3.43281-net46\;"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\"

SonarScanner.MSBuild.exe begin /k:"product_key" /d:"sonar.login=${SONAR_TOKEN}" /o:"organization_key" /v:"${BITBUCKET_COMMIT}" /d:"sonar.host.url=https://sonarcloud.io"

MSBuild.exe <path to solution.sln> /t:Rebuild

SonarScanner.MSBuild.exe end /d:sonar.login="${SONAR_TOKEN}"
