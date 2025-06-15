# PowerShell script to switch power schemes

while ($true) {
    # ��ʾ��ǰ����ĵ�Դ����
    $activeScheme = powercfg -getactivescheme
    Write-Host "��ǰ����ĵ�Դ������$activeScheme"
    Write-Host ""

    # ��ʾ�˵�
    Write-Host ""
    Write-Host "��ѡ��һ����Դ������"
    Write-Host "1. ׿Խ����"
    Write-Host "2. ������"
    Write-Host "3. ƽ��"
    Write-Host "4. ����"

    # ��ȡ�û�����
    $choice = Read-Host "������1-4"

    # �����û�����ִ�в���
    switch ($choice) {
        "1" {
            # ׿Խ���ܣ����Ʒ�������ȡ��GUID
            $output = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
            $guid = ($output | Select-String "��Դ���� GUID: (.+?) ").Matches.Groups[1].Value
            if ($guid) {
                powercfg -setactive $guid
                Write-Host "���л���׿Խ����"
            } else {
                Write-Host "�޷���ȡ׿Խ���ܷ�����GUID"
            }
        }
        "2" {
            # �����ܣ����Ʒ�������ȡ��GUID
            $output = powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            $guid = ($output | Select-String "��Դ���� GUID: (.+?) ").Matches.Groups[1].Value
            if ($guid) {
                powercfg -setactive $guid
                Write-Host "���л���������"
            } else {
                Write-Host "�޷���ȡ�����ܷ�����GUID"
            }
        }
        "3" {
            # ƽ�⣺���Ʒ�������ȡ��GUID
            $output = powercfg -duplicatescheme 381b4222-f694-41f0-9685-ff5bb260df2e
            $guid = ($output | Select-String "��Դ���� GUID: (.+?) ").Matches.Groups[1].Value
            if ($guid) {
                powercfg -setactive $guid
                Write-Host "���л���ƽ��"
            } else {
                Write-Host "�޷���ȡƽ�ⷽ����GUID"
            }
        }
        "4" {
            # ���ܣ����Ʒ�������ȡ��GUID
            $output = powercfg -duplicatescheme a1841308-3541-4fab-bc81-f71556f20b4a
            $guid = ($output | Select-String "��Դ���� GUID: (.+?) ").Matches.Groups[1].Value
            if ($guid) {
                powercfg -setactive $guid
                Write-Host "���л�������"
            } else {
                Write-Host "�޷���ȡ���ܷ�����GUID"
            }
        }
        default {
            Write-Host "��Ч�����룬������1-4"
        }
    }

    # ��ʾ��ǰ����ĵ�Դ����
    $activeScheme = powercfg -getactivescheme
    Write-Host "��ǰ����ĵ�Դ������$activeScheme"
    Write-Host ""
}