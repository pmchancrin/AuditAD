
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Application.Read.All", "Application.ReadWrite.All", "Directory.Read.All", "Directory.ReadWrite.All", "Directory.AccessAsUser.All"
$Apps = Get-MgApplication -All
$today = Get-Date
$credentials = @()

$Apps | %{
    $aadAppObjId = $_.Id
    $app = Get-MgApplication -ApplicationId $aadAppObjId 
    $owner = Get-MgApplicationOwner -ApplicationId $aadAppObjId

    $app.KeyCredentials | %{
        #write-host $_.KeyId $_.DisplayName
        $credentials += [PSCustomObject] @{
            CredentialType = "KeyCredentials";
            DisplayName = $app.DisplayName;
            AppId = $app.AppId;
            ExpiryDate = $_.EndDateTime;
            StartDate = $_.StartDateTime;
            #KeyID = $_.KeyId;
            Type = $_.Type;
            Usage = $_.Usage;
            Owners = $owner.AdditionalProperties.userPrincipalName;
            Expired = (([DateTime]$_.EndDateTime) -lt $today) ? "Yes" : "No";
            }
    }


    $app.PasswordCredentials | %{
        #write-host $_.KeyId $_.DisplayName
        $credentials += [PSCustomObject] @{
            CredentialType = "PasswordCredentials";
            DisplayName = $app.DisplayName;
            AppId = $app.AppId;
            ExpiryDate = $_.EndDateTime;
            StartDate = $_.StartDateTime;
            #KeyID = $_.KeyId;
            Type = 'NA';
            Usage = 'NA';
            Owners = $owner.AdditionalProperties.userPrincipalName;
            Expired = (([DateTime]$_.EndDateTime) -lt $today) ? "Yes" : "No";
        }
    }
}

$credentials | FT -AutoSize 

# Optionally export to a CSV file
#$credentials | Export-Csv -Path "AppsInventory.csv" -NoTypeInformation 
