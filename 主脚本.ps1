# ����Ƿ��Թ���Ա�������
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "�������Թ���Ա������д˽ű���" -ForegroundColor Red
    Write-Host "`n�� Enter ���˳�" -ForegroundColor Red
    Read-Host
    exit
}

# ��ȡ��ǰ�ű���Ŀ¼
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Ŀ���������
$processNames = @("SGuardSvc64", "SGuard64", "ACE-Tray")

# Ŀ��������ƣ�ʹ�� DisplayName����ȷ�ϣ�
$serviceNames = @("AntiCheatExpert Service", "AntiCheatExpert Protection")

# ��� wmic ������
$wmicAvailable = $true
try {
    & wmic /? | Out-Null
} catch {
    $wmicAvailable = $false
    Write-Host "���棺wmic �����ã�I/O ���ȼ����úͲ�����ֹ�����������ޡ�`n���������� PowerShell 7 ��ʹ�õ��������ߣ��� Process Lasso����" -ForegroundColor Yellow
}

Write-Host "`n=== ��ʼ������� ===" -ForegroundColor Cyan
# ֹͣ��ط���
foreach ($service in $serviceNames) {
    Write-Host "`n������: $service" -ForegroundColor White
    $svc = Get-Service -DisplayName $service -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.Status -eq "Running") {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction Stop
                Write-Host "��ֹͣ����: $service" -ForegroundColor Green
            } catch {
                Write-Host "�޷�ֹͣ���� ${service}: $($_.Exception.Message)`n�������Ȩ�޻�״̬��" -ForegroundColor Yellow
            }
        }
        try {
            Set-Service -Name $svc.Name -StartupType Manual -ErrorAction Stop
            Write-Host "�ѽ����� ${service} ��������������Ϊ�ֶ�" -ForegroundColor Green
        } catch {
            Write-Host "�޷����÷��� ${service} ����������: $($_.Exception.Message)`n����������á�" -ForegroundColor Yellow
        }
    } else {
        Write-Host "δ�ҵ�����: $service`n���� services.msc ��ȷ�Ϸ��� DisplayName��" -ForegroundColor Yellow
    }
}

Write-Host "`n=== ��ʼ������� ===" -ForegroundColor Cyan
# ��ȡ CPU ������
$cpuCount = [Environment]::ProcessorCount
# �������һ�� CPU �˵��׺�������
$lastCpuMask = [IntPtr] (1 -shl ($cpuCount - 1))
Write-Host "CPU ������: $cpuCount, ���һ�� CPU ��: $($cpuCount - 1), ����: $lastCpuMask" -ForegroundColor White

# ����Ŀ�����
foreach ($name in $processNames) {
    # ����Ŀ�����
    $processes = Get-Process -Name $name -ErrorAction SilentlyContinue

    if ($processes) {
        foreach ($process in $processes) {
            Write-Host "`n�ҵ�����: $($process.Name), PID: $($process.Id)" -ForegroundColor White

            # ���� CPU �׺���Ϊ���һ�� CPU ��
            try {
                $process.ProcessorAffinity = $lastCpuMask
                Write-Host "�ѽ� $($process.Name) �� CPU �׺�������Ϊ CPU $($cpuCount - 1)" -ForegroundColor Green
            } catch {
                Write-Host "�޷����� $($process.Name) �� CPU �׺���: $($_.Exception.Message)`n������Ҫ����Ȩ�ޣ��� SYSTEM����" -ForegroundColor Yellow
            }

            # ���ý������ȼ�Ϊ�� (Idle)
            try {
                $process.PriorityClass = "Idle"
                Write-Host "�ѽ� $($process.Name) �����ȼ�����Ϊ�� (Idle)" -ForegroundColor Green
            } catch {
                Write-Host "�޷����� $($process.Name) �����ȼ�: $($_.Exception.Message)`n������Ҫ����Ȩ�ޡ�" -ForegroundColor Yellow
            }

            # ���� I/O ���ȼ�Ϊ�ǳ��� (Very Low)
            try {
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    # PowerShell 7+ �� Windows 10 1809+ ֧�� Set-ProcessIoPriority
                    Set-ProcessIoPriority -Id $process.Id -Priority VeryLow -ErrorAction Stop
                    Write-Host "�ѽ� $($process.Name) �� I/O ���ȼ�����Ϊ�ǳ��� (Very Low)" -ForegroundColor Green
                } elseif ($wmicAvailable) {
                    # ���˵� wmic
                    & wmic process where processid=$($process.Id) call setpriority 1
                    Write-Host "�ѽ� $($process.Name) �� I/O ���ȼ�����Ϊ�ǳ��� (Very Low, via wmic)" -ForegroundColor Green
                } else {
                    Write-Host "�޷����� $($process.Name) �� I/O ���ȼ���ϵͳ��֧�� wmic �� PowerShell �汾����`n�������� PowerShell ��ʹ�� Process Lasso��" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "�޷����� $($process.Name) �� I/O ���ȼ�: $($_.Exception.Message)`n������Ҫ����Ȩ�޻���������ߡ�" -ForegroundColor Yellow
            }

            Write-Host "`n������ֹ����: $($process.Name), PID: $($process.Id)" -ForegroundColor White
            # ���� 1: Stop-Process
            try {
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
                Write-Host "��ͨ�� Stop-Process �ɹ���ֹ $($process.Name)" -ForegroundColor Green
                continue
            } catch {
                Write-Host "Stop-Process �޷���ֹ $($process.Name): $($_.Exception.Message)" -ForegroundColor Yellow
            }

            # ���� 2: taskkill
            try {
                & taskkill /PID $($process.Id) /F
                Write-Host "��ͨ�� taskkill �ɹ���ֹ $($process.Name)" -ForegroundColor Green
                continue
            } catch {
                Write-Host "taskkill �޷���ֹ $($process.Name): $($_.Exception.Message)" -ForegroundColor Yellow
            }

            # ���� 3: wmic
            if ($wmicAvailable) {
                try {
                    & wmic process where processid=$($process.Id) call terminate
                    Write-Host "��ͨ�� wmic �ɹ���ֹ $($process.Name)" -ForegroundColor Green
                    continue
                } catch {
                    Write-Host "wmic �޷���ֹ $($process.Name): $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
        }
    } else {
        Write-Host "`nδ�ҵ�����: $name" -ForegroundColor Yellow
    }
}

Write-Host "`n=== ���ú͹رճ������ ===" -ForegroundColor Green
Write-Host "`nһ���Խű���ÿ����Ϸ�������Ȳ�Ҫ�� :��װace: �����ľܾ��������޷�ֹͣ���̣����� :��ȫ: ������Ϸ��Ȼ���ٵ���ű��ļ����еĵ� :ace kill����.bat: �������ܣ����������Ϸ�������棬��������ֹ���̻���������Ȼ���ڰ���ǰ��˵�Ĳ�����в�����`n��ǰ�汾 : 1.0.2`n�ű�û�и����������ű����������޸�bug֮��ģ��������`n����� : https://ftnknc.lanzouo.com/b0sxutpvc`n����:1eo8" -ForegroundColor Red

# ���ѡ��˵�
while ($true) {
    Write-Host "`n��ѡ��һ��ѡ�" -ForegroundColor Cyan
    Write-Host "1. ���� '���ĵ�Դ�ƻ�'"
    Write-Host "2. ���� '��������������'"
    Write-Host "3. �˳�"

    $choice = Read-Host "������1��2��3"

    switch ($choice) {
        "1" {
            # ���� '���ĵ�Դ�ƻ�.ps1'
            $powerScriptPath = Join-Path -Path $scriptDir -ChildPath "���ĵ�Դ�ƻ�.ps1"
            if (Test-Path -Path $powerScriptPath) {
                try {
                    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$powerScriptPath`"" -Verb RunAs -ErrorAction Stop
                    Write-Host "������ '���ĵ�Դ�ƻ�'" -ForegroundColor Green
                } catch {
                    Write-Host "�޷����� '���ĵ�Դ�ƻ�': $($_.Exception.Message)`n��ȷ���ļ�·����Ȩ�ޡ�" -ForegroundColor Yellow
                }
            } else {
                Write-Host "δ�ҵ� '���ĵ�Դ�ƻ�' �ļ�: $powerScriptPath`n��ȷ���ļ��Ƿ�����ڽű�Ŀ¼�С�" -ForegroundColor Yellow
            }
        }
        "2" {
            # ���� '��������������.ps1'
            $antiCheatScriptPath = Join-Path -Path $scriptDir -ChildPath "��������������.ps1"
            if (Test-Path -Path $antiCheatScriptPath) {
                try {
                    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$antiCheatScriptPath`"" -Verb RunAs -ErrorAction Stop
                    Write-Host "������ '��������������'" -ForegroundColor Green
                } catch {
                    Write-Host "�޷����� '��������������': $($_.Exception.Message)`n��ȷ���ļ�·����Ȩ�ޡ�" -ForegroundColor Yellow
                }
            } else {
                Write-Host "δ�ҵ� '��������������' �ļ�: $antiCheatScriptPath`n��ȷ���ļ��Ƿ�����ڽű�Ŀ¼�С�" -ForegroundColor Yellow
            }
        }
        "3" {
            # �˳��ű�
            Write-Host "�˳��ű�" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "��Ч�����룬������1��2��3" -ForegroundColor Red
        }
    }
}