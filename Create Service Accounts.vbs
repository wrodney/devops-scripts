Dim objNetwork
Dim objComputer

Const PASSWORD = "password"
Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000

' Get Computer

Set objNetwork = CreateObject("WScript.Network")
Set objComputer = GetObject("WinNT://" + objNetwork.ComputerName)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Create service accounts
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Create Account(s)

CreateAccount "TFSSERVICE","TFS Service Account"
CreateAccount "TFSBUILD","TFS Build Service Account"
CreateAccount "WSSSERVICE","WSS Service Account"
CreateAccount "TFSREPORTS","TFS Reporting Account"

' Done

Set objComputer = Nothing
Set objNetwork  = Nothing
msgbox "TFS Service Accounts created!"
Wscript.quit


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Subroutines

sub CreateAccount (User,FullName)

  ' Drop first

  on error resume next
  objComputer.Delete "User",User
  on error goto 0

  ' Add User

  set objUser = objComputer.Create("User",User)
  objUser.SetInfo
  objUser.FullName = FullName
  objUser.Description = FullName
  objUser.SetPassword PASSWORD

  ' Set Password so it doesn't expire

  lngUF = objUser.Get("userFlags")
  lngUF = lngUF Or ADS_UF_DONT_EXPIRE_PASSWD
  objUser.Put "userFlags", lngUF

  ' Activate the above settings
  
  objUser.SetInfo
End Sub