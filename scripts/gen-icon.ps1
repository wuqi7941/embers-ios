# 生成 App 图标：炭夜 + 余烬光（在 Windows 上无需 Xcode，System.Drawing 即可）
# 用法: powershell -ExecutionPolicy Bypass -File scripts/gen-icon.ps1
Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot "..\Resources\Assets.xcassets\AppIcon.appiconset"
$out = Join-Path $outDir "icon-1024.png"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(255, 10, 10, 14))

function New-Glow($cx, $cy, $r, $center, $edge) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse([single]($cx - $r), [single]($cy - $r), [single](2 * $r), [single](2 * $r))
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
    $brush.CenterColor = $center
    $brush.SurroundColors = [System.Drawing.Color[]]@($edge)
    $g.FillEllipse($brush, [single]($cx - $r), [single]($cy - $r), [single](2 * $r), [single](2 * $r))
    $brush.Dispose(); $path.Dispose()
}

function New-Sparks($cx, $cy, $offset, $count, $baseR, $color) {
    for ($i = 0; $i -lt $count; $i++) {
        $angle = -1.2 + $i * (2.4 / ($count - 1))   # 上方扇形展开
        $dx = [math]::Cos($angle) * $offset
        $dy = [math]::Sin($angle) * $offset
        $r = $baseR * (0.6 + 0.5 * ($i % 3) / 2)
        $p = New-Object System.Drawing.Drawing2D.GraphicsPath
        $p.AddEllipse([single]($cx + $dx - $r), [single]($cy + $dy - $r), [single](2 * $r), [single](2 * $r))
        $b = New-Object System.Drawing.Drawing2D.PathGradientBrush($p)
        $b.CenterColor = $color
        $b.SurroundColors = [System.Drawing.Color[]]@([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        $g.FillEllipse($b, [single]($cx + $dx - $r), [single]($cy + $dy - $r), [single](2 * $r), [single](2 * $r))
        $b.Dispose(); $p.Dispose()
    }
}

# 外圈大辉光
New-Glow 512 512 340 ([System.Drawing.Color]::FromArgb(70, 255, 150, 60)) ([System.Drawing.Color]::FromArgb(0, 120, 40, 20))
# 中层焰光
New-Glow 512 512 215 ([System.Drawing.Color]::FromArgb(160, 255, 190, 110)) ([System.Drawing.Color]::FromArgb(0, 200, 80, 30))
# 核心：烧红的炭
New-Glow 512 512 110 ([System.Drawing.Color]::FromArgb(255, 255, 227, 176)) ([System.Drawing.Color]::FromArgb(255, 232, 88, 47))
New-Glow 512 512 52 ([System.Drawing.Color]::FromArgb(255, 255, 245, 214)) ([System.Drawing.Color]::FromArgb(255, 255, 170, 90))

# 上方火花
New-Sparks 512 356 150 5 26 ([System.Drawing.Color]::FromArgb(255, 255, 200, 120))
New-Sparks 340 430 0 3 14 ([System.Drawing.Color]::FromArgb(255, 235, 120, 70))

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Host "✓ 图标已生成: $out"