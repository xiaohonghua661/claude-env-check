@echo off
setlocal EnableExtensions
chcp 65001 >nul <nul
title 伪装环境一键工具
set "SELF=%~f0"

echo ================================================
echo        伪装环境一键工具 (网页版)
echo ================================================
echo.
echo   正在启动本地网页控制台...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $l=[IO.File]::ReadAllLines($args[0],[Text.Encoding]::UTF8); $s=-1; for($i=0;$i -lt $l.Count;$i++){ if($l[$i] -match '^::PS>$'){ $s=$i; break } }; if($s -ge 0){ $code=($l[($s+1)..($l.Count-1)] -join [char]10); & ([ScriptBlock]::Create($code)) } }" "%SELF%"
echo.
echo  服务已停止。按任意键退出。
pause >nul
exit /b 0
::PS>

# 伪装环境一键工具 - 网页版 (由bat以GBK提取执行)
$OK = 'PASS'; $BAD = 'FAIL'; $WARN = 'WARN'

$uiHtml = @'
<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>伪装环境一键工具</title>
<style>
:root{--bg:#0f1420;--card:#1a2233;--line:#2c3a55;--txt:#e6e9f0;--sub:#9fb2d0;--ok:#3ddc84;--warn:#ffd166;--bad:#ff6b6b;--blue:#3b82f6}
*{box-sizing:border-box}
body{margin:0;font-family:system-ui,"Segoe UI","Microsoft YaHei",sans-serif;background:var(--bg);color:var(--txt)}
.wrap{max-width:880px;margin:0 auto;padding:28px 20px 60px}
h1{font-size:24px;margin:0 0 4px}
.sub{color:var(--sub);font-size:13px;margin-bottom:20px}
.cards{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:20px}
button{border:0;border-radius:10px;padding:12px 18px;font-size:15px;cursor:pointer;color:#fff;background:var(--blue)}
button.green{background:var(--ok);color:#04230f}
button.orange{background:var(--warn);color:#2a1c00}
button.gray{background:#334155}
button:active{opacity:.8}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:18px;margin-bottom:16px}
.row{display:flex;justify-content:space-between;gap:12px;padding:7px 0;border-bottom:1px dashed var(--line);font-size:14px}
.row:last-child{border-bottom:none}
.k{color:var(--sub);white-space:nowrap}
.v{font-weight:600;text-align:right;word-break:break-all}
.badge{display:inline-block;padding:2px 9px;border-radius:20px;font-size:12px;font-weight:700;white-space:nowrap}
.b-ok{background:#123b26;color:var(--ok)}
.b-warn{background:#3a2f12;color:var(--warn)}
.b-bad{background:#3b1218;color:var(--bad)}
.b-info{background:#243047;color:var(--sub)}
#log{white-space:pre-wrap;font-size:13px;color:var(--sub);background:#121a29;border:1px solid var(--line);border-radius:10px;padding:14px;max-height:360px;overflow:auto;margin-top:10px}
.note{font-size:12px;color:var(--sub);line-height:1.7;margin-top:14px}
.verdict{font-size:16px;font-weight:700;padding:12px 16px;border-radius:10px;margin-bottom:12px}
.v-ok{background:#123b26;color:var(--ok)}
.v-warn{background:#3a2f12;color:var(--warn)}
.v-bad{background:#3b1218;color:var(--bad)}
</style></head><body><div class="wrap">
<h1>伪装环境一键工具</h1>
<div class="sub">本地网页控制台 · 目标：美国纽约 + 英文 · 含 Claude Code 客户端伪装检查</div>
<div class="cards">
<button onclick="run('check')">全面检测</button>
<button class="green" onclick="run('fixen')">修复为英文+纽约</button>
<button class="orange" onclick="run('fixzh')">切回中文+北京</button>
<button class="gray" onclick="run('claude')">Claude客户端检查</button>
<button class="gray" onclick="fetch('/api/report',{method:'POST'})">打开铁证报告</button>
</div>
<div id="result"><div class="card">点击上方按钮开始。修复/切回需要管理员权限，会弹出 UAC 授权窗口。</div></div>
<div class="note">· 检测不需要管理员；修复/切回自动请求管理员。<br>· WebRTC 防泄露策略已内置（browserscan 将不再显示国内真实 IP）。<br>· 本页面由本地服务提供，不经过任何外部服务器。</div>
</div>
<script>
async function run(a){
  var r=document.getElementById('result');
  r.innerHTML='<div class="card">执行中'+(a==='fixen'||a==='fixzh'?'（等待 UAC 授权）':'')+'...</div>';
  try{
    var res=await fetch('/api/'+a,{method:'POST'});
    var t=await res.text();
    r.innerHTML=t;
  }catch(e){ r.innerHTML='<div class="card" style="color:var(--bad)">请求失败: '+e.message+'</div>'; }
}
</script></body></html>
'@

function Find-Chrome {
    $cands = @('C:\Program Files\Google\Chrome\Application\chrome.exe','C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',(Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'),'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe','C:\Program Files\Microsoft\Edge\Application\msedge.exe')
    foreach ($c in $cands) { if (Test-Path $c) { return $c } }
    return $null
}

function Get-HeadlessDom($chromePath, $url, $timeoutSec) {
    $tmpDir = Join-Path $env:TEMP ('hd_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
    $out = Join-Path $tmpDir 'out.txt'
    $q = [char]34
    $argsStr = '--headless=new --no-sandbox --disable-gpu --no-first-run --user-data-dir=' + $q + $tmpDir + $q + ' --virtual-time-budget=' + $timeoutSec + ' --dump-dom ' + $q + $url + $q
    $p = Start-Process -FilePath $chromePath -ArgumentList $argsStr -PassThru -WindowStyle Hidden -RedirectStandardOutput $out -RedirectStandardError (Join-Path $tmpDir 'err.txt')
    $done = $p.WaitForExit($timeoutSec * 1000 + 5000)
    if (-not $done) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
    $dom = ''
    for ($i = 0; $i -lt 12; $i++) {
        try { if (Test-Path $out) { $dom = [System.IO.File]::ReadAllText($out, [System.Text.Encoding]::UTF8); break } } catch { Start-Sleep -Milliseconds 500 }
        Start-Sleep -Milliseconds 500
    }
    Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    return $dom
}

function Get-BrowserEvidence($chromePath) {
    $result = @{}
    if (-not $chromePath) { return $result }
    $tmpHtml = Join-Path $env:TEMP ('fp_' + [guid]::NewGuid().ToString('N') + '.html')
    $html = '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body><script>document.title=(navigator.language||"")+"|"+(navigator.languages||[]).join(",")+"|"+(Intl.DateTimeFormat().resolvedOptions().timeZone||"")+"|"+new Date().getTimezoneOffset();document.body.textContent=document.title;</script></body></html>'
    [System.IO.File]::WriteAllText($tmpHtml, $html, (New-Object System.Text.UTF8Encoding($false)))
    $dom = Get-HeadlessDom $chromePath ('file:///' + $tmpHtml.Replace('\','/')) 8000
    Remove-Item -LiteralPath $tmpHtml -Force -ErrorAction SilentlyContinue
    $mT = [regex]::Match($dom, '<title>(.*?)</title>')
    $t = if ($mT.Success) { $mT.Groups[1].Value } else { '' }
    $parts = $t -split '\|'
    $result['language'] = if ($parts.Count -gt 0) { $parts[0] } else { '' }
    $result['languages'] = if ($parts.Count -gt 1) { $parts[1] } else { '' }
    $result['tz'] = if ($parts.Count -gt 2) { $parts[2] } else { '' }
    $result['offset'] = if ($parts.Count -gt 3) { $parts[3] } else { '' }
    return $result
}

function Get-ExitMultiDB {
    $rows = @()
    try { $a = Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 8 -ErrorAction Stop; $rows += [pscustomobject]@{ Db='ipinfo'; IP=$a.ip; Country=$a.country; Loc="$($a.city),$($a.region)"; Tz=$a.timezone } } catch {}
    try { $b = Invoke-RestMethod -Uri 'http://ip-api.com/json/?fields=status,query,country,regionName,city,timezone' -TimeoutSec 8 -ErrorAction Stop; if ($b.status -eq 'success') { $rows += [pscustomobject]@{ Db='ip-api'; IP=$b.query; Country=$b.country; Loc="$($b.city),$($b.regionName)"; Tz=$b.timezone } } } catch {}
    return $rows
}

function Collect-Evidence {
    $ev = @()
    $tz = (tzutil /g) -join ''
    $ev += [pscustomobject]@{ L='系统'; I='时区'; E=$tz; S=$(if ($tz -eq 'Eastern Standard Time') { $OK } elseif ($tz -eq 'China Standard Time') { $WARN } else { $BAD }) }
    $culture = (Get-Culture).Name
    $ev += [pscustomobject]@{ L='系统'; I='区域格式'; E=$culture; S=$(if ($culture -eq 'en-US') { $OK } else { $BAD }) }
    $sysReg = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\Language' -ErrorAction SilentlyContinue).Default
    $sysLive = (Get-WinSystemLocale).Name
    $sysSt = if ($sysReg -eq '0409' -and $sysLive -eq 'en-US') { $OK } elseif ($sysReg -eq '0409') { $WARN } else { $BAD }
    $ev += [pscustomobject]@{ L='系统'; I='系统区域'; E="注册表=$sysReg 运行态=$sysLive"; S=$sysSt }
    $ui = Get-WinUILanguageOverride
    $uiName = if ($ui) { $ui.Name } else { '无' }
    $ev += [pscustomobject]@{ L='系统'; I='显示语言'; E=$uiName; S=$(if ($uiName -eq 'en-US') { $OK } else { $BAD }) }
    $langs = Get-WinUserLanguageList
    $first = ($langs | Select-Object -First 1).LanguageTag
    $ev += [pscustomobject]@{ L='系统'; I='语言列表首位'; E=$first; S=$(if ($first -eq 'en-US') { $OK } else { $BAD }) }
    $mui = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MUI\UILanguages\en-US'
    $ev += [pscustomobject]@{ L='系统'; I='en-US语言包'; E=$(if ($mui) { '已安装' } else { '未安装' }); S=$(if ($mui) { $OK } else { $BAD }) }
    $root = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data'
    $confs = @()
    Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile*' } | Sort-Object { if ($_.Name -eq 'Default') { 0 } else { 1 } } | ForEach-Object {
        $f = Join-Path $_.FullName 'Preferences'
        if (Test-Path $f) { $raw = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8); $m = [regex]::Match($raw, '"selected_languages"\s::\s*"([^"]*)"'); $confs += $(if ($m.Success) { $m.Groups[1].Value } else { '?' }) }
    }
    $allEn = ($confs | Where-Object { $_ -notmatch '^en-US' }).Count -eq 0
    $ev += [pscustomobject]@{ L='浏览器'; I='Chrome语言'; E=(($confs | Select-Object -Unique) -join '; '); S=$(if ($confs.Count -gt 0 -and $allEn) { $OK } else { $BAD }) }
    $chromePath = Find-Chrome
    if ($chromePath) {
        $be = Get-BrowserEvidence $chromePath
        $langE = if ($be['language'] -eq '') { '未能获取(请普通权限运行)' } else { $be['language'] }
        $langS = if ($be['language'] -eq '') { $WARN } elseif ($be['language'] -eq 'en-US') { $OK } else { $BAD }
        $ev += [pscustomobject]@{ L='浏览器'; I='实时语言'; E=$langE; S=$langS }
        $tzE = if ($be['tz'] -eq '') { '未能获取(请普通权限运行)' } else { $be['tz'] }
        $tzS = if ($be['tz'] -eq '') { $WARN } elseif ($be['tz'] -eq 'America/New_York') { $OK } else { $BAD }
        $ev += [pscustomobject]@{ L='浏览器'; I='实时时区'; E=$tzE; S=$tzS }
    } else { $ev += [pscustomobject]@{ L='浏览器'; I='实时指纹'; E='未找到Chrome'; S=$WARN } }
    $dns = @(Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddresses } | ForEach-Object { $_.ServerAddresses }) | Select-Object -Unique
    $cnDns = $dns | Where-Object { $_ -match '^(114\.114|223\.5\.5|119\.29\.29|180\.76\.76)' }
    $ev += [pscustomobject]@{ L='网络'; I='DNS'; E=($dns -join ','); S=$(if ($cnDns) { $BAD } else { $OK }) }
    $wrtcV = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'WebRTCIPHandlingPolicy' -ErrorAction SilentlyContinue).WebRTCIPHandlingPolicy
    if (-not $wrtcV) { $wrtcV = (Get-ItemProperty 'HKCU:\Software\Policies\Google\Chrome' -Name 'WebRTCIPHandlingPolicy' -ErrorAction SilentlyContinue).WebRTCIPHandlingPolicy }
    $ev += [pscustomobject]@{ L='网络'; I='WebRTC防泄露'; E=$(if ($wrtcV -eq 3) { '策略已启用(disable_non_proxied_udp)' } else { '未启用(会泄露真实IP)' }); S=$(if ($wrtcV -eq 3) { $OK } else { $BAD }) }
    $rows = Get-ExitMultiDB
    if ($rows.Count -gt 0) {
        $usCount = @($rows | Where-Object { $_.Country -match 'US|United' }).Count
        $nyCount = @($rows | Where-Object { $_.Tz -eq 'America/New_York' }).Count
        $ev += [pscustomobject]@{ L='网络'; I='出口IP'; E=(($rows | ForEach-Object { $_.IP }) -join '; '); S=$(if ($usCount -eq $rows.Count) { $OK } else { $BAD }) }
        $ev += [pscustomobject]@{ L='网络'; I='出口判纽约'; E="$nyCount/$($rows.Count) 库"; S=$(if ($nyCount -eq $rows.Count) { $OK } elseif ($nyCount -gt 0) { $WARN } else { $BAD }) }
    } else { $ev += [pscustomobject]@{ L='网络'; I='出口IP'; E='查询失败'; S=$WARN } }
    return $ev
}

function Claude-Check {
    $rows = @()
    $claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
    $rows += [pscustomobject]@{ I='Claude Code'; E=$(if ($claudeCmd) { '已安装: ' + $claudeCmd.Source } else { '未安装(仅检查环境)' }); S='INFO' }
    $claudeDir = Join-Path $env:USERPROFILE '.claude'
    $rows += [pscustomobject]@{ I='.claude 目录'; E=$(if (Test-Path $claudeDir) { '存在' } else { '不存在' }); S='INFO' }
    $rows += [pscustomobject]@{ I='终端时区(Claude继承)'; E=((tzutil /g) -join ''); S=$(if (((tzutil /g) -join '') -eq 'Eastern Standard Time') { $OK } else { $WARN }) }
    $rows += [pscustomobject]@{ I='终端区域'; E=(Get-Culture).Name; S=$(if ((Get-Culture).Name -eq 'en-US') { $OK } else { $WARN }) }
    $px = if ($env:HTTPS_PROXY) { $env:HTTPS_PROXY } elseif ($env:https_proxy) { $env:https_proxy } else { '未设置(走系统/路由器)' }
    $rows += [psustomobject]@{ I='HTTPPS代理'; E=$px; S='INFO' }
    $rows += [pscustomobject]@{ I='WebRTC策略'; E=$(if ((Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'WebRTCIPHandlingPolicy' -ErrorAction SilentlyContinue).WebRTCIPHandlingPolicy -eq 3) { '已启用' } else { '未启用' }); S='INFO' }
    return $rows
}

function Save-Report($ev) {
    $self = $env:SELF
    $repDir = Join-Path (Split-Path $self -Parent) '铁证报告'
    New-Item -ItemType Directory -Force -Path $repDir | Out-Null
    $repFile = Join-Path $repDir ('铁证报告_' + (Get-Date).ToString('yyyyMMdd_HHmmss') + '.txt')
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('铁证报告 - 环境伪装证据链  时间: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))
    foreach ($e in $ev) { $lines.Add(('[{0}] {1} | {2} | {3}' -f $e.L, $e.S, $e.I, $e.E)) }
    $fails = @($ev | Where-Object { $_.S -eq $BAD }).Count
    $lines.Add('判定: ' + $(if ($fails -eq 0) { 'PASS' } else { $fails.ToString() + ' 项 FAIL' }))
    [System.IO.File]::WriteAllLines($repFile, $lines, (New-Object System.Text.UTF8Encoding($true)))
    return $repFile
}

function Format-EvHtml($ev) {
    $sb = New-Object System.Text.StringBuilder
    $fails = @($ev | Where-Object { $_.S -eq $BAD }).Count
    $warns = @($ev | Where-Object { $_.S -eq $WARN }).Count
    if ($fails -eq 0 -and $warns -eq 0) { [void]$sb.Append('<div class="verdict v-ok">铁证判定：全部 PASS，环境伪装成立</div>') }
    elseif ($fails -eq 0) { [void]$sb.Append(('<div class="verdict v-warn">核心 PASS，' + $warns + ' 项留意（多为数据库分歧/待重启）</div>')) }
    else { [void]$sb.Append(('<div class="verdict v-bad">' + $fails + ' 项 FAIL，铁证不成立，请先点「修复为英文+纽约」</div>')) }
    [void]$sb.Append('<div class="card">')
    foreach ($e in $ev) {
        $cls = if ($e.S -eq 'PASS') { 'b-ok' } elseif ($e.S -eq 'WARN') { 'b-warn' } elseif ($e.S -eq 'FAIL') { 'b-bad' } else { 'b-info' }
        [void]$sb.Append(('<div class="row"><span class="k">' + $e.I + '</span><span class="v">' + $e.E + ' <span class="badge ' + $cls + '">' + $e.S + '</span></span></div>'))
    }
    [void]$sb.Append('</div>')
    return $sb.ToString()
}

function Build-FixScript($action, $resultFile) {
    $tz = if ($action -eq 'fixen') { 'Eastern Standard Time' } else { 'China Standard Time' }
    $culture = if ($action -eq 'fixen') { 'en-US' } else { 'zh-CN' }
    $langList = if ($action -eq 'fixen') { 'en-US,zh-CN' } else { 'zh-CN,en-US' }
    $chromeVal = if ($action -eq 'fixen') { 'en-US,en,zh-CN' } else { 'zh-CN,zh,en-US' }
    $geo = if ($action -eq 'fixen') { 244 } else { 45 }
    $body = @'
$ErrorActionPreference = 'Continue'
tzutil /s '__TZ__'
Set-Culture '__CULTURE__'
Set-WinUserLanguageList __LANG__ -Force
Set-WinUILanguageOverride '__CULTURE__'
try { Set-WinSystemLocale '__CULTURE__' } catch {}
Set-WinHomeLocation -GeoId __GEO__
if (-not (Test-Path 'HKLM:SYSTEMCurrentControlSetControlMUIUILanguagesen-US')) { try { Install-Language en-US } catch { try { Add-WindowsCapability -Online -Name 'Language.Basic~~~en-US~~~0.0.1.0' } catch {} } }
New-Item 'HKLM:SOFTWAREPoliciesGoogleChrome' -Force | Out-Null
Set-ItemProperty 'HKLM:SOFTWAREPoliciesGoogleChrome' -Name 'WebRTCIPHandlingPolicy' -Value 3 -Type DWord
New-Item 'HKCU:SoftwarePoliciesGoogleChrome' -Force | Out-Null
Set-ItemProperty 'HKCU:SoftwarePoliciesGoogleChrome' -Name 'WebRTCIPHandlingPolicy' -Value 3 -Type DWord
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$root = Join-Path $env:LOCALAPPDATA 'GoogleChromeUser Data'
Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile*' } | ForEach-Object {
  $f = Join-Path $_.FullName 'Preferences'
  if (Test-Path $f) {
    $raw = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
    $new = [regex]::Replace($raw, '"selected_languages"s*:s*"[^"]*"', '"selected_languages":"__CHROME__"')
    $new = [regex]::Replace($new, '"accept_languages"s::s*"[^"]*"', '"accept_languages":"__CHROME__"')
    if ($new -ne $raw) { [IO.File]::WriteAllText($f, $new, (New-Object Text.UTF8Encoding($false))) }
  }
}
'FIX_OK' | Out-File -LiteralPath '__RESULT__' -Encoding utf8
'@
    return $body.Replace('__TZ__', $tz).Replace('__CULTURE__', $culture).Replace('__LANG__', $langList).Replace('__GEO__', [string]$geo).Replace('__CHROME__', $chromeVal).Replace('__RESULT__', $resultFile)
}

function Invoke-Elevated($action) {
    $resultFile = Join-Path $env:TEMP ('fixres_' + [guid]::NewGuid().ToString('N') + '.txt')
    $tmp = Join-Path $env:TEMP ('fixact_' + [guid]::NewGuid().ToString('N') + '.ps1')
    $script = Build-FixScript $action $resultFile
    [System.IO.File]::WriteAllText($tmp, $script, (New-Object System.Text.UTF8Encoding($true)))
    $label = if ($action -eq 'fixen') { '修复为英文+纽约' } else { '切回中文+北京' }
    try {
        $p = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$tmp) -Verb RunAs -PassThru -Wait
        Start-Sleep -Seconds 1
        if (Test-Path $resultFile) {
            $r = [System.IO.File]::ReadAllText($resultFile, [System.Text.Encoding]::UTF8).Trim()
            $msg = if ($r -eq 'FIX_OK') { '<div class="verdict v-ok">' + $label + ' 完成</div><div class="card">请重启 Chrome 后点「全面检测」复核。系统区域/显示语言重启电脑后完全生效。</div>' } else { '<div class="verdict v-warn">执行返回: ' + $r + '</div>' }
        } else { $msg = '<div class="verdict v-bad">执行失败或未授权（UAC 被取消？）</div>' }
    } catch { $msg = '<div class="verdict v-bad">' + $_.Exception.Message + '</div>' }
    Remove-Item -LiteralPath $tmp, $resultFile -Force -ErrorAction SilentlyContinue
    return $msg
}

function Get-FreePort {
    $l = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback, 0)
    $l.Start()
    $p = ($l.LocalEndpoint).Port
    $l.Stop()
    return $p
}

# ---------- 启动网页服务器 ----------
$port = Get-FreePort
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:' + $port + '/')
$listener.Start()
$uiUrl = 'http://127.0.0.1:' + $port + '/'
Write-Host ''
Write-Host '  伪装环境一键工具 - 网页控制台已启动'
Write-Host '  地址: ' + $uiUrl
Write-Host '  正在打开浏览器... 关闭本窗口即可退出服务。'
Start-Process $uiUrl
try { [System.IO.File]::WriteAllText((Join-Path $env:TEMP 'tz_ui_url.txt'), $uiUrl, (New-Object System.Text.UTF8Encoding($false))) } catch {}
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $path = $ctx.Request.Url.AbsolutePath
        $html = ''
        $ctype = 'text/html; charset=utf-8'
        if ($path -eq '/' -or $path -eq '/index.html') { $html = $uiHtml }
        elseif ($path -eq '/api/check') {
            $ev = Collect-Evidence
            $repFile = Save-Report $ev
            $html = (Format-EvHtml $ev) + '<div class="note">铁证报告: ' + $repFile + '</div>'
        }
        elseif ($path -eq '/api/claude') {
            $rows = Claude-Check
            $sb = New-Object System.Text.StringBuilder
            [void]$sb.Append('<div class="verdict v-warn">Claude Code 客户端伪装检查</div><div class="card">')
            foreach ($e in $rows) {
                $cls = if ($e.S -eq 'PASS') { 'b-ok' } elseif ($e.S -eq 'WARN') { 'b-warn' } else { 'b-info' }
                [void]$sb.Append(('<div class="row"><span class="k">' + $e.I + '</span><span class="v">' + $e.E + ' <span class="badge ' + $cls + '">' + $e.S + '</span></span></div>'))
            }
            [void]$sb.Append('</div><div class="note">提示：Claude 服务端的出口判定请看 https://ip.net.coffee/claude/ （应在纽约/美国）。Claude Code 本地终端继承上述时区/区域/代理设置。</div>')
            $html = $sb.ToString()
        }
        elseif ($path -eq '/api/fixen' -or $path -eq '/api/fixzh') {
            $action = if ($path -eq '/api/fixen') { 'fixen' } else { 'fixzh' }
            $html = Invoke-Elevated $action
        }
        elseif ($path -eq '/api/report') {
            $repDir = Join-Path (Split-Path $env:SELF -Parent) '铁证报告'
            if (Test-Path $repDir) { Start-Process $repDir }
            $html = '<div class="card">已打开铁证报告文件夹</div>'
        }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
        $ctx.Response.ContentType = $ctype
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {}
    $ctx.Response.Close()
}

