# configure the powershell to run only signed scripts
Set-ExecutionPolicy -ExecutionPolicy:'AllSigned' -Scope:'Process' -Confirm:$false

./popup.ps1;

$certification = Get-ChildItem -Path