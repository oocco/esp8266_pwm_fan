--the NTC (MF52 10K3435) characteristic
NTCData = {}
NTCData[1] = {26.83,25.70,24.63,23.62,22.66,21.75,20.89,20.07,19.30,18.56,18.48,18.15,17.63,16.99,16.28,15.54,14.79,14.06,13.35,12.69,12.07,11.49,10.95,10.46,10.00,9.58,9.18,8.82,8.48,8.16,7.86,7.58,7.31}
NTCData[2] = {7.06,6.81,6.58,6.36,6.14,5.93,5.73,5.54,5.35,5.17,5.00,4.83,4.67,4.51,4.35,4.21,4.07,3.93,3.79,3.66,3.54,3.41,3.29,3.18,3.06,2.94,2.83,2.78,2.72,2.65,2.58,2.51}
NTCData[3] = {2.43,2.36,2.28,2.21,2.14,2.07,2.00,1.94,1.88,1.82,1.77,1.72,1.67,1.63,1.59,1.55,1.51,1.47,1.44,1.40,1.37,1.33,1.30,1.27,1.24,1.20,1.17,1.14,1.11,1.07,1.04,1.01,0.98,0.95,0.92}

function getTempAnalog()
    local virtualVoltage = adc.read(0)
    --print("Primary Data: ", virtualVoltage)
    local virtualVoltage = virtualVoltage*3.25/1000
    --print("Voltage: ", virtualVoltage, "V")
    local t = virtualVoltage/3.25
    --set resistor specification, unit: k¦¸
    local resistor = 20
    t= (resistor*t)/(1-t)
    --print("Resistor: ", t, "k¦¸")
    
    if (t > 7.3) then 
        for i=1, #NTCData[1] do
            --print("i: ", i)
            --print("N: ",NTCData[1][i])
            if (t > NTCData[1][i]) then
                print("Temperature: ", i)
                t = i
                break
            elseif (t > 26.85) then
                print("Temperature: 0-")
                t = 0
                break
            end
        end
    elseif (t > 2.5) then 
        for i=1, #NTCData[2] do
            if t > NTCData[2][i] then
                print("Temperature: ", 33+i)
                t = 33+i
                break
            end
        end
    elseif (t > 0.94) then 
        for i=0, #NTCData[3] do
            if t > NTCData[3][i+1] then
                print("Temperature: ", 66+i)
                t = 66+i
                break
            end
        end
    else
        print("Temperature: 100+")
        t = 100
    end
    return t
end
