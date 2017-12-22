<#
Psake and GUI

We will create GUI in .NET WinForms. Remember, this is just a sample that will show you that it is possible. 
So, the code will be as concise as possible.
PowerShell has to be run with -STA switch.


#>


Add-type -assembly System.Windows.Forms
Add-type -assembly System.Drawing
if (! (get-module psake)) {
  sl D:\temp\psake\JamesKovacs-psake-b0094de\
  ipmo .\psake.psm1
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Build'
$form.ClientSize = New-Object System.Drawing.Size 70,100

('build',10), ('test',30), ('out', 50) | % { 
  $cb = new-object Windows.Forms.CheckBox
  $cb.Text = $_[0]
  $cb.Size = New-Object System.Drawing.Size 60,20
  $cb.Location = New-Object System.Drawing.Point 10,$_[1]
  $form.Controls.Add($cb)
  Set-Item variable:\cb$($_[0]) -value $cb
}
$go = New-Object System.Windows.Forms.Button
$go.Text = "Run!"
$go.Size = New-Object System.Drawing.Size 60,20
$go.Location = New-Object System.Drawing.Point 10,70
$go.add_Click({
  $form.Close()
  if ($cbbuild.Checked) { $script:tasks += 'Rebuild' }
  if ($cbtest.Checked) { $script:tasks += 'Test' }
  if ($cbout.Checked) { $script:tasks += 'Out' }
})
$form.Controls.Add($go)

$script:tasks = @()
$form.ShowDialog() | Out-Null
if ($script:tasks) {
  Invoke-psake -buildFile d:\temp\psake\psake-devbuild.ps1 -task $tasks
}