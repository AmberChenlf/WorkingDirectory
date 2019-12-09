*** Settings ***
Library           Telnet
Library           SSHLibrary
Library           supportLibrary/support.py
Library           FtpLibrary
Library           String

*** Variables ***
${ip}             192.168.3.42    # 设备ip
${mask}           255.255.255.0
${gateway}        192.168.3.1    #网关
${ip2}            192.168.3.23    #可配置ip
${versionInfo}    v1.0.4 build-2019/11/22 18:26:03   #版本信息
${ModuleOnLine}    1    #在位模块个数
${switchIp}       192.168.3.44    #交换机ip
@{switchPort}     xe-1/1
${version}        v1.0.4
${switchUser}    admin     #交换机用户名
${switchPwd}     admin     #交换机密码

*** Test Cases ***
1.2.1.1_FanAutoSet(2min)
    [Documentation]    purpose：配置风扇自动模式
    :FOR    ${i}    IN RANGE    100
    \    opentheconnection    ${ip}
    \    Telnet.write    global fan_control auto
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_control:auto
    \    Telnet.write    show slot 1
    \    ${slotInfo}    Telnet.read until    sysadmin(config)#
    \    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    \    log    ${slot}
    \    should not contain     ${slot}    :0rpm
    \    should not contain     ${slot}    rpm0rpm
    \    comment     自动模式下设置风扇转速
    \    Telnet.write    global fan_speed 100
    \    ${errorInfo}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${errorInfo}    ERROR: fan control auto.
    \    Telnet.close connection
1.2.1.2_FanManualSet(2min)
    [Documentation]    purpose：配置风扇手动模式
    ${sleep}    set variable    10
    :FOR    ${i}    IN RANGE    2
    \    opentheconnection    ${ip}
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    sleep    ${sleep}
    \    Telnet.write    global fan_control manual
    \    Telnet.read until    sysadmin(config)#
    \    sleep    ${sleep}
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_control:manual
    \    Telnet.write    show slot 1
    \    ${slotInfo}    Telnet.read until    sysadmin(config)#
    \    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    \    log    ${slot}
    \    should not contain     ${slot}    :0rpm
    \    should not contain     ${slot}    rpm0rpm
    \    comment     设置风扇转速
    \    Telnet.write    global fan_speed 0
    \    Telnet.read until    sysadmin(config)#
    \    sleep    ${sleep}
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_speed:0
    \    Telnet.write    show slot 1
    \    ${slotInfo}    Telnet.read until    sysadmin(config)#
    \    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    \    log    ${slot}
    \    should contain x times    ${slot}    0rpm    6
    \    comment    设置风扇转速为100
    \    Telnet.write    global fan_speed 100
    \    Telnet.read until    sysadmin(config)#
    \    sleep    ${sleep}
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_speed:100
    \    Telnet.write    show slot 1
    \    ${slotInfo}    Telnet.read until    sysadmin(config)#
    \    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    \    log    ${slot}
    \    GetFanSpeed     ${slot}    5000
    \    comment    设置风扇转速为255
    \    Telnet.write    global fan_speed 255
    \    Telnet.read until    sysadmin(config)#
    \    sleep    ${sleep}
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_speed:255
    \    Telnet.write    show slot 1
    \    ${slotInfo}    Telnet.read until    sysadmin(config)#
    \    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    \    log    ${slot}
    \    GetFanSpeed     ${slot}    13333
    \    Telnet.write    global fan_speed 256
    \    ${errorInfo}=   Telnet.read until    sysadmin(config)#
    \    should contain    ${errorInfo}    ERROR
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_speed:255
    \    comment    恢复自动调速
    \    Telnet.write    global fan_control auto
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show global
    \    ${globalInfo}    Telnet.read until    sysadmin(config)#
    \    ${global}    replace string    ${globalInfo}    ${SPACE}    ${EMPTY}
    \    should contain    ${global}     fan_control:auto
    \    Telnet.close connection
1.2.1.3_FanSpeedChangeWithTem(3seconds)
    [Documentation]    风扇转速随温度的转变
    opentheconnection    ${ip}
    Telnet.write     global fan_control auto
    Telnet.read until    sysadmin(config)#
    sleep    10
    Telnet.write     show slot 1
    ${slotInfo}    Telnet.read until    sysadmin(config)#
    ${slot}    replace string    ${slotInfo}    ${SPACE}    ${EMPTY}
    log    ${slot}
    ${Tem1}    getStringInfo    ${slot}    temperature1:   C
    ${Tem2}    getStringInfo    ${slot}    temperature2:   C
    run keyword if     ${Tem1[0]}<=30    getfanspeed    ${slot}    4000
    run keyword if     30<${Tem1[0]}<40     getfanspeed    ${slot}   5000
    run keyword if     40<${Tem1[0]}<50     getfanspeed    ${slot}   6000
    run keyword if     50<${Tem1[0]}<60     getfanspeed    ${slot}   9000
    run keyword if     60<${Tem1[0]}    getfanspeed    ${slot}   11000
    run keyword if     ${Tem2[0]}<=30    getfanspeed    ${slot}    4000
    run keyword if     30<${Tem2[0]}<40     getfanspeed    ${slot}   5000
    run keyword if     40<${Tem2[0]}<50     getfanspeed    ${slot}   6000
    run keyword if     50<${Tem2[0]}<60     getfanspeed    ${slot}   9000
    run keyword if     60<${Tem2[0]}    getfanspeed    ${slot}   11000
    Telnet.close connection
1.2.2_portInfo
    [documentation]    端口信息读取
    opentheconnection    ${ip}
    Telnet.write    show interface
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain x times    ${info}    sn    ${ModuleOnLine}
    @{powerlist}=    getStringInfo    ${info}    op:    dBm
    checkIopAndOop    @{powerlist}
    ${name1}=    getStringInfo    ${info}    n:    pn
    ${pn1}=    getStringInfo    ${info}    pn:    sn
    ${sn1}=    getStringInfo    ${info}    sn:    rev
    : FOR    ${i}    IN RANGE    2
    \    Telnet.write    show interface
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain x times    ${info}    oop    ${ModuleOnLine}
    \    @{powerlist}=    getStringInfo    ${info}    op:    dBm
    \    checkIopAndOop    @{powerlist}
    \    ${name}=    getStringInfo    ${info}    n:    pn
    \    ${pn}=    getStringInfo    ${info}    pn:    sn
    \    ${sn}=    getStringInfo    ${info}    sn:    rev
    \    should be equal    ${name1}    ${name}
    \    should be equal    ${pn1}    ${pn}
    \    should be equal    ${sn1}    ${sn}
    \    @{perList}=    split to lines    ${info}
    \    showInterfaceId    @{perList}
    Telnet.close all connections
1.3_PwrInfomation(1seconds)
    [Documentation]    电源信息读取 需要两个电源在线
    opentheconnection    ${ip}
    Telnet.write    show slot 1
    ${info}=    Telnet.read until    sysadmin(config)#
    ${info5}=    get line     ${info}    5
    should contain    ${info5}    power-id
    ${info8}=    get line     ${info}    8
    should contain    ${info8}    fanmodule1
    ${pwr1info}=    get line     ${info}    6
    should not contain    ${pwr1info}    ${SPACE}0.00${SPACE}
    ${pwr2info}=    get line     ${info}    7
    should not contain    ${pwr2info}    ${SPACE}0.00${SPACE}

    log    ${pwr1info}
    log    ${pwr2info}
    Telnet.close connection
2.1_ETHERNETPort(2min)
    [Documentation]   ETHERNET端口测试
    opentheconnection    ${ip}
    :For    ${i}   IN RANGE    10
    \    Telnet.write    \t
    \    ${info}    Telnet.read
    \    should contain    ${info}    show
    \    log    ${info}
    \    sleep    15
    Telnet.close connection
3.1_CommandLineTest
    [Documentation]    命令行测试：输入错误命令有提示
    opentheconnection    ${ip}
    :FOR    ${i}    IN RANGE    15
    \    ${err}    generate random string    12
    \    Telnet.write    ${err}
    \    ${error}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${error}    ERROR: Error command
    \    comment    输入show+tab/show+随机生成字符串
    \    Telnet.write bare   show \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     version
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    输入global+tab/global+随机生成字符串
    \    Telnet.write bare    global \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     fan_speed
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    输入clear+tab/clear+随机生成字符串
    \    Telnet.write bare   clear \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    输入interface+tab/interface+随机生成字符串
    \    Telnet.write bare   interface \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    输入reboot+tab/reboot+随机生成字符串
    \    Telnet.write bare   reboot \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     cold
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    输入exit/输入config
    \    Telnet.write    exit
    \    ${show}    Telnet.read until    sysadmin#
    \    should not contain    ${show}     ERROR
    \    Telnet.write    config
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    comment    restore+tab/restore+随机字符串
    \    Telnet.write bare   restore${SPACE}\t
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write bare   \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}    default
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    save+tab/save+随机字符串
    \    Telnet.write bare   save \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     save
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    terminal+tab/terminal+随机字符串
    \    Telnet.write bare   terminal${SPACE}\t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     length
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    undo+tab/undo+随机字符串
    \    Telnet.write bare   undo \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     global
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    \    comment    update+tab/update+随机字符串
    \    Telnet.write bare   update${SPACE}\t
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write bare   \t
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should not contain    ${show}     ERROR
    \    should contain    ${show}     version
    \    Telnet.write    ${err}
    \    ${show}    Telnet.read until    sysadmin(config)#
    \    should contain    ${show}     ERROR
    Telnet.close connection
3.2_Show(1seconds)
    opentheconnection    ${ip}
    Telnet.write    show alarm current
    ${currentAlarm}    Telnet.read until    sysadmin(config)#
    should contain    ${currentAlarm}    AlmId
    should not contain    ${currentAlarm}    ERROR
    Telnet.write    show alarm history
    ${historyAlarm}    Telnet.read until    sysadmin(config)#
    should contain    ${historyAlarm}    AlmId
    should not contain    ${historyAlarm}    ERROR
    ${err}    generate random string    3
    Telnet.write    show alarm ${err}
    ${errInfo}    Telnet.read until    sysadmin(config)#
    should contain    ${errInfo}    ERROR

    Telnet.write    show boot-package
    ${info}    Telnet.read until    sysadmin(config)#
    should contain x times    ${info}    ${version}    2

    Telnet.write    show global
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    objidx
    should contain    ${info}    device_id
    should contain    ${info}    fan_control
    should contain    ${info}    ntp_update_time

    Telnet.write    show interface
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    id_index

    Telnet.write    show login-user
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    sysadmin

    Telnet.write    show login-user
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    sysadmin

    Telnet.write    show memory
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    Temporary memory

    Telnet.write    show running-config
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}    syslog local enable
    should contain    ${info}    global device_id
    should contain    ${info}    global fan_control
    should contain    ${info}    global ntp_update_time

    Telnet.write    show slot 1
    ${info}    Telnet.read until    sysadmin(config)#
    ${info}    replace string    ${info}    ${SPACE}    ${EMPTY}
    should contain    ${info}     lgtype:oeo10

    Telnet.write    show syslog
    ${info}    Telnet.read until    sysadmin(config)#
    ${info}    replace string    ${info}    ${SPACE}    ${EMPTY}
    should contain    ${info}     remote:disable

    Telnet.write    show systemtime
    ${info}    Telnet.read until    sysadmin(config)#
    should not contain    ${info}     ERROR

    Telnet.write    show terminal
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}     terminal length

    Telnet.write    show version
    ${info}    Telnet.read until    sysadmin(config)#
    should contain    ${info}     ${versionInfo}
    Telnet.close connection


3.3_setIpAddress
    [Documentation]    purpose:配置ip/mask/gateway
    ...    非法ip/msk/gateway的选择：非法字符和越界ip
    OpenTheConnection    ${ip}
    : FOR    ${i}    IN RANGE    10
    \    Telnet.write    show interface mgmt 1/1
    \    ${mgmtInfo}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${mgmtInfo}    ${ip}
    \    comment    配置非法ip地址
    \    ${s1}=    togenerateRandomString    3    3
    \    ${s2}=    togenerateRandomString    3    3
    \    ${s3}=    togenerateRandomString    3    3
    \    ${s4}=    togenerateRandomString    3    3
    \    Telnet.write    interface mgmt 1/1 ip ${s1}.${s2}.${s3}.${s4} mask 255.255.255.0 gateway 192.168.3.1
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    配置非法掩码
    \    Telnet.write    interface mgmt 1/1 ip ${ip2} mask ${s1}.${s2}.${s3}.${s4} gateway 192.168.3.1
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    配置非法网关
    \    Telnet.write    interface mgmt 1/1 ip ${ip2} mask 255.255.255.0 gateway ${s1}.${s2}.${s3}.${s4}
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    配置越界ip
    \    ${y1}=    evaluate    random.randint(255,999999999)    random
    \    ${y2}=    evaluate    random.randint(255,999999999)    random
    \    ${y3}=    evaluate    random.randint(255,999999999)    random
    \    ${y4}=    evaluate    random.randint(255,999999999)    random
    \    Telnet.write    interface mgmt 1/1 ip ${y1}.${y2}.${y3}.${y4} mask 255.255.255.0 gateway 192.168.3.1
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    配置非法掩码
    \    Telnet.write    interface mgmt 1/1 ip ${ip2} mask ${y1}.${y2}.${y3}.${y4} gateway 192.168.3.1
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    配置非法网关
    \    Telnet.write    interface mgmt 1/1 ip ${ip2} mask 255.255.255.0 gateway ${y1}.${y2}.${y3}.${y4}
    \    ${errMgmtInfo}    Telnet.read until    sysadmin(config)#
    \    should contain    ${errMgmtInfo}    ERROR
    \    comment    iP和网关不在同一网段
    \    Telnet.write    interface mgmt 1/1 ip ${ip} mask 255.255.255.0 gateway 192.168.4.1
    \    ${info}    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    ERROR
    : FOR    ${i}    IN RANGE    10
    \    comment    配置ip地址
    \    Telnet.write bare    interface mgmt 1/1 ip ${ip2} mask 255.255.255.0 gateway 192.168.3.1
    \    Telnet.write bare    ${\n}
    \    sleep    5
    \    Telnet.close connection
    \    OpenTheConnection    ${ip2}
    \    Telnet.write bare    interface mgmt 1/1 ip ${ip} mask 255.255.255.0 gateway 192.168.3.1
    \    Telnet.write bare    ${\n}
    \    sleep    5
    \    OpenTheConnection    ${ip}
    Telnet.close connection

3.4_Reboot
    [Documentation]    purpose:重启，查看版本信息、电源信息、流量是否正常,ip/网关是否正确
    setPortUpOnSwitch
    opentheconnection    ${ip}
    Telnet.write    restore default configuration
    Telnet.read until    sysadmin(config)#
    comment    版本信息查询
    Telnet.write    show version
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    ${versionInfo}
    Telnet.write    show slot
    ${info}=    Telnet.read until    sysadmin(config)#
    @{infoSplit}    splitBy    ${info}    ${\n}
    ${countPower1}=    get count    @{infoSplit}[6]    0.00
    ${countPower2}=    get count    @{infoSplit}[7]    0.00
    log    ${countPower1}
    log    ${countPower2}
    comment    reboot cold
    Telnet.write    reboot cold
    sleep    120
    opentheconnection    ${ip}
    Telnet.write    show version
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    ${versionInfo}
    Telnet.write    show slot
    ${info}=    Telnet.read until    sysadmin(config)#
    @{infoSplit}    splitBy    ${info}    ${\n}
    ${countPower1RebootCold}=    get count    @{infoSplit}[6]    0.00
    ${countPower2RebootCold}=    get count    @{infoSplit}[7]    0.00
    run keyword and continue on failure    should be equal as integers    ${countPower1}    ${countPower1RebootCold}
    run keyword and continue on failure    should be equal as integers    ${countPower2}    ${countPower2RebootCold}
    Telnet.write    show interface mgmt 1/1
    ${mgmtInfo}=    Telnet.read until    sysadmin(config)#
    should contain    ${mgmtInfo}    ${mask}
    should contain    ${mgmtInfo}    ${gateway}
    Telnet.write    show running-config
    ${configInfo}=    Telnet.read until    sysadmin(config)#
    should contain    ${configInfo}    global device_id 0
    comment    TODO 检查流量
    checkFlowOnSwitch
    comment    reboot warm
    Telnet.write    reboot warm
    sleep    120
    opentheconnection    ${ip}
    Telnet.write    show version
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    ${versionInfo}
    Telnet.write    show slot
    ${info}=    Telnet.read until    sysadmin(config)#
    @{infoSplit}    splitBy    ${info}    ${\n}
    ${countPower1RebootCold}=    get count    @{infoSplit}[6]    0.00
    ${countPower2RebootCold}=    get count    @{infoSplit}[7]    0.00
    run keyword and continue on failure    should be equal as integers    ${countPower1}    ${countPower1RebootCold}
    run keyword and continue on failure    should be equal as integers    ${countPower2}    ${countPower2RebootCold}
    comment    TODO 检查流量
    Telnet.write    show interface mgmt 1/1
    ${mgmtInfo}=    Telnet.read until    sysadmin(config)#
    should contain    ${mgmtInfo}    ${mask}
    should contain    ${mgmtInfo}    ${gateway}
    Telnet.write    show running-config
    ${configInfo}=    Telnet.read until    sysadmin(config)#
    should contain    ${configInfo}    global device_id 0
    comment    TODO 检查流量
    checkFlowOnSwitch
    Telnet.close all connections

3.5_Save
    [Documentation]    保存设置命令测试；更改风扇控制；
    :FOR    ${i}    IN RANGE    10
    \    opentheconnection    ${ip}
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    should contain    ${info}    global device_id 0
    \    Telnet.write    global fan_control manual
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    global fan_speed 100
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global device_id 0
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 100
    \    Telnet.write    save
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    reboot cold
    \    sleep    120
    \    opentheconnection    ${ip}
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global device_id 0
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 100
    \    Telnet.write    show interface mgmt 1/1
    \    ${ipInterface}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${ipInterface}    ${ip}
    \    should contain    ${ipInterface}    ${mask}
    \    should contain    ${ipInterface}    ${gateway}
    \    Telnet.write    reboot warm
    \    sleep    120
    \    opentheconnection    ${ip}
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 100
    \    Telnet.write    show interface mgmt 1/1
    \    ${ipInterface}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${ipInterface}    ${ip}
    \    should contain    ${ipInterface}    ${mask}
    \    should contain    ${ipInterface}    ${gateway}
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.close connection

3.6_Resotre
    [Documentation]    恢复出厂命令测试；更改风扇设置，再恢复；
    : FOR    ${i}    IN RANGE    10
    \    opentheconnection    ${ip}
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    Telnet.write    global fan_control manual
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    global fan_speed 100
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 100
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    save
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    Telnet.write    reboot cold
    \    sleep    120
    \    opentheconnection    ${ip}
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    Telnet.write    reboot warm
    \    sleep    120
    \    opentheconnection    ${ip}
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    Telnet.close connection

5.1_LosAlarm
    ${onLos}=    set variable    0
    opentheconnection    ${ip}
    Telnet.write    show alarm current
    ${alarmInfo}    Telnet.read until    sysadmin(config)#
    should not contain    ${alarmInfo}    Los
    Telnet.close connection
    comment    交换机端口down
    setPortDownOnSwitch
    opentheconnection    ${ip}
    Telnet.write    show alarm current
    ${alarmInfo}    Telnet.read until    sysadmin(config)#
    ${alarm}=    replace String    ${alarmInfo}    ${SPACE}    ${EMPTY}
    log    ${alarm
    Telnet.write    show interface
    ${info}=    Telnet.read until    sysadmin(config)#
    @{list}=    split to lines    ${info}
    : FOR    ${i}    IN    @{list}
    \    ${flag}=    containss    ${i}    iop:-30.00dBm
    \    continue for loop if    ${flag}==-1
    \    ${id}=    get substring    ${i}    0    1
    \    should contain    ${alarm}    Los1/${id}minor
    \    ${onLos}=    evaluate    ${onLos}+1
    run keyword and continue on failure    should contain x times    ${alarm}    Los    ${onLos}
    Telnet.close all connections
    setPortUpOnSwitch
    opentheconnection    ${ip}
    Telnet.write    show alarm current
    ${alarmInfo}    Telnet.read until    sysadmin(config)#
    should not contain    ${alarmInfo}    Los
    Telnet.close connection

5.2_LsrOffLineAlarm
    [Documentation]    模块不在位告警
    ${onLine}=    set variable    0
    opentheconnection    ${ip}
    Telnet.write    show alarm current
    ${alarmInfo}    Telnet.read until    sysadmin(config)#
    ${alarm}=    replace String    ${alarmInfo}    ${SPACE}    ${EMPTY}
    log    ${alarm}
    Telnet.write    show interface
    ${info}=    Telnet.read until    sysadmin(config)#
    @{list}=    split to lines    ${info}
    : FOR    ${i}    IN    @{list}
    \    ${flag}=    containss    ${i}    iop
    \    continue for loop if    ${flag}==-1
    \    @{interfaceList}=    split string    ${i}    ${SPACE}
    \    log    LsrOffline1/@{interfaceList}[0]minor
    \    should not contain    ${alarm}    LsrOffline1/@{interfaceList}[0]minor
    \    ${onLine}=    evaluate    ${onLine}+1
    ${offLine}=    evaluate    48-${onLine}
    should contain x times    ${alarm}    LsrOffline    ${offLine}
    Telnet.close all connections

5.4_FanAlarm
    : FOR    ${i}    IN RANGE    100
    \    opentheconnection    ${ip}
    \    Telnet.write    restore default configuration
    \    Telnet.read until    sysadmin(config)#
    \    sleep    15
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should not contain    ${info}    FanFail
    \    Telnet.write    global fan_control manual
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    global fan_speed 0
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 0
    \    sleep    15
    \    Telnet.write    show slot
    \    ${slotInfo}=    Telnet.read until    sysadmin(config)#
    \    log    ${slotInfo}
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain x times    ${info}    FanFail    3
    \    Telnet.write    global fan_control auto
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    sleep    15
    \    Telnet.write    show slot
    \    ${slotInfo}=    Telnet.read until    sysadmin(config)#
    \    log    ${slotInfo}
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should not contain    ${info}    FanFail
    \    Telnet.close all connections
5.7_CurrentAlarm
    [Documentation]    当前告警（主要是风扇告警）
    opentheconnection    ${ip}
    : FOR    ${i}    IN RANGE    10
    \    Telnet.write    global fan_control auto
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should not contain    ${info}    FanFail
    \    comment    设置风扇转速为0，出现风扇告警
    \    Telnet.write    global fan_control manual
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    global fan_speed 0
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control manual
    \    should contain    ${info}    global fan_speed 0
    \    sleep    15
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain x times    ${info}    FanFail    3
    \    Telnet.write    global fan_control auto
    \    Telnet.read until    sysadmin(config)#
    \    Telnet.write    show running-config
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    global fan_control auto
    \    sleep    15
    \    Telnet.write    show alarm current
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should not contain    ${info}    FanFail
    Telnet.close all connections
5.8_HistoryAlarm
    opentheconnection    ${ip}
    Telnet.write    restore default configuration
    Telnet.read until    sysadmin(config)#
    Telnet.write    clear alarm history
    Telnet.read until    sysadmin(config)#
    sleep    15
    Telnet.write    show alarm current
    ${info}=    Telnet.read until    sysadmin(config)#
    should not contain    ${info}    FanFail
    Telnet.write    global fan_control manual
    Telnet.read until    sysadmin(config)#
    Telnet.write    global fan_speed 0
    Telnet.read until    sysadmin(config)#
    Telnet.write    show running-config
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    global fan_control manual
    should contain    ${info}    global fan_speed 0
    sleep    15
    Telnet.write    show alarm current
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain x times    ${info}    FanFail    3
    Telnet.write    global fan_control auto
    Telnet.read until    sysadmin(config)#
    Telnet.write    show running-config
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    global fan_control auto
    sleep    15
    Telnet.write    show alarm current
    ${info}=    Telnet.read until    sysadmin(config)#
    should not contain    ${info}    FanFail
    Telnet.write    show alarm history
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain x times    ${info}    FanFail    3
    Telnet.close all connections

6.1_LongTimeRunStablity
    [Documentation]    长时间运行稳定性测试
    clearErrOnSwitch
    setPortUpOnSwitch
    opentheconnection    ${ip}
    comment    版本信息查询
    Telnet.write    show version
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain    ${info}    ${versionInfo}
    Telnet.write    show slot
    ${info}=    Telnet.read until    sysadmin(config)#
    @{infoSplit}    splitBy    ${info}    ${\n}
    ${countPower1}=    get count    @{infoSplit}[6]    0.00
    ${countPower2}=    get count    @{infoSplit}[7]    0.00
    log    ${countPower1}
    log    ${countPower2}
    Telnet.close connection
    : FOR    ${i}    IN RANGE    100
    \    opentheconnection    ${ip}
    \    Telnet.write    show version
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${info}    ${versionInfo}
    \    Telnet.write    show slot
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    @{infoSplit}    splitBy    ${info}    ${\n}
    \    ${countPower1RebootCold}=    get count    @{infoSplit}[6]    0.00
    \    ${countPower2RebootCold}=    get count    @{infoSplit}[7]    0.00
    \    comment    should be equal as integers    ${countPower1}    ${countPower1RebootCold}
    \    comment    should be equal as integers    ${countPower2}    ${countPower2RebootCold}
    \    Telnet.write    show interface mgmt 1/1
    \    ${mgmtInfo}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${mgmtInfo}    ${mask}
    \    should contain    ${mgmtInfo}    ${gateway}
    \    Telnet.write    show running-config
    \    ${configInfo}=    Telnet.read until    sysadmin(config)#
    \    should contain    ${configInfo}    global device_id 0
    \    Telnet.close connection
    \    comment    TODO 检查流量
    \    checkErrOnSwitch
    \    checkFlowOnSwitch
    \    sleep    15

6.3_RebootStability
    [Documentation]    重启稳定性测试
    : FOR    ${i}    IN RANGE    100
    \     clearErrOnSwitch
    \     opentheconnection    ${ip}
    \     comment    版本信息查询
    \     Telnet.write    show version
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     should contain    ${info}    ${versionInfo}
    \     Telnet.write    show slot
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     @{infoSplit}    splitBy    ${info}    ${\n}
    \     ${countPower1}=    get count    @{infoSplit}[6]    0.00
    \     ${countPower2}=    get count    @{infoSplit}[7]    0.00
    \     log    ${countPower1}
    \     log    ${countPower2}
    \     comment    reboot cold
    \     Telnet.write    reboot cold
    \     sleep    120
    \     opentheconnection    ${ip}
    \     Telnet.write    show version
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     should contain    ${info}    ${versionInfo}
    \     Telnet.write    show slot
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     @{infoSplit}    splitBy    ${info}    ${\n}
    \     ${countPower1RebootCold}=    get count    @{infoSplit}[6]    0.00
    \     ${countPower2RebootCold}=    get count    @{infoSplit}[7]    0.00
    \     comment    should be equal as integers    ${countPower1}    ${countPower1RebootCold}
    \     comment    should be equal as integers    ${countPower2}    ${countPower2RebootCold}
    \     Telnet.close connection
    \     comment    TODO 检查流量
    \     checkErrOnSwitch
    \     checkFlowOnSwitch
    \     comment    reboot warm
    \     opentheconnection    ${ip}
    \     Telnet.write    reboot warm
    \     sleep    120
    \     opentheconnection    ${ip}
    \     Telnet.write    show version
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     should contain    ${info}    ${versionInfo}
    \     Telnet.write    show slot
    \     ${info}=    Telnet.read until    sysadmin(config)#
    \     @{infoSplit}    splitBy    ${info}    ${\n}
    \     ${countPower1RebootCold}=    get count    @{infoSplit}[6]    0.00
    \     comment    ${countPower2RebootCold}=    get count    @{infoSplit}[7]    0.00
    \     comment    should be equal as integers    ${countPower1}    ${countPower1RebootCold}
    \     comment    should be equal as integers    ${countPower2}    ${countPower2RebootCold}
    \     Telnet.close all connections
    \     comment    TODO 检查流量
    \     checkErrOnSwitch
    \     checkFlowOnSwitch

6.7_ModuleInfoGet
    [Documentation]    光模块信息读取：循环读取，和上次读取比较是否相同
    opentheconnection    ${ip}
    Telnet.write    show interface
    ${info}=    Telnet.read until    sysadmin(config)#
    should contain x times    ${info}    oop    ${ModuleOnLine}
    @{powerlist}=    getStringInfo    ${info}    op:    dBm
    checkIopAndOop    @{powerlist}
    ${name1}=    getStringInfo    ${info}    n:    pn
    ${pn1}=    getStringInfo    ${info}    pn:    sn
    ${sn1}=    getStringInfo    ${info}    sn:    rev
    : FOR    ${i}    IN RANGE    100
    \    Telnet.write    show interface
    \    ${info}=    Telnet.read until    sysadmin(config)#
    \    should contain x times    ${info}    oop    ${ModuleOnLine}
    \    @{powerlist}=    getStringInfo    ${info}    op:    dBm
    \    checkIopAndOop    @{powerlist}
    \    ${name}=    getStringInfo    ${info}    n:    pn
    \    ${pn}=    getStringInfo    ${info}    pn:    sn
    \    ${sn}=    getStringInfo    ${info}    sn:    rev
    \    should be equal    ${name1}    ${name}
    \    should be equal    ${pn1}    ${pn}
    \    should be equal    ${sn1}    ${sn}
    \    @{perList}=    split to lines    ${info}
    \    showInterfaceId    @{perList}
    \    sleep    10
    Telnet.close all connections

6.8_SystemStability
    [Documentation]    管理系统稳定性
    :FOR    ${i}    IN RANGE    720
    \    opentheconnection    ${ip}
    \    SSHLibrary.open connection    ${ip}    \     22
    \    SSHLibrary.login    root    fa    user    password
    \    SSHLibrary.write     df -h
    \    ${info}=    SSHLibrary.read until     root@NanoPi-NEO-Core:~#
    \    should not contain    ${info}    100%
    \    SSHLibrary.close connection
    \    sleep    10
    \    Telnet.close connection


*** Keywords ***
GetFanSpeed
    [Arguments]    ${slot}    ${speed}
    ${true}=    convert to boolean    True
    @{oneGroup}=    getStringInfo    ${slot}    :    rpm
    @{twoGroup}=    getStringInfo    ${slot}    rpm    rpm
    :FOR    ${i}    IN     @{oneGroup}
    \    ${flag}=    evaluate    ${speed}-2000<${i}<${speed}+2000
    \    should be equal    ${flag}    ${true}
    :FOR    ${i}    IN     @{twoGroup}
    \    ${flag}=    evaluate    ${speed}-2000<${i}<${speed}+2000
    \    should be equal    ${flag}    ${true}

showInterfaceId
    [Arguments]    @{list}
    [Documentation]    show interface id 检查cftType/cfpInfo/support length/wave length/temperature
    : FOR    ${i}    IN    @{list}
    ${flag}=    containss    ${i}    iop
    continue for loop if    ${flag}==-1
    @{interfaceList}=    split string    ${i}    ${SPACE}
    Telnet.write    show interface 1/@{interfaceList}[0]
    ${interfaceInfo}=    Telnet.read until    sysadmin(config)#
    ${interfaceInfo}=    replace String    ${interfaceInfo}    ${SPACE}    ${EMPTY}
    should not contain    ${interfaceInfo}    cftType:unknown
    should not contain    ${interfaceInfo}    -NA-
    should not contain    ${interfaceInfo}    -inf
    should contain    ${interfaceInfo}    cfpInfo:vendor
    should contain    ${interfaceInfo}    supportlength    :Linklength

setPortDownOnSwitch
    [Documentation]    将交换机端口down掉
    telnetSwitch    ${switchIp}
    : FOR    ${i}    IN    @{switchPort}
    \    SSHLibrary.write    ovs-ofctl mod-port br0 ${i} down
    \    SSHLibrary.read until    admin@PICOS-OVS:~$
    \    sleep    0.2
    SSHLibrary.close connection

setPortUpOnSwitch
    [Documentation]    将交换机端口Up起来
    telnetSwitch    ${switchIp}
    : FOR    ${i}    IN    @{switchPort}
    \    SSHLibrary.write    ovs-ofctl mod-port br0 ${i} up
    \    SSHLibrary.read until    admin@PICOS-OVS:~$
    \    sleep    0.2
    SSHLibrary.close connection

checkErrOnSwitch
    [Documentation]    检查交换机上的流量和误码情况
    telnetSwitch    ${switchIp}
    comment    查看是否有误码
    : FOR    ${i}    IN    @{switchPort}
    \    SSHLibrary.write    ovs-vsctl list interface ${i}
    \    ${info}=    SSHLibrary.read until    admin@PICOS-OVS:~$
    \    should contain    ${info}    rx_errors=0    msg="有误码"
    SSHLibrary.close connection

clearErrOnSwitch
    telnetSwitch    ${switchIp}
    : FOR    ${i}    IN    @{switchPort}
    \   SSHLibrary.write    ovs-appctl bridge/clear-counts br0 ${i}
    \   ${info}=    SSHLibrary.read until    admin@PICOS-OVS:~$
    SSHLibrary.close connection

checkFlowOnSwitch
    clearErrOnSwitch
    sleep    5
    telnetSwitch    ${switchIp}\
    : FOR    ${i}    IN    @{switchPort}
    \    SSHLibrary.write    ovs-vsctl list interface ${i}
    \    ${info}=    SSHLibrary.read until    admin@PICOS-OVS:~$
    \    should not contain    ${info}    rx_bytes=0
    \    should not contain    ${info}    tx_bytes=0
    SSHLibrary.close connection

checkIopAndOop
    [Arguments]    @{list}
    ${true}    convert to boolean    True
    : FOR    ${i}    IN    @{list}
    \    ${status}=    evaluate    -15<${i}<2
    \    should be equal    ${status}    ${true}    msg=iop or oop is too strong or too low

OpenTheConnection
    [Arguments]    ${telnetIp}
    Telnet.Open Connection    ${telnetIp}    \    9999
    Telnet.login    sysadmin    sysadmin    user    password
    Telnet.Write    config
    Telnet.read until    sysadmin(config)#

telnetSwitch
    [Arguments]    ${ip}
    SSHLibrary.open connection    ${ip}    \    22
    SSHLibrary.Login    ${switchUser}    ${switchPwd}
    ${info}=    SSHLibrary.read
