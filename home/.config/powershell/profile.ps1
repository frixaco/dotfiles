$env:EDITOR = "nvim"
$env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
$env:BAT_THEME = "cyberdream"

$userPaths = @(
    (Join-Path $HOME ".local/bin")
    (Join-Path $HOME ".bun/bin")
    (Join-Path $HOME ".amp/bin")
    (Join-Path $HOME ".opencode/bin")
)

if ($IsMacOS) {
    $env:JAVA_HOME = "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    $env:ANDROID_HOME = Join-Path $HOME "Library/Android/sdk"
    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
    $userPaths += @(
        (Join-Path $env:ANDROID_HOME "platform-tools")
        (Join-Path $env:ANDROID_HOME "emulator")
        "/Applications/Obsidian.app/Contents/MacOS"
    )
} elseif ($IsLinux) {
    $userPaths += "/usr/local/bin/obsidian"
}

$pathSeparator = [IO.Path]::PathSeparator
$currentPaths = @($env:PATH -split [Regex]::Escape($pathSeparator))
$pathComparer = if ($IsWindows) { [StringComparer]::OrdinalIgnoreCase } else { [StringComparer]::Ordinal }
$seenPaths = [Collections.Generic.HashSet[string]]::new($pathComparer)
$mergedPaths = foreach ($pathEntry in $userPaths + $currentPaths) {
    if (-not $pathEntry) {
        continue
    }

    $normalizedPath = if ($IsWindows) {
        $pathEntry.Replace([IO.Path]::AltDirectorySeparatorChar, [IO.Path]::DirectorySeparatorChar)
    } else {
        $pathEntry
    }

    if ($seenPaths.Add($normalizedPath)) {
        $normalizedPath
    }
}
$env:PATH = $mergedPaths -join $pathSeparator

Set-Alias v nvim
Set-Alias c Clear-Host
Set-Alias cc claude
Set-Alias oc opencode
Set-Alias cx codex

function cl { claude --dangerously-skip-permissions @args }

function l {
    eza --color=always --icons --all --long --time modified --sort modified --no-permissions --octal-permissions --git --smart-group --git-repos @args
}

function en {
    Set-Location -LiteralPath (Join-Path $HOME ".config/nvim")
    nvim
}

function sf {
    . $PROFILE.CurrentUserAllHosts
}

function ef {
    nvim (Join-Path $HOME ".dotfiles/home/.config/powershell/profile.ps1")
}

function se {
    $activateScript = if ($IsWindows) {
        Join-Path $PWD ".venv/Scripts/Activate.ps1"
    } else {
        Join-Path $PWD ".venv/bin/Activate.ps1"
    }

    if (-not (Test-Path -LiteralPath $activateScript -PathType Leaf)) {
        Write-Error "Virtual environment activation script not found: $activateScript"
        return
    }

    . $activateScript
}

function ccd {
    Set-Location -LiteralPath (Join-Path $HOME ".dotfiles")
}

function upall {
    $originalLocation = Get-Location
    $originalMiseYes = $env:MISE_YES
    $failed = @()
    try {
        Set-Location -LiteralPath (Join-Path $HOME ".dotfiles") -ErrorAction Stop
        $env:MISE_YES = "1"
        # Scoop owns mise too, so it also updates the mise executable.
        foreach ($step in @(
            "scoop update", "scoop update --all",
            "mise run sync", "mise up", "mise exec -- npm update -g",
            "mise exec -- bun update -g", "mise lsp:sync", "mise ai:sync"
        )) {
            Write-Host "`n==> $step"
            $command, $commandArgs = $step -split " "
            $commandArgs = @($commandArgs)
            $global:LASTEXITCODE = 0
            try {
                & $command @commandArgs
                $result = $LASTEXITCODE
            } catch {
                Write-Warning $_.Exception.Message
                $result = if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 }
            }
            # Continue after failures, but stop on Unix or Windows interruption codes.
            if ($result -in @(130, 143, -1073741510)) {
                $global:LASTEXITCODE = $result
                return
            }
            if ($result -ne 0) { $failed += $step }
        }
    } finally {
        Set-Location -LiteralPath $originalLocation.Path
        $env:MISE_YES = $originalMiseYes
    }
    $global:LASTEXITCODE = if ($failed) { 1 } else { 0 }
    if ($failed) { Write-Error "Failed: $($failed -join ', ')" }
}

function envsource {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Error "Environment file not found: $Path"
        return
    }

    foreach ($line in [IO.File]::ReadLines((Resolve-Path -LiteralPath $Path).Path)) {
        $entry = $line.Trim()
        if (-not $entry -or $entry.StartsWith("#")) {
            continue
        }

        $separator = $entry.IndexOf("=")
        if ($separator -le 0) {
            Write-Warning "Skipping invalid environment entry: $line"
            continue
        }

        $name = $entry.Substring(0, $separator).Trim()
        if ($name -notmatch "^[A-Za-z_][A-Za-z0-9_]*$") {
            Write-Warning "Skipping invalid environment variable name: $name"
            continue
        }

        $value = $entry.Substring($separator + 1).Trim()
        if ($value.Length -ge 2) {
            $isDoubleQuoted = $value.StartsWith('"') -and $value.EndsWith('"')
            $isSingleQuoted = $value.StartsWith("'") -and $value.EndsWith("'")
            if ($isDoubleQuoted -or $isSingleQuoted) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        Set-Item -LiteralPath "Env:$name" -Value $value
    }
}

function g {
    $originalLocation = Get-Location
    try {
        lazygit @args
    } finally {
        Set-Location -LiteralPath $originalLocation.Path
    }
}

function j {
    $originalLocation = Get-Location
    try {
        jjui @args
    } finally {
        Set-Location -LiteralPath $originalLocation.Path
    }
}

function y {
    $cwdFile = [IO.Path]::GetTempFileName()
    try {
        yazi @args "--cwd-file=$cwdFile"
        $nextLocation = (Get-Content -Raw -LiteralPath $cwdFile).Trim()
        if ($nextLocation -and $nextLocation -ne (Get-Location).Path) {
            Set-Location -LiteralPath $nextLocation
        }
    } finally {
        Remove-Item -Force -LiteralPath $cwdFile -ErrorAction SilentlyContinue
    }
}

if ($IsLinux -and $env:WSL_DISTRO_NAME) {
    function Copy-ToDesktop {
        param(
            [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
            [string[]]$Path
        )

        $targetDirectory = "/mnt/c/Users/frixa/Desktop"
        if (-not (Test-Path -LiteralPath $targetDirectory -PathType Container)) {
            Write-Error "Desktop directory not found: $targetDirectory"
            return
        }

        foreach ($sourcePath in $Path) {
            if (Test-Path -LiteralPath $sourcePath) {
                Copy-Item -LiteralPath $sourcePath -Destination $targetDirectory
                Write-Output "Copied: $sourcePath -> $targetDirectory/"
            } else {
                Write-Error "File not found: $sourcePath"
            }
        }
    }
}

function anitrack {
    bun x @frixaco/anitrack
}

$environmentProfile = Join-Path $HOME ".config/powershell/env.ps1"
if (Test-Path -LiteralPath $environmentProfile -PathType Leaf) {
    . $environmentProfile
}

if ($IsWindows -and $env:ChocolateyInstall) {
    $chocolateyProfile = Join-Path $env:ChocolateyInstall "helpers/chocolateyProfile.psm1"
    if (Test-Path -LiteralPath $chocolateyProfile -PathType Leaf) {
        Import-Module $chocolateyProfile
    }
}

$hasUsablePrompt = $Host.UI.SupportsVirtualTerminal
if ($hasUsablePrompt) {
    try {
        $cursorPosition = $Host.UI.RawUI.CursorPosition
        $Host.UI.RawUI.CursorPosition = $cursorPosition
    } catch {
        $hasUsablePrompt = $false
    }
}

if ($hasUsablePrompt) {
    if (Get-Command mise -ErrorAction SilentlyContinue) {
        (& mise activate pwsh) | Out-String | Invoke-Expression
    }
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        & starship init powershell | Out-String | Invoke-Expression
    }
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        # Starship replaces prompt. Reattach zoxide after it, including profile reloads.
        $global:__zoxide_hooked = 0
        zoxide init powershell | Out-String | Invoke-Expression
    }
}
