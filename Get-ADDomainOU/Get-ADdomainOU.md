
# Get-ADDomainAllOUs.ps1 Script Explanation

## Overview

This PowerShell script retrieves information about Active Directory Organizational Units (OUs) based on various filters and options. It supports filtering by creation and modification dates, checking for empty OUs, and scanning all OUs in the domain.

## Author

- **Author:** Prabu Ponnan
- **Version:** 1.0
- **Date:** August 1, 2024

## Parameters

- **Filter:** Specifies the LDAP filter to use for retrieving OUs. Default is 'OU=*'.
- **OneLevel:** Limits the search to one level.
- **AllSubOU:** Searches all sub-OUs.
- **Created:** Filters OUs created within the last X days.
- **Modified:** Filters OUs modified within the last X days.
- **Domain:** Scans all OUs in the domain.
- **Empty:** Filters and retrieves only empty OUs.

## Functions

### Convert-ADDateTimeToString

This function converts AD DateTime properties to string format.

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

### CalculateDaysAgo

This function calculates the number of days ago a date occurred.

```powershell
function CalculateDaysAgo {
    param (
        [DateTime]$date
    )
    if ($date -ne $null) {
        return (New-TimeSpan -Start $date -End (Get-Date)).Days
    } else {
        return $null
    }
}
```

## Main Script

### Folder Check and Creation

Checks if the folder `C:\PowershellReports` exists and creates it if not.

```powershell
$folderPath = "C:\PowershellReports"

if (-Not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
    Write-Output "Folder created: $folderPath"
} else {
    Write-Output "Folder already exists: $folderPath"
}
```

### CSV Output Path

Generates a filename based on the current date and time.

```powershell
$currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss_tt"
$outputPath = "$folderPath\OUdetails_$currentDateTime.csv"
```

### Search Scope

Sets the search scope based on the `OneLevel` and `AllSubOU` switches.

```powershell
$searchScope = if ($OneLevel) {
    'OneLevel'
} elseif ($AllSubOU) {
    'Subtree'
} else {
    'Subtree'
}
```

### Properties to Retrieve

Defines the properties to retrieve from Active Directory.

```powershell
$properties = @(
    'Name', 'Description', 'Created', 'Modified', 'CanonicalName', 'gPLink', 'DistinguishedName', 'ObjectGUID', 'ProtectedFromAccidentalDeletion'
)
```

### LDAP Filter

Builds the LDAP filter based on creation and modification dates.

```powershell
$ldapFilter = "(objectClass=organizationalUnit)"
if ($Created) {
    $createdDate = (Get-Date).AddDays(-$Created)
    $ldapFilter = "(&($ldapFilter)(whenCreated>=$($createdDate.ToString('yyyyMMddHHmmss.0Z'))))"
}
if ($Modified) {
    $modifiedDate = (Get-Date).AddDays(-$Modified)
    $ldapFilter = "(&($ldapFilter)(whenChanged>=$($modifiedDate.ToString('yyyyMMddHHmmss.0Z'))))"
}
```

### Base Distinguished Name

Gets the base distinguished name based on the `Domain` switch.

```powershell
$baseDN = if ($Domain) {
    (Get-ADDomain).DistinguishedName
} else {
    (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$Filter)").DistinguishedName
}
```

### Retrieve OUs

Retrieves the list of OUs based on the specified filters and search scope.

```powershell
$OUs = Get-ADOrganizationalUnit -LDAPFilter $ldapFilter -SearchBase $baseDN -SearchScope $searchScope -Properties $properties | Where-Object { $_.Name -ne "Domain Controllers" }
```

### Filter Empty OUs

Filters out empty OUs if the `-Empty` switch is used.

```powershell
if ($Empty) {
    $OUs = $OUs | Where-Object {
        (Get-ADObject -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count -eq 0
    }
}
```

### Select Required Properties

Selects the required properties for the final output.

```powershell
$selectedOUs = $OUs | Select-Object Name,
                                @{Name='ParentOU'; Expression={($_.DistinguishedName -replace '^OU=[^,]+,', '')}},
                                DistinguishedName,
                                @{Name="Created"; Expression={Convert-ADDateTimeToString $_.Created}},
                                @{Name="Modified"; Expression={Convert-ADDateTimeToString $_.Modified}},
                                @{Name="Created Days Ago"; Expression={CalculateDaysAgo $_.Created}},
                                @{Name="Modified Days Ago"; Expression={CalculateDaysAgo $_.Modified}},
                                CanonicalName,
                                Description,
                                ObjectGUID,
                                ProtectedFromAccidentalDeletion,
                                gPLink
```

### Export to CSV

Exports the list of OUs to a CSV file.

```powershell
$selectedOUs | Export-Csv -Path $outputPath -NoTypeInformation -Encoding utf8

Write-Host "Export completed. The list of OUs has been saved to $outputPath"
```

## Example Usages

1. **Retrieve only direct sub-organizational units:**
   ```powershell
   Get-ADDomainOU -Filter "OU=TestLab,DC=TestLab,DC=Local" -OneLevel
   ```

2. **Retrieve all sub-organizational units:**
   ```powershell
   Get-ADDomainOU -Filter "OU=TestLab,DC=TestLab,DC=Local" -AllSubOU
   ```

3. **Retrieve OUs created in the last 30 days:**
   ```powershell
   Get-ADDomainOU -Created 30 -Domain
   ```
   
4. **Retrieve OUs modified in the last 15 days:**
   ```powershell
   Get-ADDomainOU -Modified 15 -Domain
   ```

5. **Retrieve all empty OUs in the domain:**
   ```powershell
   Get-ADDomainOU -Domain -Empty
   ```

6. **Retrieve all OUs in the domain:**
   ```powershell
   Get-ADDomainOU -Domain
   ```
