# sonarcloud

SonarCloud will review code quality and security.  The security scan and results are based on OWASP, SANS, and CWE recommendations.
Scans can be configured to look for and/or ignore certain files.  They can also look at code based on previous version, day(s), or specific date.
Scan results can be automatically or manually assigned to individuals.
SonarScanner is the application used to scan .Net code.

A dashboard Summary will show the results after a scan has successfully completed.  This also allows quick access to view those items impacted in each area.

•	Reliability – a coding error that will break your code and needs to be fixed immediately

•	Maintainability – code that is confusing and difficult to maintain

•	Security – code that can be exploited by hackers

•	Security Review – security-sensitive code that needs manual review to assess whether a vulnerability exists

•	Coverage – the amount of unit tests covering the code

•	Duplications – the amount of duplicate code


### Setup Bitbucket Pipelines
https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/bitbucket-pipelines/

### Setup SonarScanner command line
https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/sonarscanner-for-net/

### Setup SonarScanner Test Coverage
https://docs.sonarqube.org/latest/analysis/test-coverage/dotnet-test-coverage/

### Setup OpenCover command line
https://www.apriorit.com/dev-blog/697-qa-measuring-code-coverage
