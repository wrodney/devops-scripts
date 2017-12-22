@ECHO OFF

FOR /l %%i in (393,1,453) DO tools\nuget delete Diligent.Research.Web.Core 0.3.0.%%i -Source http://artifactory-clt.devtms.local:8081/artifactory/api/nuget/research-nuget-local -NonInteractive -Verbosity detailed



