--send webstion page
function index(conn)
    local buf = ""
    print("read index.html")
    file.open("index.html", "r")
    while true do 
        temp = file.readline()
        if (temp == nil) then 
            break
        else
            buf = buf..string.sub(temp, 1, -1)
        end
    end
    file.close()
    
    --out of memory, cut the data
    local sendBuf = {}
    sendBuf[1] = string.sub(buf, 1, 1400)
    sendBuf[2] = string.sub(buf, 1401, 2800)
    sendBuf[3] = string.sub(buf, 2801, -1)

    --send self config
    sendBuf[4] = '<script>\
    document.getElementById("firstTemp").value='..pwmTempValue[1]..';\
    document.getElementById("secondTemp").value='..pwmTempValue[2]..';\
    document.getElementById("threeTemp").value='..pwmTempValue[3]..';\
    document.getElementById("fourTemp").value='..pwmTempValue[4]..';\
    document.getElementById("firstSpeed").value='..pwmFanValue[1]..';\
    document.getElementById("secondSpeed").value='..pwmFanValue[2]..';\
    document.getElementById("threeSpeed").value='..pwmFanValue[3]..';\
    document.getElementById("fourSpeed").value='..pwmFanValue[4]..';\
    document.getElementById("virtualSwitch").checked='..pwmConstValue[1]..';\
    document.getElementById("virtualSwitch").value='..pwmConstValue[1]..';\
    document.getElementById("virtualTempA").value='..pwmConstValue[2]..';\
    document.getElementById("virtualTempB").value='..pwmConstValue[3]..';\
    document.getElementById("virtualSpeed").value='..pwmConstValue[4]..';\
    </script>'
    
    --if #sendBuf > 0 then
    --    conn:send(table.remove(sendBuf, 1))
    --else
    --    conn:close()
    --    sendBuf = nil
    --end
    
    conn:send(sendBuf[1], function() 
        conn:send(sendBuf[2], function()
            conn:send(sendBuf[3], function() 
                conn:send(sendBuf[4], function(con) 
                    con:close()
                end)
            end)
        end)
    end)
    --conn:send(buf)
end

--decode post data
function postDecode(post)
    local t = string.gsub(post, " ", "")
    t = string.gsub(t, "=", "\":\"")
    t = "{\""..string.gsub(t, "&", "\",\"").."\"}"
    print("Decode: ",t)
    return sjson.decode(t)
end

--set post data and save
function setConfig(item, post)
    local t = postDecode(post)
    if (item == "setpwm") then
        t.firstTemp = tonumber(t.firstTemp)
        t.secondTemp = tonumber(t.secondTemp)
        t.threeTemp = tonumber(t.threeTemp)
        t.fourTemp = tonumber(t.fourTemp)

        t.firstSpeed = tonumber(t.firstSpeed)
        t.secondSpeed = tonumber(t.secondSpeed)
        t.threeSpeed = tonumber(t.threeSpeed)
        t.fourSpeed = tonumber(t.fourSpeed)

        if (t.firstTemp and t.secondTemp and t.threeTemp and t.fourTemp and t.firstSpeed and t.secondSpeed and t.threeSpeed and t.fourSpeed) then
            pwmTempValue = {t.firstTemp, t.secondTemp, t.threeTemp, t.fourTemp}
            pwmFanValue = {t.firstSpeed, t.secondSpeed, t.threeSpeed, t.fourSpeed ,1000}
            print("save to file")
            saveConfig({pwmTempValue,pwmFanValue})
        else
            print("setTemp data error!")
        end
    elseif (item == "settemp") then
        t.virtualSwitch = tonumber(t.virtualSwitch)
        if (not t.virtualSwitch) then t.virtualSwitch = 0 end
        t.virtualTempA = tonumber(t.virtualTempA)
        t.virtualTempB = tonumber(t.virtualTempB)
        t.virtualSpeed = tonumber(t.virtualSpeed)
        if (t.virtualTempA and t.virtualTempB and t.virtualSpeed) then
            pwmConstValue = {t.virtualSwitch, t.virtualTempA, t.virtualTempB, t.virtualSpeed}
            print("save to file")
            saveConfig({pwmConstValue})
        else
            print("setTemp data error!")
        end
    end
end

--start webstation
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    local buffer = nil
    conn:on("receive",function(conn,payload)
        --manually buffer the data
        if buffer == nil then
            buffer = payload
        else
            buffer = buffer .. payload
        end
        payload = buffer
        buffer = nil

        print("Http Request..\r\n")
        --print(payload) 
        --send index content
        local _, _, method, action = string.find(payload, "([A-Z]+) /(.+) HTTP");

        --print(method, action)
        if ((action==nil) or (action=="index.html")) then 
            print("send default content")
            index(conn)
            
        elseif (action=="digital") then
            local _, _, _, item, post = string.find(payload, "(digital=)([a-z]+).(.*)");
            --print(item, post)
            setConfig(item, post)
            index(conn)

        else
            print("no post")
            index(conn)   
        end      
        --conn:close() 
    end)
end)
