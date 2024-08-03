<#
.SYNOPSIS
    Script to retrieve information about Active Directory Organizational Units (OUs).

.DESCRIPTION
    This script retrieves details about Active Directory OUs based on various filters and options.
    It supports filtering by creation and modification dates, checking for empty OUs.

.PARAMETER Filter
    Specifies the LDAP filter to use for retrieving OUs. Default is 'OU=*'.

.PARAMETER OneLevel
    Limits the search to one level.

.PARAMETER AllSubOU
    Searches all sub-OUs.

.PARAMETER Created
    Filters OUs created within the last X days.

.PARAMETER Modified
    Filters OUs modified within the last X days.

.PARAMETER Domain
    Scans all OUs in the domain.

.PARAMETER Empty
    Filters and retrieves only empty OUs.

.NOTES
    Author: Prabu Ponnan
    Version: 1.0
    Date: August 1, 2024

.EXAMPLE
    Get-ADDomainOU -Filter "OU=TestLab,DC=xyz,DC=domain,DC=net" -OneLevel

.EXAMPLE
    Get-ADDomainOU -Filter "OU=TestLab,DC=xyz,DC=domain,DC=net" -AllSubOU

.EXAMPLE
    Get-ADDomainOU -Created 30 -Domain

.EXAMPLE
    Get-ADDomain -Modified 15 -Domain

.EXAMPLE
    Get-ADDomainOU -Domain -Empty

.EXAMPLE
    Get-ADDomainOU -Domain
#>

# Define the Get-ADDomainOU function
function Get-ADDomainOU {
    param (
        [string]$Filter = 'OU=*',
        [switch]$OneLevel,
        [switch]$AllSubOU,
        [int]$Created,
        [int]$Modified,
        [switch]$Domain,
        [switch]$Empty
    )

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

    # Function to calculate days ago
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

    # Define the folder path
    $folderPath = "C:\PowershellReports"

    # Check if the folder exists
    if (-Not (Test-Path -Path $folderPath)) {
        # If the folder does not exist, create it
        New-Item -ItemType Directory -Path $folderPath
        Write-Output "Folder created: $folderPath"
    } else {
        # If the folder already exists, inform the user
        Write-Output "Folder already exists: $folderPath"
    }

    # Get the current date and time
    $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss_tt"

    # Define the output path for the CSV file
    $outputPath = "$folderPath\OUdetails_$currentDateTime.csv"

    # Define the search scope
    $searchScope = if ($OneLevel) {
        'OneLevel'
    } elseif ($AllSubOU) {
        'Subtree'
    } else {
        'Subtree'
    }

    # Define the properties to retrieve
    $properties = @(
        'Name', 'Description', 'Created', 'Modified', 'CanonicalName', 'gPLink', 'DistinguishedName', 'ObjectGUID', 'ProtectedFromAccidentalDeletion'
    )

    # Build the LDAP filter
    $ldapFilter = "(objectClass=organizationalUnit)"
    if ($Created) {
        $createdDate = (Get-Date).AddDays(-$Created)
        $ldapFilter = "(&($ldapFilter)(whenCreated>=$($createdDate.ToString('yyyyMMddHHmmss.0Z'))))"
    }
    if ($Modified) {
        $modifiedDate = (Get-Date).AddDays(-$Modified)
        $ldapFilter = "(&($ldapFilter)(whenChanged>=$($modifiedDate.ToString('yyyyMMddHHmmss.0Z'))))"
    }

    # Get the base distinguished name
    $baseDN = if ($Domain) {
        (Get-ADDomain).DistinguishedName
    } else {
        (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$Filter)").DistinguishedName
    }

    # Get the list of OUs
    $OUs = Get-ADOrganizationalUnit -LDAPFilter $ldapFilter -SearchBase $baseDN -SearchScope $searchScope -Properties $properties | Where-Object { $_.Name -ne "Domain Controllers" }

    # Filter out empty OUs if the -Empty switch is used
    if ($Empty) {
        $OUs = $OUs | Where-Object {
            (Get-ADObject -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count -eq 0
        }
    }

    # Select the required properties
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

    # Export the list to a CSV file
    $selectedOUs | Export-Csv -Path $outputPath -NoTypeInformation -Encoding utf8

    Write-Host "Export completed. The list of OUs has been saved to $outputPath"
}

# Example usage
# Get-ADDomainOU -Filter "OU=TestLab,DC=TestLab,DC=Local" -OneLevel
# Get-ADDomainOU -Filter "OU=TestLab,DC=TestLab,DC=Local" -AllSubOU
# Get-ADDomainOU -Created 30 -Domain
# Get-ADDomainOU -Modified 15 -Domain
# Get-ADDomainOU -Domain -Empty
# Get-ADDomainOU -Domain
