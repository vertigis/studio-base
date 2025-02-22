function Test-LastExitCode {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed with: $LASTEXITCODE"
        throw ""
    }
}

function Get-Config {
    param (
        [string]$Path
    )

    $config = Get-Content -Path "$Path"
    $config = $config -match '^;\s*Config:'
    $config = $config -replace '.*Config:', ""
    $config = $config -replace '\s*', ""
    $config = $config -join ""

    if ($config -ne "default") {
        return $config
    }
    
    $config = certutil
    $config = $config -match '^\s*Config:'
    $config = $config -replace '.*Config:', ""
    $config = $config -replace '[\s"]*', ""
    $config = $config -join ""

    return $config
}

function Test-Cert {
    param (
        [string]$Filter
    )

    $files = Get-ChildItem -Path web-certs -Filter $Filter

    foreach ($file in $files) {
        $name = $file.BaseName

        # Load the certificate
        $cert = Get-PfxCertificate -FilePath $file.FullName

        # Check the NotAfter date
        $end = $cert.NotAfter
        $end = $end.AddDays(-7)
        $now = Get-Date

        if ($now -lt $end) {
            Write-Host "$name valid --- Skipping"
            throw ""
        }

        Write-Host "$name expired --- Ignoring"            
    }
}

$_ = mkdir .temp -ErrorAction SilentlyContinue
$_ = mkdir web-certs -ErrorAction SilentlyContinue
$files = Get-ChildItem -Path web-certs -Filter *.inf

foreach ($file in $files) {
    try {
        $name = "web-certs\" + $file.BaseName
        $temp = ".temp\" + $file.BaseName
        Test-Cert -Filter ($file.BaseName + "_*.pfx")

        $config = Get-Config -Path "$name.inf"
        if ($config -eq "False") {
            throw ""
        }

        Write-Host "> certreq -f -new `"$name.inf`" `"$temp.csr`""
        certreq -f -new `"$name.inf`" `"$temp.csr`"
        Test-LastExitCode

        Write-Host "> certreq -f -config $config -submit `"$temp.csr`" `"$temp.crt`""
        certreq -f -config $config -submit `"$temp.csr`" `"$temp.crt`"
        Test-LastExitCode

        Write-Host "> certreq -accept `"$temp.crt`""
        $sn = certreq -accept `"$temp.crt`"
        Test-LastExitCode
        Write-Host ($sn -join "\n")
        $sn = $sn -match "Serial Number:"
        $sn = $sn -replace "Serial Number:", ""
        $sn = $sn -join ""
        $sn = $sn.Trim()

        Write-Host "> certutil -exportPFX -f -p `"`" MY $sn `"$temp.pfx`""
        certutil -exportPFX -f -p `"`" MY $sn `"$temp.pfx`"
        Test-LastExitCode

        Write-Host "> certutil -delstore MY $sn"
        certutil -delstore MY $sn
        Test-LastExitCode

        $suffix = "_" + [DateTime]::Now.Ticks
        $_ = cp -Path "$temp.pfx" -Destination "$name$suffix.pfx"
    }
    catch {
        # message done
    }
}
