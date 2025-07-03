if (-not (Test-Path "$( $env:ProgramData )\docker")) { exit 0 }
$services = @("cexecsvc", "vmcompute", "vmicguestinterface", "vmicheartbeat", "vmickvpexchange", "vmicrdv", "vmicshutdown", "vmictimesync", "vmicvmsession", "vmicvss")
foreach ($serviceName in $services)
{
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') { Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue }
}
Start-Sleep -Seconds 2
$hcsdiagOutput = & hcsdiag.exe list 2> $null
if ($hcsdiagOutput)
{
    $containerMatches = $hcsdiagOutput | Select-String -Pattern "container" -SimpleMatch
    if ($containerMatches)
    {
        $containerMatches | ForEach-Object {
            $line = $_.Line
            if ($line -match '\{([^}]+)\}')
            {
                $containerId = $Matches[1]
                & hcsdiag.exe kill $containerId 2> $null
            }
        }
    }
}
if (Get-Command Get-ComputeProcess -ErrorAction SilentlyContinue)
{
    $computeProcesses = Get-ComputeProcess -ErrorAction SilentlyContinue
    if ($computeProcesses)
    {
        $containerProcesses = $computeProcesses | Where-Object { $_.Type -like "*container*" }
        if ($containerProcesses)
        {
            $containerProcesses | ForEach-Object {
                $_ | Stop-ComputeProcess -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
Start-Sleep -Seconds 3
$windowsFilterPath = Join-Path "$( $env:ProgramData )\docker" "windowsfilter"
if (Test-Path $windowsFilterPath)
{
    $layerDirs = Get-ChildItem -Path $windowsFilterPath -Directory -ErrorAction SilentlyContinue
    if ($layerDirs)
    {
        $job = Start-Job -ScriptBlock {
            param($layers)
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Hcs
{
[DllImport("ComputeStorage.dll", SetLastError=true, CharSet=CharSet.Unicode)]
public static extern int HcsDestroyLayer(string layerPath);
}
"@
            $results = @()
            foreach ($layer in $layers)
            {
                try
                {
                    $result = [Hcs]::HcsDestroyLayer($layer.FullName)
                    $results += [PSCustomObject]@{
                        Layer = $layer.Name
                        Path = $layer.FullName
                        Result = $result
                        Success = ($result -eq 0)
                    }
                }
                catch
                {
                    $results += [PSCustomObject]@{
                        Layer = $layer.Name
                        Path = $layer.FullName
                        Result = -1
                        Success = $false
                        Error = $_.Exception.Message
                    }
                }
            }
            return $results
        } -ArgumentList @(,$layerDirs)
        if ($job | Wait-Job -Timeout 120)
        {
            $results = $job | Receive-Job
            $job | Remove-Job
        }
        else
        {
            $job | Stop-Job
            $job | Remove-Job
        }
    }
    if (Test-Path $windowsFilterPath)
    {
        & cmd.exe /c "rd /s /q `"$windowsFilterPath`"" 2> $null | Out-Null
        if (Test-Path $windowsFilterPath)
        {
            $tempEmptyDir = Join-Path $env:TEMP "EmptyDir_$( Get-Random )"
            try
            {
                New-Item -ItemType Directory -Path $tempEmptyDir -Force | Out-Null
                & robocopy.exe $tempEmptyDir $windowsFilterPath /MIR /R:1 /W:1 /NP /NFL /NDL /NJH /NJS 2> $null | Out-Null
                Remove-Item $tempEmptyDir -Force -ErrorAction SilentlyContinue
            }
            catch { Remove-Item $tempEmptyDir -Force -ErrorAction SilentlyContinue }
        }
    }
}
Remove-Item "$( $env:ProgramData )\docker" -Recurse -Force
$dockerDownloads = "$env:UserProfile\DockerDownloads"
if (Test-Path $dockerDownloads) { Remove-Item $dockerDownloads -Recurse -Force }
