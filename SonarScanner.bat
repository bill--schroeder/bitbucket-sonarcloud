REM https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/sonarscanner-for-net/
REM https://docs.sonarqube.org/latest/user-guide/user-token/

  
SET PATH=%PATH%;C:\Apps\SonarScanner\sonar-scanner-msbuild-5.5.3.43281-net46\
SET PATH=%PATH%;"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\"

SET JAVA_HOME=C:\Apps\SonarScanner\jdk\
SET SONAR_TOKEN="${SONAR_TOKEN}"

SET BUILD_SOLUTION=%1


SonarScanner.MSBuild.exe begin /k:"product_key" /d:sonar.login=%SONAR_TOKEN% /o:"organization_key" /d:"sonar.host.url=https://sonarcloud.io"

REM MSBuild.exe <path to solution.sln or project> /t:Rebuild
MSBuild.exe %BUILD_SOLUTION%

SonarScanner.MSBuild.exe end /d:sonar.login=%SONAR_TOKEN%
