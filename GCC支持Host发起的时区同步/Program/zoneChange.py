import ntsecuritycon
import win32api
import win32security


def AdjustPrivilege(priv):
    flags = ntsecuritycon.TOKEN_ADJUST_PRIVILEGES | ntsecuritycon.TOKEN_QUERY
    htoken = win32security.OpenProcessToken(win32api.GetCurrentProcess(), flags)
    id = win32security.LookupPrivilegeValue(None, priv)
    newPrivileges = [(id, ntsecuritycon.SE_PRIVILEGE_ENABLED)]
    win32security.AdjustTokenPrivileges(htoken, 0, newPrivileges)


deBug = False
deBug_Zone = False
if deBug:
    # 显示当前时区
    print(win32api.GetTimeZoneInformation())
    if deBug_Zone:
        win32api.SetTimeZoneInformation(
            (-480, '中国标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '中国夏令时', (0, 0, 0, 0, 0, 0, 0, 0), 0))
        print(win32api.GetTimeZoneInformation())



