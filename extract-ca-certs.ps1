if ($args[0] -ne $null) {
    $root_dse = Get-ADRootDSE -Server $args[0]
}
else {
    $root_dse = Get-ADRootDSE
}

$config_nc = $root_dse.ConfigurationNamingContext
$sources = Get-ADObject -LDAPFilter "(objectClass=certificationAuthority)" -SearchBase "$config_nc" -Properties cACertificate
$_ = mkdir ca-certs -ErrorAction SilentlyContinue
$seen = @{}

foreach ($source in $sources) {
    $i = 0
    foreach ($bytes in $source.caCertificate) {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($bytes)

        $include = $true
        if ($seen[$cert.Thumbprint] -eq 1) {
            $include = $false
        }

        if ($cert.Subject -ne $cert.Issuer) {
            $include = $false
        }

        if ($include) {
            $seen[$cert.Thumbprint] = 1
            $pem = [Convert]::ToBase64String($bytes)
            $pem = $pem -replace ".{1,64}", "$&`n"
            $pem = "-----BEGIN CERTIFICATE-----`n$pem-----END CERTIFICATE-----"

            $name = $cert.Subject
            $name = $name -replace ',.*'
            $name = $name -replace '^.*?='
            $name = $name -replace '[^a-zA-Z0-9]+', '_'
            $name = "_" + $name.ToUpper()

            $prefix = $cert.Thumbprint.Substring(0, 8) + "_"
            $prefix = $prefix.ToLower()
            $name = "$prefix$i$name.crt"
            Write-Host "Extracted: $name"      
            sc -Path "ca-certs\$name" -Value "$pem" -Encoding utf8
        }

        $i++
    }
}
