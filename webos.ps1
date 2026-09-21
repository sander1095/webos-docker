#!/usr/bin/env pwsh
# Runs an ares-* command inside the webOS CLI container.
# Usage: .\webos.ps1 ares-install --device tv --list
#        .\webos.ps1                (drops into a shell)

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $CliArgs
)

$ErrorActionPreference = 'Stop'
if (-not $CliArgs) { $CliArgs = @('bash') }

docker compose --file (Join-Path $PSScriptRoot 'compose.yaml') run --rm cli @CliArgs
exit $LASTEXITCODE
