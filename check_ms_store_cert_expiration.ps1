# TODO get sure that if any command fails in an unexpected way, the full script ends with a non-zero status.
# TODO check the possibility to use NSClient++ scripts\\lib\\wrapper.vbs and/or scripts\\lib\\NagiosPlugins.vbs.
$Thumbprint=$args[0]
# TODO validate coherence of the following arguments, i.e. $CriticalThresholdInDays shouldn't be larger than $WarningThresholdInDays.
$WarningThresholdInDays=$args[1]
$CriticalThresholdInDays=$args[2]
# TODO allow to specify the certificate store (machine or user) or even the folder...
$MatchingCertificate = Get-ChildItem -Path Cert:\LocalMachine\My | where {$_.Thumbprint -eq $Thumbprint}
If ($MatchingCertificate -eq $null){
Write-Host ("CRITICAL: Certificate not found with provided fingerprint.")
Exit 2
}
$Now = Get-Date
# TODO check the details of the following time related logic.
$TimeSpanUntilExpiration = New-TimeSpan -Start $Now -End $MatchingCertificate.NotAfter
$Message = ($MatchingCertificate.Subject + " (Thumbprint: "+ $Thumbprint +") will expire in " + $TimeSpanUntilExpiration.Days + " days.")
If ($TimeSpanUntilExpiration.TotalDays -ge $WarningThresholdInDays){
Write-Host ("OK: " + $Message)
Exit 0
} ElseIf ($TimeSpanUntilExpiration.TotalDays -ge $CriticalThresholdInDays){
Write-Host ("WARNING: " + $Message)
Exit 1
} Else {
Write-Host ("CRITICAL: " + $Message)
Exit 2
}
