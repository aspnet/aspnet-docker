[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    $BuildNumber
)

Get-ChildItem -Recurse "$PSScriptRoot/../2.0/*/Dockerfile" | % {
    Write-Host "Updating $_"
    Set-Content $_ (Get-Content $_ `
    | % {
        if ($_ -like 'ENV ASPNETCORE_BUILD_VERSION*') {
            "ENV ASPNETCORE_BUILD_VERSION 2.0.0-rtm-$BuildNumber"
        } elseif ($_ -like 'ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL*') {
            if ($_ -like '*.tar.gz'){
                $rid = 'linux'
                $ext = 'tar.gz'
            } else {
                $rid = 'winx64'
                $ext = 'zip'
            }
            "ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/2.0.0-${BuildNumber}/Build.RS.$rid-rtm-${BuildNumber}.$ext"
        } else {
            $_
        }
     })
}
