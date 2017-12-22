' Set User Rights

Set oShell = WScript.CreateObject("WScript.Shell")
oShell.Run "%comspec% /c ntrights.exe /? > SvcAccountRights.log", 1, True
oShell.Run "%comspec% /c ntrights.exe -u TFSREPORTS +r SeInteractiveLogonRight >> SvcAccountRights.log", 1, True
oShell.Run "%comspec% /c ntrights.exe -u TFSSERVICE +r SeServiceLogonRight >> SvcAccountRights.log", 1, True
oShell.Run "%comspec% /c ntrights.exe -u TFSBUILD +r SeServiceLogonRight >> SvcAccountRights.log", 1, True

' Done

msgbox "TFS Service Accounts permissions assigned"
Wscript.quit
