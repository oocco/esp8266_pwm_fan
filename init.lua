--set PWM pin
pwmPinA = 5
pwmPinB = 6
pwmPinC = 7
pwmPinD = 8

--set Temperature Pin
tempPinA = 1
tempPinB = 2 

--define Temperature int
tempNumA = 0
tempNumB = 0
 
--setting PWM config, will be a file
pwmTempValue = {45,60,70,80}
pwmFanValue = {0,100,300,600,1023}
pwmConstValue = {0,61,61,1000}
wifiConf = {}
wifiConf.ssid=""
wifiConf.pwd=""

--setting PWM default value
pwm.setup(pwmPinA, 1000, 1023)
pwm.setup(pwmPinB, 1000, 1023)
pwm.setup(pwmPinC, 1000, 1023)
pwm.setup(pwmPinD, 1000, 1023)

--setting PWM pin start
pwm.start(pwmPinA)
pwm.start(pwmPinB)
pwm.start(pwmPinC)
pwm.start(pwmPinD)

--get config file
function readConfig()
    if file.open("conf.json", "r") then
        print("config file open")
        local buf = ""
        while true do 
            local temp = file.readline()
            if (temp == nil) then 
                break
            else
                buf = buf..string.sub(temp, 1, -1)
            end
        end
        print(buf)
        file.close()
        local t = sjson.decode(buf)
        if (t.wifiConf) then
            wifiConf = t.wifiConf
        end
        if (t.pwmTempValue) then
            pwmTempValue = t.pwmTempValue
        end
        if (t.pwmFanValue) then
            pwmFanValue = t.pwmFanValue
        end
        if (t.pwmConstValue) then
            pwmConstValue = t.pwmConstValue
        end
    else
        print("config not open")
    end
end

--set config file
function saveConfig(t)
    local conf = {} 
    if t.wifiConf then
        conf["wifiConf"] = t.wifiConf
    else 
        print("wifiConf value error, use default")
        conf["wifiConf"] = wifiConf
    end
    
    if t.pwmTempValue then
        conf["pwmTempValue"] = t.pwmTempValue
    else 
        print("pwmTempValue error, use default")
        conf["pwmTempValue"] = pwmTempValue
    end
    
    if t.pwmFanValue then
        conf["pwmFanValue"] = t.pwmFanValue
    else 
        print("pwmFanValue error, use default")
        conf["pwmFanValue"] = pwmFanValue
    end
    
    if t.pwmConstValue then
        conf["pwmConstValue"] = t.pwmConstValue
    else 
        print("pwmConstValue error, use default")
        conf["pwmConstValue"] = pwmConstValue
    end
        
    if file.open("conf.json", "w+") then
        print("open config file, saving")
        local buf = sjson.encode(conf)
        file.write(buf)
        file.close()
        print(buf)
        print("save success!")
    end
end

--refresh config
readConfig()

--get ADC Temperature
getTemp = function(pin)
    local temp = math.random(20,100)
    --print("Get temperature: pin", pin)
    --print(temp)
    return temp
end

--refresh Temperatrue
function refreshTemp()
    tempNumA = getTemp(tempPinA)
    tempNumB = getTemp(tempPinB)
end

--set PWM duty, tempArray is five number
function setPwm(pin,temp,tempArray,pwmArray)
    --print("Set PWM, temp: ",temp)
    if (temp < tempArray[1]) then
        pwm.setduty(pin, pwmArray[1])
    elseif (tempArray[1] <= temp and temp < tempArray[2]) then
        pwm.setduty(pin, pwmArray[2])
    elseif (tempArray[2] <= temp and  temp < tempArray[3]) then
        pwm.setduty(pin, pwmArray[3])
    elseif (tempArray[3] <= temp and  temp < tempArray[4]) then
        pwm.setduty(pin, pwmArray[4])
    else
        pwm.setduty(pin, pwmArray[5])
    end
end

tmr.alarm(0,10000,1,function()
    if (pwmConstValue[1]) then
        tempNumA = pwmConstValue[2]
        tempNumB = pwmConstValue[3]
    else
        refreshTemp()
    end
    setPwm(pwmPinA,tempNumA,pwmTempValue,pwmFanValue)
    setPwm(pwmPinB,tempNumB,pwmTempValue,pwmFanValue)
end)
tmr.alarm(1,15000,1,function()
    if (pwmConstValue[1]) then
        tempNumA = pwmConstValue[2]
        tempNumB = pwmConstValue[3]
    else
        refreshTemp()
    end
    setPwm(pwmPinC,tempNumA,pwmTempValue,pwmFanValue)
    setPwm(pwmPinD,tempNumB,pwmTempValue,pwmFanValue)
end)
 
