
# PowerShell Script to Export Active Directory Users

This PowerShell script exports all Active Directory (AD) users in the domain with specified properties. It formats the output for readability and usability, including detailed properties for each user.

## Properties Included

The script retrieves the following properties for each user:
- Name
- Account Is Locked Out
- City
- Company
- Country
- Creation Date
- Department
- Description
- Account Status
- Display Name
- Division
- Email Address
- Employee ID
- Expiration Date
- First Name
- Initials
- Job Title
- Last Lock Out Date
- Last Name
- Manager
- Mobile Phone Number
- Modification Date
- Must Change Password At Next Logon
- Notes
- Office
- Parent Container
- Password Age (Days)
- Password Expiration Date
- Password Last Changed
- Password Never Expires
- Password Not Required
- Telephone Number
- Username
- Username (pre 2000)
- Distinguished Name (excluding the CN part)
- Member Of (formatted as a comma-separated list of group names)

## Script Details

### Properties Variable

The `$properties` variable defines the list of properties to be retrieved for each user.

```powershell
$properties = @(
    'Name', 'AccountLockoutTime', 'City', 'Company', 'Country', 'whenCreated', 'Department', 'Description', 'Enabled', 
    'DisplayName', 'Division', 'EmailAddress', 'EmployeeID', 'accountExpires', 'GivenName', 'Initials', 'Title', 'LockedOut', 
    'Surname', 'Manager', 'MobilePhone', 'whenChanged', 'PasswordExpired', 'info', 'PhysicalDeliveryOfficeName', 'CanonicalName', 
    'PasswordLastSet', 'PasswordNeverExpires', 'PasswordNotRequired', 'TelephoneNumber', 'SamAccountName', 'userPrincipalName', 
    'distinguishedName', 'MemberOf'
)
```

### Select-Object Properties

The `$global:selectProperties` variable defines how each property should be displayed, including any custom formatting required.

```powershell
$global:selectProperties = @(
    @{Name='Name'; Expression={$_.Name}}, 
    @{Name='Account Is Locked Out'; Expression={$_.AccountLockoutTime}}, 
    @{Name='City'; Expression={$_.City}}, 
    @{Name='Company'; Expression={$_.Company}}, 
    @{Name='Country'; Expression={$_.Country}}, 
    @{Name='Creation Date'; Expression={$_.whenCreated}}, 
    @{Name='Department'; Expression={$_.Department}}, 
    @{Name='Description'; Expression={$_.Description}}, 
    @{Name='AccountStatus'; Expression={$_.Enabled}}, 
    @{Name='Display Name'; Expression={$_.DisplayName}}, 
    @{Name='Division'; Expression={$_.Division}}, 
    @{Name='Email Address'; Expression={$_.EmailAddress}}, 
    @{Name='Employee ID'; Expression={$_.EmployeeID}}, 
    @{Name='Expiration Date'; Expression={[datetime]::FromFileTime($_.accountExpires)}}, 
    @{Name='First Name'; Expression={$_.GivenName}}, 
    @{Name='Initials'; Expression={$_.Initials}}, 
    @{Name='Job Title'; Expression={$_.Title}}, 
    @{Name='Last Lock Out Date'; Expression={$_.LockedOut}}, 
    @{Name='Last Name'; Expression={$_.Surname}}, 
    @{Name='Manager'; Expression={$_.Manager}}, 
    @{Name='Mobile Phone Number'; Expression={$_.MobilePhone}}, 
    @{Name='Modification Date'; Expression={$_.whenChanged}}, 
    @{Name='Must Change Password At Next Logon'; Expression={$_.PasswordExpired}}, 
    @{Name='Notes'; Expression={$_.info}}, 
    @{Name='Office'; Expression={$_.PhysicalDeliveryOfficeName}}, 
    @{Name='Parent Container'; Expression={$_.CanonicalName}}, 
    @{Name='Password Age (Days)'; Expression={((Get-Date) - $_.PasswordLastSet).Days}}, 
    @{Name='Password Expiration Date'; Expression={if ($_.accountExpires -ne 0) {[datetime]::FromFileTime($_.accountExpires)} else {"Never"}}}, 
    @{Name='Password Last Changed'; Expression={$_.PasswordLastSet}}, 
    @{Name='Password Never Expires'; Expression={$_.PasswordNeverExpires}}, 
    @{Name='Password Not Required'; Expression={$_.PasswordNotRequired}}, 
    @{Name='Telephone Number'; Expression={$_.TelephoneNumber}}, 
    @{Name='Username'; Expression={$_.SamAccountName}}, 
    @{Name='Username (pre 2000)'; Expression={$_.userPrincipalName}}, 
    @{Name='distinguishedName'; Expression={($_.distinguishedName -replace '^CN=[^,]+,', '')}}, 
    @{Name='MemberOf'; Expression={($_.MemberOf -replace '^CN=([^,]+),.*$', '$1') -join ','}}
)
```

### Function to Export All Users

The `Get-ADDomainAllUsers` function retrieves all users in the domain with the specified properties.

```powershell
function Get-ADDomainAllUsers {
    $users = Get-ADUser -Filter * -Properties $properties
    $users | ForEach-Object {
        $_ | Select-Object $global:selectProperties
    }
}
```

### Example Usage

```powershell
# Export all users in the domain
Get-ADDomainAllUsers
```

## Full Script

```powershell
# Define properties variable
$properties = @(
    'Name', 'AccountLockoutTime', 'City', 'Company', 'Country', 'whenCreated', 'Department', 'Description', 'Enabled', 
    'DisplayName', 'Division', 'EmailAddress', 'EmployeeID', 'accountExpires', 'GivenName', 'Initials', 'Title', 'LockedOut', 
    'Surname', 'Manager', 'MobilePhone', 'whenChanged', 'PasswordExpired', 'info', 'PhysicalDeliveryOfficeName', 'CanonicalName', 
    'PasswordLastSet', 'PasswordNeverExpires', 'PasswordNotRequired', 'TelephoneNumber', 'SamAccountName', 'userPrincipalName', 
    'distinguishedName', 'MemberOf'
)

# Define global variable for Select-Object properties
$global:selectProperties = @(
    @{Name='Name'; Expression={$_.Name}}, 
    @{Name='Account Is Locked Out'; Expression={$_.AccountLockoutTime}}, 
    @{Name='City'; Expression={$_.City}}, 
    @{Name='Company'; Expression={$_.Company}}, 
    @{Name='Country'; Expression={$_.Country}}, 
    @{Name='Creation Date'; Expression={$_.whenCreated}}, 
    @{Name='Department'; Expression={$_.Department}}, 
    @{Name='Description'; Expression={$_.Description}}, 
    @{Name='AccountStatus'; Expression={$_.Enabled}}, 
    @{Name='Display Name'; Expression={$_.DisplayName}}, 
    @{Name='Division'; Expression={$_.Division}}, 
    @{Name='Email Address'; Expression={$_.EmailAddress}}, 
    @{Name='Employee ID'; Expression={$_.EmployeeID}}, 
    @{Name='Expiration Date'; Expression={[datetime]::FromFileTime($_.accountExpires)}}, 
    @{Name='First Name'; Expression={$_.GivenName}}, 
    @{Name='Initials'; Expression={$_.Initials}}, 
    @{Name='Job Title'; Expression={$_.Title}}, 
    @{Name='Last Lock Out Date'; Expression={$_.LockedOut}}, 
    @{Name='Last Name'; Expression={$_.Surname}}, 
    @{Name='Manager'; Expression={$_.Manager}}, 
    @{Name='Mobile Phone Number'; Expression={$_.MobilePhone}}, 
    @{Name='Modification Date'; Expression={$_.whenChanged}}, 
    @{Name='Must Change Password At Next Logon'; Expression={$_.PasswordExpired}}, 
    @{Name='Notes'; Expression={$_.info}}, 
    @{Name='Office'; Expression={$_.PhysicalDeliveryOfficeName}}, 
    @{Name='Parent Container'; Expression={$_.CanonicalName}}, 
    @{Name='Password Age (Days)'; Expression={((Get-Date) - $_.PasswordLastSet).Days}}, 
    @{Name='Password Expiration Date'; Expression={if ($_.accountExpires -ne 0) {[datetime]::FromFileTime($_.accountExpires)} else {"Never"}}}, 
    @{Name='Password Last Changed'; Expression={$_.PasswordLastSet}}, 
    @{Name='Password Never Expires'; Expression={$_.PasswordNeverExpires}}, 
    @{Name='Password Not Required'; Expression={$_.PasswordNotRequired}}, 
    @{Name='Telephone Number'; Expression={$_.TelephoneNumber}}, 
    @{Name='Username'; Expression={$_.SamAccountName}}, 
    @{Name='Username (pre 2000)'; Expression={$_.userPrincipalName}}, 
    @{Name='distinguishedName'; Expression={($_.distinguishedName -replace '^CN=[^,]+,', '')}}, 
    @{Name='MemberOf'; Expression={($_.MemberOf -replace '^CN=([^,]+),.*$', '$1') -join ','}}
)

# Function to export all users in the domain with specified properties
function Get-ADDomainAllUsers {
    $users = Get-ADUser -Filter * -Properties $properties
    $users | ForEach-Object {
        $_ | Select-Object $global:selectProperties
    }
}

# Export all users in the domain
Get-ADDomainAllUsers
```
