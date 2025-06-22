# ������ԱȨ��
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "���Թ���Ա������д˽ű���" -ForegroundColor Red
    Pause
    Exit
}

# ����Ŀ������б����������ķ���
$services = @(
    "ACE-BASE",
    "ace-game",
    "ace-game-0",
    "TesSafe",
    "AntiCheatExpert Protection",
    "AntiCheatExpert Service",
    "ACE-CORE302706"
)

# �˵�����
function Show-Menu {
    Clear-Host
    Write-Host "��������Ϊ���� (Disabled)" -ForegroundColor Red
    Write-Host ""
    Write-Host ""
    Write-Host "===== �����׷��������������� =====" -ForegroundColor Cyan
    Write-Host "1. ����Ϊ�ֶ����� (Manual)"
    Write-Host "2. ����Ϊ���� (Disabled)"
    Write-Host "3. �˳�"
    Write-Host "=================================" -ForegroundColor Cyan
}

# ��ѭ��
while ($true) {
    Show-Menu
    $choice = Read-Host "��ѡ����� (1-3)"
    
    switch ($choice) {
        "1" {
            # ����Ϊ�ֶ�����
            foreach ($service in $services) {
                try {
                    Set-Service -Name $service -StartupType Manual -ErrorAction Stop
                    Write-Host "������ [$service] Ϊ�ֶ�����" -ForegroundColor Green
                } catch {
                    Write-Host "�޷����� [$service]�����ܷ��񲻴��ڻ�Ȩ�޲���" -ForegroundColor Red
                }
            }
            Pause
        }
        "2" {
            # ����Ϊ����
            foreach ($service in $services) {
                try {
                    Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
                    Write-Host "������ [$service] Ϊ����" -ForegroundColor Green
                } catch {
                    Write-Host "�޷����� [$service]�����ܷ��񲻴��ڻ�Ȩ�޲���" -ForegroundColor Red
                }
            }
            Pause
        }
        "3" {
            # �˳��ű�
            Exit
        }
        default {
            Write-Host "��Ч���룬������ѡ��" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}