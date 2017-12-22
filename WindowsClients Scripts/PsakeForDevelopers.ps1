<#
Psake for developers

I have been writing about psake only in general terms, but I mentioned almost everything what you will need for some automation tasks. 
There is something more for programmers. The best feature is function exec, which terminates the psake script in case that application called inside exec finishes with error.
The error is indicated by a return code. Body of exec is very simple, let's look at it with Get-Content function:\exec.

Task that builds solution is almost one liner when you use exec:
#>


$framework = '4.0' 
...
task Build { 
  exec { msbuild $slnPath '/t:Build' }
}