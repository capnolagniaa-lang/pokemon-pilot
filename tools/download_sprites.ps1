# Descarga sprites (PMDCollab/SpriteCollab) y genera scripts/sprite_data.gd.
# Uso: powershell -ExecutionPolicy Bypass -File tools/download_sprites.ps1
# Para agregar especies, sumá su número de Pokédex a $dex.

$dex = @(1, 4, 7, 16, 19, 37, 43, 54, 58, 60, 69, 133)
$anims = @("Idle", "Walk", "Attack", "Hurt")
$base = "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master"
$root = Split-Path -Parent $PSScriptRoot
$ProgressPreference = "SilentlyContinue"

$out = @()
foreach ($n in $dex) {
	$id = "{0:D4}" -f $n
	$dir = Join-Path $root "sprites/pokemon/$id"
	New-Item -ItemType Directory -Force $dir | Out-Null
	[xml]$xml = (Invoke-WebRequest "$base/sprite/$id/AnimData.xml" -UseBasicParsing).Content
	$byName = @{}
	foreach ($a in $xml.AnimData.Anims.Anim) { $byName[$a.Name] = $a }
	$entries = @()
	foreach ($name in $anims) {
		$a = $byName[$name]
		if ($null -eq $a) { continue }
		while ($a.CopyOf) { $a = $byName[$a.CopyOf] }
		$file = "$($a.Name)-Anim.png"
		$dest = Join-Path $dir $file
		if (-not (Test-Path $dest)) { Invoke-WebRequest "$base/sprite/$id/$file" -OutFile $dest -UseBasicParsing }
		$durs = ($a.Durations.Duration | ForEach-Object { $_ }) -join ", "
		$entries += "`t`t`"$name`": {`"file`": `"res://sprites/pokemon/$id/$file`", `"w`": $($a.FrameWidth), `"h`": $($a.FrameHeight), `"durations`": [$durs]},"
	}
	$portrait = Join-Path $dir "portrait.png"
	if (-not (Test-Path $portrait)) { Invoke-WebRequest "$base/portrait/$id/Normal.png" -OutFile $portrait -UseBasicParsing }
	$out += "`t$n`: {"
	$out += "`t`t`"portrait`": `"res://sprites/pokemon/$id/portrait.png`","
	$out += $entries
	$out += "`t},"
	Write-Host "OK $id"
}

$items = Join-Path $root "sprites/items"
New-Item -ItemType Directory -Force $items | Out-Null
$ball = Join-Path $items "poke-ball.png"
if (-not (Test-Path $ball)) { Invoke-WebRequest "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png" -OutFile $ball -UseBasicParsing }

$gd = @("extends RefCounted", "## Generado por tools/download_sprites.ps1 - no editar a mano.", "", "const ANIMS := {") + $out + @("}")
[IO.File]::WriteAllText((Join-Path $root "scripts/generated/sprite_data.gd"), ($gd -join "`n") + "`n", (New-Object Text.UTF8Encoding($false)))
Write-Host "Listo."
