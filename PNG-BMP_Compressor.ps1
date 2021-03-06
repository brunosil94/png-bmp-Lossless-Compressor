﻿function compress($nameOfFile) {
    cls
    $dir=(Get-Item -Path ".\" -Verbose).FullName
    if ($nameOfFile -eq $null) {
        return "File not found"
    }
    if (![System.IO.File]::Exists("$dir\$nameOfFile")){
        return "File not found"
    }
    $file=$nameOfFile
    $paq8="paq8l\paq8l"
    $image= New-Object System.Drawing.Bitmap($file);
    $a=New-Object System.Collections.Generic.List[System.Object]
    $b=New-Object System.Collections.Generic.List[System.Object]
    $c=New-Object System.Collections.Generic.List[System.Object]
    $Width=$image.Width
    $Height=$image.Height
    for ($j = 0; $j -lt $Height; $j++)
    {
       for ($i = 0; $i -lt $Width;$i++)
       { 
         $a.Add($image.GetPixel($i,$j).R)
         $b.Add($image.GetPixel($i,$j).G)
         $c.Add($image.GetPixel($i,$j).B)
       }
       $progress=[math]::Floor(($j * 100)/$Height)
       Write-Progress -Activity "Processing pixels..." -PercentComplete $progress
    }
    cls
    "Finished!"
    $group=@()
    $group+=$a
    $group+=$b
    $group+=$c
    [System.IO.File]::WriteAllBytes("$dir\x",$group)
    cmd /c "$paq8 -8 x"
    Remove-Item "$dir\x"
    $name="$Width-$Height-$file"
    Rename-Item "x.paq8l" "$name.paq8l"
    cls
    $size=(Get-Item "$file").Length
    $sizex=(Get-Item "$name.paq8l").Length
    $percentage=100-[math]::Round((($sizex*100)/$size))
    "$size bytes --> $sizex bytes"
    "$percentage % smaller!."
}

function decompress($nameOfFile) {
    cls
    if ($nameOfFile -eq $null) {
        return "File not found"
    }
    $dir=(Get-Item -Path ".\" -Verbose).FullName
     if (![System.IO.File]::Exists("$dir\$nameOfFile")){
        return "File not found"
    }
    $f=$nameOfFile -split "-"
    $Width=$f[0]
    $Height=$f[1]
    $file=$f[2] -replace '.paq8l',''

    $paq8="paq8l\paq8l"

    $r=New-Object System.Collections.Generic.List[System.Object]
    $g=New-Object System.Collections.Generic.List[System.Object]
    $b=New-Object System.Collections.Generic.List[System.Object]
    cmd /c "$paq8 $nameOfFile"
    Remove-Item "$dir\$nameOfFile"

    [byte[]]$k=[System.IO.File]::ReadAllBytes("$dir\x")

    #bits to black and white // 3 bytes group to color pixel

    $s=[convert]::ToInt32(([math]::Round($k.Count/3)))
    $s1=$s+$s
    for ($x=0;$x -lt $s;$x++) {
        $r.Add($k[$x])
        $progress=[math]::Floor(($x * 100)/$s)
        Write-Progress -Activity "Processing pixels..." -PercentComplete $progress
    }
    for ($y=$s;$y -lt $s1;$y++) {
        $g.Add($k[$y])
    }
    for ($z=$s1;$z -lt $k.Count;$z++) {
        $b.Add($k[$z])
    }

    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $bmp = New-Object System.Drawing.Bitmap($Width,$Height)

    $p=0
    for ($j = 0; $j -lt $Height; $j++)
    {
       for ($i = 0; $i -lt $Width;$i++)  #  $j += 2
       { 
         $bmp.SetPixel($i, $j, [System.Drawing.Color]::FromArgb($r[$p],$g[$p],$b[$p]))
         $p++
       }
    }
    $file=$file -replace "$Width-$Height-",''
    $bmp.Save("$dir\$file")   #Convert with paint to monochromatic
}
cls
$input=Read-Host -Prompt "c nameOfImage.png / d name.paq8l :"
$i=$input -split " "
$name=$i[1]
if ($i[0] -eq "c") {
    compress $name
 }
 if ($i[0] -eq "d") {
    decompress $name
 } else {
  "Nothing to do!"
 }