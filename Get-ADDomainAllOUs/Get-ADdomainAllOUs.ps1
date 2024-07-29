 # Define the output path for the CSV file
 $outputPath = "C:\Users\pponnan\Desktop\PowershellLearning\OUsList25.csv"

 # Function to convert AD DateTime property to string
 function Convert-ADDateTimeToString {
     param (
         [Microsoft.ActiveDirectory.Management.ADPropertyValueCollection]$adDateTime
     )
     if ($adDateTime -ne $null -and $adDateTime.Count -gt 0) {
         return [DateTime]$adDateTime[0]
     } else {
         return $null
     }
 }
 
 # Define the properties to retrieve
 $properties = @(
     'Name', 'Description', 'Created', 'Modified', 'CanonicalName', 'gPLink', 'DistinguishedName', 'ObjectGUID', 'ProtectedFromAccidentalDeletion'
 )
 
 # Get the list of OUs
 $OUs = Get-ADOrganizationalUnit -Filter * -Properties $properties | Where-Object { $_.Name -ne "Domain Controllers" }
 
 # Select the required properties
 $selectedOUs = $OUs | Select-Object Name, 
                                     @{Name='ParentOU'; Expression={($_.DistinguishedName -replace '^OU=[^,]+,', '')}}, 
                                     DistinguishedName, 
                                     @{Name="Created"; Expression={Convert-ADDateTimeToString $_.Created}}, 
                                     @{Name="Modified"; Expression={Convert-ADDateTimeToString $_.Modified}}, 
                                     CanonicalName, 
                                     Description, 
                                     ObjectGUID, 
                                     ProtectedFromAccidentalDeletion, 
                                     gPLink
 
 # Export the list to a CSV file
 $selectedOUs | Export-Csv -Path $outputPath -NoTypeInformation
 
 Write-Host "Export completed. The list of OUs has been saved to $outputPath" 
 