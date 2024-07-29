# PowerShell Script to Export Organizational Units (OUs) from Active Directory

This PowerShell script exports a list of Organizational Units (OUs) from an Active Directory environment, excluding the "Domain Controllers" OU, and saves the information to a CSV file.

## Script Explanation

### Define the Output Path

```powershell
$outputPath = "C:\Users\pponnan\Desktop\PowershellLearning\OUsList25.csv"
```
Sets the file path where the CSV output will be saved.
## Function to Convert AD DateTime Property to String
  ```powershell
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
```
Defines a function to convert the AD DateTime property to a readable string format.
## Define the Properties to Retrieve
```powershell
$properties = @(
    'Name', 'Description', 'Created', 'Modified', 'CanonicalName', 'gPLink', 'DistinguishedName', 'ObjectGUID', 'ProtectedFromAccidentalDeletion'
)
```
Specifies the list of properties to retrieve for each OU.
## Get the List of OUs

```powershell
$OUs = Get-ADOrganizationalUnit -Filter * -Properties $properties | Where-Object { $_.Name -ne "Domain Controllers" }
```
Retrieves all OUs from Active Directory and filters out the “Domain Controllers” OU.
## Select the Required Properties

```powershell

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
```
Selects and formats the desired properties for output.
ParentOU is calculated by removing the initial part of the DistinguishedName.
Dates are converted to string format using the Convert-ADDateTimeToString function.
    
##Export the List to a CSV File
```powershell
$selectedOUs | Export-Csv -Path $outputPath -NoTypeInformation
```
Exports the selected properties of the OUs to a CSV file.
##Completion Message
```powershell
Write-Host "Export completed. The list of OUs has been saved to $outputPath"
```
This script can be run in a PowerShell session with appropriate permissions to access Active Directory. Make sure to update the `$outputPath` variable to the desired output file path on your system.
