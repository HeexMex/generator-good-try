local U,R,C,P,VU,L,RS=game:GetService("UserInputService"),game:GetService("ReplicatedStorage"),game:GetService("CoreGui"),game:GetService("Players"),game:GetService("VirtualUser"),game:GetService("Lighting"),game:GetService("RunService")
local extra={}
local plr=P.LocalPlayer
local Http=game:GetService("HttpService")
local accountPrefix="GGT/config_"..tostring(plr.UserId)
local activeConfig="default"
local markerPath=accountPrefix.."_active.txt"
local function validConfigName(name)
    return type(name)=="string" and #name>0 and #name<=32 and name:match("^[%w_-]+$")~=nil
end
if type(readfile)=="function" then
    local ok,name=pcall(readfile,markerPath)
    if ok and validConfigName(name) then activeConfig=name end
end
local function configFile(name)
    if name=="default" then return accountPrefix..".json" end
    return accountPrefix.."_profile_"..name..".json"
end
local configPath=configFile(activeConfig)
local function readConfig()
    if type(readfile)~="function" then return end
    local ok,loaded=pcall(function() return Http:JSONDecode(readfile(configPath)) end)
    if ok and type(loaded)=="table" and loaded.version==1 then return loaded end
end
local loadedConfig=readConfig()
local savedConfig=loadedConfig or {}
local configReadable=true
if not loadedConfig and type(isfile)=="function" then
    local ok,exists=pcall(isfile,configPath)
    if not ok or exists then configReadable=false end
end
local function configNumber(value,default,minimum,maximum)
    if type(value)~="number" or value~=value then return default end
    return math.clamp(value,minimum,maximum)
end
local saveConfig
local function configNickname(value)
    return type(value)=="string" and #value<=20 and value:match("^[%w_]+$") or ""
end
local Rem=R:WaitForChild("Remotes")
local GM,ML,MB,PS,ST=Rem.GetMarket,Rem.MarketLot,Rem.MarketBuy,Rem.Post,Rem.Stall
if C:FindFirstChild("ZS") then C.ZS:Destroy() end

local g=Instance.new("ScreenGui",C) g.Name,g.ResetOnSpawn,g.IgnoreGuiInset="ZS",false,true

-- Нажимаем только Reconnect в системном окне ошибки Roblox.
do
    local running=true
    local nextAttempt=0
    local inputOk,input=pcall(function() return game:GetService("VirtualInputManager") end)
    if not inputOk or not input then
        warn("[GGT] Автореконнект недоступен: executor не предоставляет VirtualInputManager")
    else
        local function visibleInPrompt(button,prompt)
            local node=button
            while node do
                if node:IsA("GuiObject") and not node.Visible then return false end
                if node:IsA("ScreenGui") and not node.Enabled then return false end
                if node==prompt then return true end
                node=node.Parent
            end
            return false
        end
        local function isReconnect(button)
            if not button:IsA("GuiButton") then return false end
            local label=button:IsA("TextButton") and button or button:FindFirstChild("ButtonText",true)
            if not label or not (label:IsA("TextLabel") or label:IsA("TextButton")) then return false end
            local text=label.Text:match("^%s*(.-)%s*$")
            return text=="Reconnect" or text=="Переподключиться"
        end
        local function tryReconnect()
            local promptGui=C:FindFirstChild("RobloxPromptGui")
            local overlay=promptGui and promptGui:FindFirstChild("promptOverlay")
            local prompt=overlay and overlay:FindFirstChild("ErrorPrompt")
            if not prompt or not promptGui.Enabled or not visibleInPrompt(prompt,overlay) then return end
            for _,button in ipairs(prompt:GetDescendants()) do
                if isReconnect(button) and visibleInPrompt(button,prompt) then
                    local size,pos=button.AbsoluteSize,button.AbsolutePosition
                    if size.X<=0 or size.Y<=0 then return end
                    local x,y=pos.X+size.X/2,pos.Y+size.Y/2
                    nextAttempt=os.clock()+15
                    local ok,err=pcall(function()
                        input:SendMouseButtonEvent(x,y,0,true,game,0)
                        input:SendMouseButtonEvent(x,y,0,false,game,0)
                    end)
                    if not ok then warn("[GGT] Не удалось нажать Reconnect: "..tostring(err)) end
                    return
                end
            end
        end
        g.Destroying:Connect(function() running=false end)
        task.spawn(function()
            while running do
                if os.clock()>=nextAttempt then
                    local ok,err=pcall(tryReconnect)
                    if not ok then nextAttempt=os.clock()+15 warn("[GGT] Ошибка автореконнекта: "..tostring(err)) end
                end
                task.wait(2)
            end
        end)
    end
end
local u,c=UDim2.new,Color3.fromRGB
local bg,sd,cd,ac,tx,sb=c(15,15,21),c(21,21,29),c(27,27,37),c(130,85,255),c(242,242,247),c(145,145,165)
local strokeColor,danger=c(44,44,58),c(200,55,65)

local function ui(t,p,par,r,s)
    local o=Instance.new(t,par) for k,v in pairs(p) do o[k]=v end
    if r then Instance.new("UICorner",o).CornerRadius=UDim.new(0,r) end
    if s then local k=Instance.new("UIStroke",o) k.Color,k.Thickness,k.ApplyStrokeMode=strokeColor,1,Enum.ApplyStrokeMode.Border end
    return o
end
local function lb(par,t,sz,ps,cl,f,xa) return ui("TextLabel",{Size=sz,Position=ps,BackgroundTransparency=1,Text=t,TextColor3=cl or tx,Font=f or 18,TextSize=11,TextXAlignment=xa or 0},par) end
local function bt(par,t,sz,ps,cl,r,s) return ui("TextButton",{Size=sz,Position=ps,BackgroundColor3=cl or cd,Text=t,TextColor3=tx,Font=18,TextSize=11},par,r or 6,s) end
local function bx(par,t,sz,ps) return ui("TextBox",{Size=sz,Position=ps,BackgroundColor3=bg,Text=t,TextColor3=tx,Font=18,TextSize=11,ClearTextOnFocus=false},par,6,1) end

local function parseM(str)
    local s=tostring(str or ""):lower():gsub("%s+",""):gsub(",",".")
    local num=tonumber(s:match("[%d%.]+")) or 0
    if num<=0 then return 0 end
    if s:find("b") or s:find("млрд") or s:find("kkk") or s:find("ккк") then return math.floor(num*1e9)
    elseif s:find("m") or s:find("м") or s:find("kk") or s:find("кк") then return math.floor(num*1e6)
    elseif s:find("k") or s:find("к") then return math.floor(num*1e3) end
    return math.floor(num)
end
local oB=bt(g,"Меню",u(0,86,0,28),u(0,15,0.5,-14),sd,8,1) oB.Visible=false
local m=ui("Frame",{Size=u(0,435,0,320),Position=u(0.5,-217,0.3,0),BackgroundColor3=bg},g,10,1)
local tp=ui("Frame",{Size=u(1,0,0,34),BackgroundColor3=sd},m,10)
local menuTitle=lb(tp,"Меню",u(0,140,1,0),u(0,12,0,0),ac,18)
local mB=bt(tp,"—",u(0,24,0,22),u(1,-54,0,6),cd)
local cB=bt(tp,"X",u(0,24,0,22),u(1,-27,0,6),c(200,55,65))

local dlg=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=c(10,10,14),BackgroundTransparency=0.15,Visible=false,ZIndex=10},m,10)
local yB,nB
do
    local panel=ui("Frame",{Size=u(0,210,0,95),Position=u(0.5,-105,0.5,-47),BackgroundColor3=sd,ZIndex=11},dlg,8,1)
    ui("TextLabel",{Size=u(1,-10,0,38),Position=u(0,5,0,6),BackgroundTransparency=1,Text="Закрыть меню?",TextColor3=tx,Font=18,TextSize=12,ZIndex=12},panel)
    yB=bt(panel,"Да",u(0.45,0,0,28),u(0,10,1,-36),danger)
    nB=bt(panel,"Нет",u(0.45,0,0,28),u(0.55,-10,1,-36),cd)
    yB.ZIndex,nB.ZIndex=12,12
end

local sdF=ui("Frame",{Size=u(0,98,1,-34),Position=u(0,0,0,34),BackgroundColor3=sd,BorderSizePixel=0},m)
local p1=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1},m)
local p4=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p5=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p6=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p7=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false,ClipsDescendants=true},m)
local p9=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local pgs,tbs={p1,p4,p6,p5,p7,p9},{}
extra.navScroll=ui("ScrollingFrame",{Size=u(1,-2,1,-83),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=u(0,0,0,212)},sdF)
local function showPage(index)
    for i,tab in ipairs(tbs) do
        pgs[i].Visible = i==index
        tab.BackgroundColor3 = i==index and ac or cd
    end
end
for i,nm in ipairs({"Снайпер","Торгаш","Ларёк","Почта","Настройки","Предметы"}) do
    local tb=bt(extra.navScroll,nm,u(1,-12,0,28),u(0,6,0,8+(i-1)*34),i==1 and ac or cd,7)
    tbs[i]=tb
    tb.Activated:Connect(function() showPage(i) end)
end

local configB=bt(sdF,"Конфиги",u(1,-12,0,28),u(0,6,1,-76),cd,7,1)
local avatarImage="rbxthumb://type=AvatarHeadShot&id="..tostring(plr.UserId).."&w=100&h=100"
do
    local profile=ui("Frame",{Size=u(1,-12,0,40),Position=u(0,6,1,-46),BackgroundColor3=cd},sdF,7,1)
    local avatar=ui("ImageLabel",{Size=u(0,26,0,26),Position=u(0,5,0,7),BackgroundColor3=bg,Image=avatarImage},profile,13)
    local outline=Instance.new("UIStroke",avatar)
    outline.Color,outline.Thickness=ac,1
    local display=lb(profile,plr.DisplayName,u(1,-37,0,15),u(0,34,0,5),tx,18)
    display.TextSize,display.TextTruncate=10,Enum.TextTruncate.AtEnd
    local username=lb(profile,"@"..plr.Name,u(1,-37,0,13),u(0,34,0,20),sb,17)
    username.TextSize,username.TextTruncate=9,Enum.TextTruncate.AtEnd
end
local bl={}
local sorts={{id="cheap",n="Дешёвые"},{id="new",n="Новые"},{id="ending",n="Скоро конец"},{id="expensive",n="Дорогие"},{id="luck",n="Удача"}}
local curSort={id="new",n="Новые"}
local topBar=ui("Frame",{Size=u(1,0,0,36),BackgroundColor3=cd},p1,8,1)
local sB=bt(topBar,"Новые",u(0,98,0,24),u(0,6,0,6),ac,6)
lb(topBar,"Лим:",u(0,28,1,0),u(0,112,0,0),sb,17)
local lBox=bx(topBar,"0",u(0,44,0,24),u(0,140,0,6))
lb(topBar,"Сек:",u(0,28,1,0),u(0,192,0,0),sb,17)
local dBox=bx(topBar,"1.5",u(0,46,0,24),u(0,220,0,6))

local sModal=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p1,8,1)
lb(sModal,"Выберите сортировку:",u(1,-16,0,24),u(0,8,0,4),sb,18).ZIndex=9
local sBtns={}
for idx,sr in ipairs(sorts) do
    local sbRow=bt(sModal,sr.n,u(1,-16,0,32),u(0,8,0,30+(idx-1)*37),sr.id==curSort.id and ac or cd,6,1)
    sbRow.ZIndex=9 sBtns[idx]=sbRow
    sbRow.MouseButton1Click:Connect(function()
        curSort=sr sB.Text=sr.n
        for j,b in ipairs(sBtns) do b.BackgroundColor3=sorts[j].id==sr.id and ac or cd end
        sModal.Visible=false
    end)
end
local sCloseB=bt(sModal,"Закрыть",u(1,-16,0,28),u(0,8,1,-34),c(200,55,65),6) sCloseB.ZIndex=9
sCloseB.MouseButton1Click:Connect(function() sModal.Visible=false end)
sB.MouseButton1Click:Connect(function() sModal.Visible=true end)

local rars={
    {id="RARE",n="Редкий",def="150000",col=c(65,155,255),on=false},
    {id="EPIC",n="Эпический",def="500000",col=c(155,85,255),on=false},
    {id="MYTHIC",n="Мифический",def="8000000",col=c(238,72,68),on=false},
    {id="LEGENDARY",n="Легендарный",def="15000000",col=c(255,185,50),on=false}
}
local rarMap={}
for i,r in ipairs(rars) do
    rarMap[r.id]=r
    local rw=ui("Frame",{Size=u(1,0,0,33),Position=u(0,0,0,42+(i-1)*37),BackgroundColor3=cd},p1,7,1)
    ui("Frame",{Size=u(0,4,0,21),Position=u(0,5,0,6),BackgroundColor3=r.col,BorderSizePixel=0},rw,2)
    lb(rw,r.n,u(0,95,1,0),u(0,15,0,0))
    r.box=bx(rw,r.def,u(1,-168,0,23),u(0,112,0,5))
    r.box.FocusLost:Connect(function() local v=parseM(r.box.Text) if v>0 then r.box.Text=tostring(v) bl={} end end)
    local sw=bt(rw,"OFF",u(0,44,0,23),u(1,-50,0,5),bg,6,1)
    r.toggle=sw
    sw.MouseButton1Click:Connect(function() r.on=not r.on sw.BackgroundColor3=r.on and ac or bg sw.Text=r.on and "ON" or "OFF" end)
end

local stC=ui("Frame",{Size=u(1,0,0,44),Position=u(0,0,0,192),BackgroundColor3=cd},p1,8,1)
local st=lb(stC,"Ожидание | Успешных покупок: 0",u(1,-14,1,-8),u(0,8,0,4),tx,17) st.TextWrapped,st.TextYAlignment=true,0
local tB=bt(p1,"СНАЙПЕР: ВЫКЛ",u(1,0,0,36),u(0,0,1,-36),ac,8)
local refreshTraderFilters
do
    local trCard=ui("Frame",{Size=u(1,0,0,194),BackgroundColor3=cd},p4,8,1)
    local function normalizeItemName(value)
        value = value:gsub("<[^>]*>", ""):gsub(utf8.char(160), " "):gsub(utf8.char(8239), " ")
        return value:lower():gsub(utf8.charpattern,function(letter)
            local code = utf8.codepoint(letter)
            if code >= 0x410 and code <= 0x42F then return utf8.char(code+32) end
            if code == 0x401 then return "ё" end
            return letter
        end)
    end

    local filters = {
        {name="Ролл удачи ×1M", matches=function(name)
            if not name:find("ролл",1,true) or not name:find("удачи",1,true) then return false end
            local scale = name:gsub("1%s*м", "1m")
            return scale:find("%f[%w]1%s*m%f[%W]") or scale:find("%f[%d]1%s*000%s*000%f[%D]")
        end},
        {name="Эликсир / зелье V тира", matches=function(name)
            if not name:find("эликсир",1,true) and not name:find("зелье",1,true) then return false end
            return name:find("%f[%w]v%f[%W]") or name:find("%f[%d]5%s*тир")
                or name:find("тир%s+5%f[%D]") or name:find("%s5%s*$")
        end},
        {name="Ролл удачи ×100K", matches=function(name) return false end},
    }

    lb(trCard,"Фильтр ассортимента",u(1,-24,0,28),u(0,12,0,8),tx,18).TextSize = 13
    for index,filter in ipairs(filters) do
        filter.enabled = index==3 and type(savedConfig.traderFilters)=="table" and savedConfig.traderFilters[index]==true or index~=3 and (type(savedConfig.traderFilters)~="table" or savedConfig.traderFilters[index]~=false)
        local y = 45+(index-1)*34
        lb(trCard,filter.name,u(1,-144,0,28),u(0,12,0,y),sb)
        filter.status = lb(trCard,"—",u(0,84,0,28),u(1,-140,0,y),sb,17,Enum.TextXAlignment.Right)
        local toggle = bt(trCard,filter.enabled and "ON" or "OFF",u(0,40,0,26),u(1,-50,0,y+1),filter.enabled and ac or bg,6,1)
        filter.toggle = toggle
        toggle.Activated:Connect(function()
            filter.enabled = not filter.enabled
            if type(savedConfig.traderFilters)~="table" then savedConfig.traderFilters={true,true,false} end
            savedConfig.traderFilters[index]=filter.enabled
            toggle.Text = filter.enabled and "ON" or "OFF"
            toggle.BackgroundColor3 = filter.enabled and ac or bg
        end)
    end
    local balanceBox
    refreshTraderFilters=function()
        for index,filter in ipairs(filters) do
            filter.enabled=index==3 and type(savedConfig.traderFilters)=="table" and savedConfig.traderFilters[index]==true or index~=3 and (type(savedConfig.traderFilters)~="table" or savedConfig.traderFilters[index]~=false)
            filter.toggle.Text=filter.enabled and "ON" or "OFF"
            filter.toggle.BackgroundColor3=filter.enabled and ac or bg
        end
        if balanceBox then balanceBox.Text=tostring(configNumber(savedConfig.traderReserve,0,0,1e15)) end
    end
    balanceBox=bx(p4,tostring(configNumber(savedConfig.traderReserve,0,0,1e15)),u(0.48,0,0,27),u(0,0,1,-75))
    local balanceLabel=lb(p4,"Остаток ₽:",u(0.48,0,0,27),u(0.52,0,1,-75),sb,17)
    local action=bt(p4,"АВТО-ТОРГАШ: ВЫКЛ",u(1,0,0,36),u(0,0,1,-40),ac,8)
    local hint = lb(trCard,"Проверка торговца через сервер.",u(1,-24,0,30),u(0,12,0,153),sb,17)
    hint.TextWrapped=true
    local running=false
    local session=0
    local seenVisit=nil
    local handled={}
    local remaining=nil
    local function matchesId(filterIndex,id)
        if type(id)~="string" then return false end
        if filterIndex==1 then return id=="roll_1000000" end
        if filterIndex==3 then return id=="roll_100000" end
        return id=="elixir_5" or id:match("^potion_%a+_5$")~=nil
    end
    local function invoke(remote,...)
        local args=table.pack(...)
        return pcall(function() return remote:InvokeServer(table.unpack(args,1,args.n)) end)
    end
    action.Activated:Connect(function()
        running=not running
        session=session+1
        local current=session
        action.Text=running and "АВТО-ТОРГАШ: ВКЛ" or "АВТО-ТОРГАШ: ВЫКЛ"
        action.BackgroundColor3=running and danger or ac
        if not running then hint.Text="Авто-торгаш остановлен." return end
        task.spawn(function()
            while running and session==current and g.Parent do
                local trader=Rem:FindFirstChild("Trader")
                local stateRemote=Rem:FindFirstChild("GetState")
                local waitTime=2
                if not trader or not stateRemote then
                    hint.Text="Нет Trader или GetState."
                    waitTime=10
                else
                    local ok,response=invoke(trader,"get")
                    if not running or session~=current then return end
                    if ok and type(response)=="table" and type(response.data)=="table" and type(response.data.goods)=="table" then
                        local data=response.data
                        if data.n~=nil and data.n~=seenVisit then seenVisit=data.n handled={} remaining=nil end
                        if data.n==nil then
                            hint.Text="Нет ID визита торгаша; покупка остановлена."
                        else
                            for i,filter in ipairs(filters) do
                                local found=false
                                for _,good in ipairs(data.goods) do
                                    if type(good)=="table" and matchesId(i,good.id) and not good.bought then
                                        found=true filter.status.Text=tostring(good.price or 0).." ₽" break
                                    end
                                end
                                if not found then filter.status.Text="Нет" end
                            end
                            hint.Text="Получен ассортимент торгаша."
                            for index,good in ipairs(data.goods) do
                                if not running or session~=current then break end
                                local selected=false
                                for i,filter in ipairs(filters) do
                                    if type(good)=="table" and filter.enabled and matchesId(i,good.id) then selected=true break end
                                end
                                if selected and not good.bought and not handled[index] then
                                    local price=tonumber(good.price)
                                    local reserve=parseM(balanceBox.Text)
                                    if not price or price<0 then
                                        hint.Text="Неизвестная цена; покупка пропущена."
                                        handled[index]=true
                                    else
                                        local stateOk,state=invoke(stateRemote)
                                        if not running or session~=current then return end
                                        local money=stateOk and type(state)=="table" and tonumber(state.money)
                                        if money and remaining then money=math.min(money,remaining) end
                                        if not money then
                                            hint.Text="Не удалось проверить баланс."
                                            waitTime=10
                                            break
                                        elseif money-price<reserve then
                                            hint.Text="Остаток ниже лимита; ожидаю."
                                            waitTime=10
                                            break
                                        else
                                            handled[index]=true
                                            local buyOk,result=invoke(trader,"buy",index)
                                            if not running or session~=current then return end
                            if buyOk and type(result)=="table" and result.ok then
                                                remaining=money-price
                                                hint.Text="Куплено: "..tostring(good.id)
                                            else
                                                hint.Text="Покупка не подтверждена: "..tostring(type(result)=="table" and (result.why or result.err) or "ошибка")
                                                if extra.reportGameError then extra.reportGameError("Торгаш",hint.Text) end
                                            end
                                            task.wait(0.25)
                                        end
                                    end
                                end
                            end
                        end
                    else
                        seenVisit=nil handled={} remaining=nil
                        hint.Text="Торгаш недоступен; ожидаю."
                        waitTime=5
                    end
                end
                task.wait(waitTime)
            end
        end)
    end)
    balanceBox.FocusLost:Connect(function() savedConfig.traderReserve=parseM(balanceBox.Text) balanceBox.Text=tostring(savedConfig.traderReserve) end)
    g.Destroying:Connect(function() running=false session=session+1 end)
end

local idBox,sumBox,pickB,mSt,mLogScroll
local recipientBook={primary="",names={}}
do
    local recipient=ui("Frame",{Size=u(1,0,0,50),BackgroundColor3=cd},p5,8,1)
    lb(recipient,"Юзернейм в Roblox:",u(1,-14,0,15),u(0,8,0,3),sb,17)
    idBox=bx(recipient,"",u(1,-109,0,24),u(0,8,0,20))
    idBox.PlaceholderText="Введи юзернейм..."
    local rememberB=bt(recipient,"Запомнить",u(0,85,0,24),u(1,-93,0,20),cd,6,1)

    local attachments=ui("Frame",{Size=u(1,0,0,50),Position=u(0,0,0,56),BackgroundColor3=cd},p5,8,1)
    lb(attachments,"Сумма (₽) и номера:",u(1,-14,0,15),u(0,8,0,3),sb,17)
    sumBox=bx(attachments,"0",u(0.34,-4,0,24),u(0,8,0,20))
    pickB=bt(attachments,"Номера: 0",u(0.32,-4,0,24),u(0.34,4,0,20),bg,6,1)
    extra.itemPickB=bt(attachments,"Предм.: 0",u(0.34,-12,0,24),u(0.66,4,0,20),bg,6,1)

    local history=ui("Frame",{Size=u(1,0,0,76),Position=u(0,0,0,112),BackgroundColor3=cd},p5,8,1)
    mSt=lb(history,"Впиши сумму или выбери номера, затем нажми Отправить.",u(1,-16,0,22),u(0,8,0,4),sb,17)
    mSt.TextWrapped=true
    mLogScroll=ui("ScrollingFrame",{Size=u(1,-12,1,-30),Position=u(0,6,0,26),BackgroundTransparency=1,ScrollBarThickness=3,CanvasSize=u(0,0,0,0)},history)

    local caption=lb(p5,"Быстрый набор",u(1,-16,0,15),u(0,8,0,190),sb,17)
    local quick=ui("ScrollingFrame",{
        Size=u(1,-8,0,27),Position=u(0,4,0,207),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,
        ScrollBarThickness=3,CanvasSize=u(0,0,0,0),
    },p5)
    local list=Instance.new("UIListLayout",quick)
    list.FillDirection,list.SortOrder,list.Padding=Enum.FillDirection.Horizontal,Enum.SortOrder.LayoutOrder,UDim.new(0,6)

    local function normalizedNames(primary,otherNames)
        local names,seen={},{}
        local function add(value)
            local nickname=configNickname(value)
            local key=nickname:lower()
            if nickname~="" and not seen[key] then
                seen[key]=true
                table.insert(names,nickname)
            end
        end
        add(primary)
        if type(otherNames)=="table" then
            for _,value in ipairs(otherNames) do add(value) end
        end
        return names
    end

    local function refreshQuick()
        for _,child in ipairs(quick:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local hasNames=#recipientBook.names>0
        caption.Visible,quick.Visible=hasNames,hasNames
        for index,nickname in ipairs(recipientBook.names) do
            local chip=bt(quick,nickname,u(0,math.max(70,#nickname*8+16),1,-4),u(0,0,0,0),cd,6,1)
            chip.LayoutOrder=index
            chip.Activated:Connect(function() idBox.Text=nickname end)
        end
    end

    function recipientBook.load(config)
        recipientBook.primary=configNickname(config.recipient)
        recipientBook.names=normalizedNames(recipientBook.primary,config.recipients)
        idBox.Text=recipientBook.primary
        refreshQuick()
    end

    rememberB.Activated:Connect(function()
        local nickname=idBox.Text:match("^%s*(.-)%s*$")
        if nickname~="" and configNickname(nickname)=="" then
            mSt.Text="Ник может содержать до 20 латинских букв, цифр и подчёркиваний."
            return
        end
        local previous,oldNames=recipientBook.primary,recipientBook.names
        recipientBook.primary=nickname
        recipientBook.names=normalizedNames(nickname,oldNames)
        if not saveConfig or not saveConfig(true) then
            recipientBook.primary,recipientBook.names=previous,oldNames
            mSt.Text="Не удалось записать конфиг в папку GGT."
            return
        end
        idBox.Text=nickname
        refreshQuick()
        mSt.Text=nickname=="" and "Получатель по умолчанию сброшен." or "Получатель добавлен в быстрый набор."
    end)
    recipientBook.load(savedConfig)
end
local mSendB=bt(p5,"ОТПРАВИТЬ",u(0.48,0,0,38),u(0,0,1,-38),ac,8)
local mTakeB=bt(p5,"АВТО-ПРИЁМ: ВЫКЛ",u(0.49,0,0,38),u(0.51,0,1,-38),cd,8,1)

local stCard=ui("Frame",{Size=u(1,0,0,185),BackgroundColor3=cd},p6,8,1)
lb(stCard,"Уровни зелий для покупки:",u(1,-16,0,22),u(0,8,0,4),sb,17)
local stallLevels={true,true,true,true}
local applyStallLevels
do
    local buttons={}
    local function showLevel(i)
        local button=buttons[i]
        button.Text=tostring(i)..(stallLevels[i] and ": ON" or ": OFF")
        button.BackgroundColor3=stallLevels[i] and ac or bg
    end
    applyStallLevels=function(levels)
        for i=1,4 do
            stallLevels[i]=type(levels)~="table" or levels[i]~=false
            showLevel(i)
        end
    end
    for i=1,4 do
        local button=bt(stCard,tostring(i)..": ON",u(0.25,-6,0,28),u((i-1)*0.25,4,0,28),ac,6)
        buttons[i]=button
        button.Activated:Connect(function()
            stallLevels[i]=not stallLevels[i]
            showLevel(i)
        end)
    end
end
local stInfo=lb(stCard,"Статус: ВЫКЛ",u(1,-16,1,-70),u(0,8,0,64),tx,17) stInfo.TextWrapped,stInfo.TextYAlignment=true,0
local stAutoB=bt(p6,"АВТО-ЛАРЁК: ВЫКЛ",u(1,0,0,40),u(0,0,1,-40),ac,8)
local afkOn=true
local bindB,afkB,mailDelayBox,stallDelayBox
extra.settingsRows=ui("ScrollingFrame",{Size=u(1,0,1,-82),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=u(0,0,0,280)},p7)
do
    local function settingRow(y)
        return ui("Frame",{Size=u(1,-5,0,36),Position=u(0,0,0,y),BackgroundColor3=cd},extra.settingsRows,8,1)
    end

    local hotkeyRow=settingRow(0)
    lb(hotkeyRow,"Клавиша меню:",u(0.55,0,1,0),u(0,10,0,0),sb)
    bindB=bt(hotkeyRow,"RightControl",u(0.42,-8,0,24),u(0.58,0,0,7),bg,6,1)

    local idleRow=settingRow(40)
    lb(idleRow,"Анти-АФК (защита от кика):",u(0.7,0,1,0),u(0,10,0,0),sb)
    afkB=bt(idleRow,"ON",u(0,46,0,24),u(1,-54,0,7),ac,6,1)

    local mailRow=settingRow(80)
    lb(mailRow,"Пауза проверки почты (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
    mailDelayBox=bx(mailRow,tostring(configNumber(savedConfig.mailDelay,4,2,3600)),u(0,46,0,24),u(1,-54,0,7))

    local stallRow=settingRow(120)
    lb(stallRow,"Пауза проверки ларька (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
    stallDelayBox=bx(stallRow,tostring(configNumber(savedConfig.stallDelay,2,1,3600)),u(0,46,0,24),u(1,-54,0,7))
end

do
    local upkeepInterval = 60 * 60
    local upkeepEnabled = false
    local nextUpkeep = 0
    local row = ui("Frame", {Size=u(1,-5,0,36), Position=u(0,0,0,160), BackgroundColor3=cd}, extra.settingsRows, 8, 1)
    lb(row, "Автопродление номеров (раз в час)", u(0.81,0,1,0), u(0,10,0,0), sb)
    local toggle = bt(row, "OFF", u(0,46,0,24), u(1,-54,0,6), bg, 6, 1)
    toggle.Activated:Connect(function()
        upkeepEnabled = not upkeepEnabled
        toggle.Text = upkeepEnabled and "ON" or "OFF"
        toggle.BackgroundColor3 = upkeepEnabled and ac or bg
    end)

    task.spawn(function()
        while g.Parent do
            if upkeepEnabled and os.clock() >= nextUpkeep then
                local remote = Rem:FindFirstChild("PayAllUpkeep")
                if remote and remote:IsA("RemoteFunction") then
                    local ok, err = pcall(function()
                        remote:InvokeServer()
                    end)
                    if not ok then
                        warn("PayAllUpkeep:", err)
                    end
                    nextUpkeep = os.clock() + upkeepInterval
                end
            end
            task.wait(1)
        end
    end)
end

do
    local enabled,busy=false,false
    local latest=nil
    local row=ui("Frame",{Size=u(1,-5,0,36),Position=u(0,0,0,200),BackgroundColor3=cd},extra.settingsRows,8,1)
    lb(row,"Автосбор заданий",u(0.75,0,1,0),u(0,10,0,0),sb)
    local toggle=bt(row,"OFF",u(0,46,0,24),u(1,-54,0,6),bg,6,1)
    toggle.Activated:Connect(function() enabled=not enabled toggle.Text=enabled and "ON" or "OFF" toggle.BackgroundColor3=enabled and ac or bg end)
    local changed=Rem:FindFirstChild("StateChanged")
    local connection=changed and changed.OnClientEvent:Connect(function(state) if type(state)=="table" then latest=state end end)
    task.spawn(function()
        while g.Parent do
            if enabled and not busy then
                busy=true
                local getState,claim=Rem:FindFirstChild("GetState"),Rem:FindFirstChild("ClaimTask")
                local ok,state=false,nil
                if getState then ok,state=pcall(function() return getState:InvokeServer() end) end
                if ok and type(state)=="table" then latest=state end
                local tasks=type(latest)=="table" and latest.tasks
                if claim and type(tasks)=="table" and type(tasks.list)=="table" and type(tasks.progress)=="table" and type(tasks.claimed)=="table" then
                    for _,entry in ipairs(tasks.list) do
                        if not enabled or not g.Parent then break end
                        if type(entry)=="table" and type(entry.id)=="string" and type(entry.need)=="number" and (tonumber(tasks.progress[entry.id]) or 0)>=entry.need and not tasks.claimed[entry.id] then
                            local claimOk,result=pcall(function() return claim:InvokeServer(entry.id) end)
                            if extra.reportGameError and (not claimOk or type(result)~="table" or not result.ok) then
                                extra.reportGameError("Задания",type(result)=="table" and tostring(result.err or "Ошибка получения награды") or "Нет ответа при получении награды")
                            end
                            task.wait(0.5)
                        end
                    end
                    local weekly=latest.weekly
                    if enabled and type(weekly)=="table" and not weekly.claimed and type(weekly.need)=="number" and (tonumber(weekly.progress) or 0)>=weekly.need then
                        pcall(function() return claim:InvokeServer("weekly") end)
                    end
                end
                busy=false
            end
            task.wait(30)
        end
    end)
    g.Destroying:Connect(function() if connection then connection:Disconnect() end end)
end

do
    local row=ui("Frame",{Size=u(1,-5,0,36),Position=u(0,0,0,240),BackgroundColor3=cd},extra.settingsRows,8,1)
    lb(row,"Клавиша AFK (Esc — убрать):",u(0.62,0,1,0),u(0,10,0,0),sb)
    extra.afkBindB=bt(row,"Не задана",u(0.35,-8,0,24),u(0.65,0,0,6),bg,6,1)
end

local function configOptimization(raw)
    local config={shadows=true,materials=true,textures=true,particles=true,cleanup=false,no3d=false,hideui=false,fps=30}
    if type(raw)=="table" then
        for key,default in pairs(config) do
            local value = raw[key]
            if type(default)=="boolean" and type(value)=="boolean" then config[key]=value end
        end
        config.fps=math.floor(configNumber(raw.fps,30,0,1000))
    end
    return config
end
local optCfg=configOptimization(savedConfig.optimization)
local settingsActions=ui("Frame",{
    Size=u(1,0,0,76),Position=u(0,0,1,-76),BackgroundTransparency=1,ClipsDescendants=true,
},p7)
local optOpenB=bt(settingsActions,"ОПТИМИЗАЦИЯ",u(0.58,-4,0,38),u(0,0,1,-38),ac,8)
local customB=bt(settingsActions,"КАСТОМ",u(0.42,-4,0,38),u(0.58,4,1,-38),cd,8,1)
local openAfk=bt(settingsActions,"AFK-РЕЖИМ",u(0.58,-4,0,32),u(0,0,0,0),cd,8,1)
local statsOpenB=bt(settingsActions,"TELEGRAM",u(0.42,-4,0,32),u(0.58,4,0,0),cd,8,1)

local settingsOverlays={}
local function hideSettingsActionsBehind(overlay)
    table.insert(settingsOverlays,overlay)
    local function refresh()
        for _,layer in ipairs(settingsOverlays) do
            if layer.Visible then settingsActions.Visible=false return end
        end
        settingsActions.Visible=true
    end
    overlay:GetPropertyChangedSignal("Visible"):Connect(refresh)
    refresh()
end
hideSettingsActionsBehind(dlg)

local optModal=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p7,8,1)
hideSettingsActionsBehind(optModal)
local optScroll=ui("ScrollingFrame",{Size=u(1,-12,1,-44),Position=u(0,6,0,6),BackgroundTransparency=1,ScrollBarThickness=3,CanvasSize=u(0,0,0,272),ZIndex=9},optModal)
local optItems={
    {k="shadows",n="Убрать тени и туман",tip="Отключает глобальные тени, туман и эффекты постобработки для снижения нагрузки на видеокарту."},
    {k="materials",n="Простые материалы",tip="Заменяет сложные поверхности карты на гладкий пластик (SmoothPlastic), повышая FPS."},
    {k="textures",n="Скрыть текстуры карты",tip="Скрывает наклейки и текстуры объектов на карте, не затрагивая интерфейс."},
    {k="particles",n="Отключить частицы",tip="Убирает летающие искры, дым, огонь и следы в воздухе."},
    {k="cleanup",n="Удалить декор и скины",tip="Удаляет аксессуары, одежду игроков и декоративные меши для реальной экономии ОЗУ."},
    {k="no3d",n="Отключить 3D-рендер",tip="Полностью отключает отрисовку 3D-мира (0% нагрузки на видеокарту). Меню и фарм продолжают работать."},
    {k="hideui",n="Скрыть интерфейс игры",tip="Скрывает все кнопки, панели и счётчики игры на экране, оставляя только это меню."}
}
local optBtns,optRows={},{}
for idx,it in ipairs(optItems) do
    local row=ui("Frame",{Size=u(1,-6,0,30),Position=u(0,2,0,(idx-1)*34),BackgroundColor3=cd},optScroll,6,1) row.ZIndex=9
    lb(row,it.n,u(0.72,0,1,0),u(0,8,0,0),tx,17).ZIndex=10
    local sw=bt(row,optCfg[it.k] and "ON" or "OFF",u(0,44,0,22),u(1,-50,0,4),optCfg[it.k] and ac or bg,6,1) sw.ZIndex=10
    optBtns[it.k],optRows[it.k]=sw,row
end
local fpsRow=ui("Frame",{Size=u(1,-6,0,30),Position=u(0,2,0,238),BackgroundColor3=cd},optScroll,6,1) fpsRow.ZIndex=9
lb(fpsRow,"Лимит FPS (0 = без лим.):",u(0.65,0,1,0),u(0,8,0,0),tx,17).ZIndex=10
local fpsBox=bx(fpsRow,tostring(optCfg.fps),u(0,68,0,22),u(1,-74,0,4)) fpsBox.ZIndex=10

local optApplyB=bt(optModal,"ПРИМЕНИТЬ",u(0.48,0,0,30),u(0,8,1,-36),ac,6) optApplyB.ZIndex=9
local optCloseB=bt(optModal,"Закрыть",u(0.46,0,0,30),u(0.52,0,1,-36),cd,6,1) optCloseB.ZIndex=9
local pModal=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p5,8,1)
local pScroll=ui("ScrollingFrame",{Size=u(1,-10,1,-42),Position=u(0,5,0,5),BackgroundTransparency=1,ScrollBarThickness=4,CanvasSize=u(0,0,0,0),ZIndex=9},pModal)
local pAllB=bt(pModal,"Выбрать все",u(0.55,-8,0,28),u(0,5,1,-33),cd,6) pAllB.ZIndex=9
local pDoneB=bt(pModal,"Готово",u(0.45,-7,0,28),u(0.55,2,1,-33),ac,6) pDoneB.ZIndex=9

local rarStyle={RARE={n="Редкий",c="#419BFF"},EPIC={n="Эпический",c="#9B55FF"},MYTHIC={n="Мифический",c="#EE4844"},LEGENDARY={n="Легендарный",c="#FFB932"},ORIGINAL={n="Оригинал",c="#38BDF8"}}
local function fmtNum(n) local s=tostring(math.floor(tonumber(n) or 0)) return s:reverse():gsub("(%d%d%d)","%1 "):reverse():gsub("^ ","") end
local function fmtPlateRich(rawStr)
    local txt,code=rawStr:match("^(.-)%s*%[(.-)%]$")
    if txt and code then
        local st=rarStyle[code:upper()]
        if st then return string.format("• <b>%s</b>  <font color=\"%s\">%s</font>",txt,st.c,st.n) end
    end
    return "• <b>"..rawStr.."</b>"
end

local tipBox=ui("Frame",{Size=u(0,295,0,0),Position=u(0,112,0,44),BackgroundColor3=c(19,19,27),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=25},m,8)
local bindTip
do
    local tipStroke=Instance.new("UIStroke",tipBox)
    tipStroke.Color,tipStroke.Thickness=ac,1
    local tipPad=Instance.new("UIPadding",tipBox)
    tipPad.PaddingTop,tipPad.PaddingBottom,tipPad.PaddingLeft,tipPad.PaddingRight=UDim.new(0,8),UDim.new(0,8),UDim.new(0,10),UDim.new(0,10)
    local tipLbl=lb(tipBox,"",u(1,0,0,0),u(0,0,0,0),tx,17)
    tipLbl.RichText,tipLbl.TextWrapped,tipLbl.AutomaticSize,tipLbl.ZIndex=true,true,Enum.AutomaticSize.Y,26

    bindTip=function(obj,textStr,yOffset)
        obj.MouseEnter:Connect(function()
            tipLbl.Text=textStr
            tipBox.Position=u(0,112,0,yOffset or 44)
            tipBox.Visible=true
        end)
        obj.MouseLeave:Connect(function() tipBox.Visible=false end)
    end
end

local mailLogCount=0
local function addMailLog(txt,tipText)
    mailLogCount=mailLogCount+1
    local entry=ui("Frame",{Size=u(1,-6,0,22),Position=u(0,2,0,(mailLogCount-1)*25),BackgroundColor3=bg},mLogScroll,5,1)
    local l=lb(entry,txt,u(1,-10,1,0),u(0,5,0,0),tx,17) l.TextTruncate=Enum.TextTruncate.AtEnd
    if tipText and tipText~="" then bindTip(entry,tipText,44) end
    mLogScroll.CanvasSize=u(0,0,0,mailLogCount*25)
    mLogScroll.CanvasPosition=Vector2.new(0,math.max(0,mailLogCount*25-mLogScroll.AbsoluteWindowSize.Y))
end

local selPlates,sentPlates,mailItems={},{},{}
local function countSel() local n=0 for _ in pairs(selPlates) do n=n+1 end return n end
local function updPickTxt() pickB.Text="Номера: "..countSel() end

local function plateId(item)
    if type(item) ~= "table" then return end
    return rawget(item,"uid") or rawget(item,"sn") or rawget(item,"id")
end

extra.mailInventoryCache=nil
local function scanMyPlates(sortByLabel)
    local pref,bestMap,bestCnt=tostring(plr.UserId).."_",{},0
    local mounted,hasMountState = {},false
    local currentInventory,currentState=nil,nil
    local function markEquipped(state,inventory)
        local function mark(index)
            if type(index)=="number" and index>0 then local id=plateId(rawget(inventory,index)) if type(id)=="string" then mounted[id]=true end end
        end
        mark(state.car) mark(state.hand)
        if type(state.wall)=="table" then for _,index in ipairs(state.wall) do mark(index) end end
    end
    local function available(item)
        local expiry=tonumber(rawget(item,"paidUntil"))
        return not rawget(item,"sold") and not rawget(item,"deleted") and not rawget(item,"inPost") and not rawget(item,"fav") and (not expiry or expiry>=workspace:GetServerTimeNow())
    end
    local getState=Rem:FindFirstChild("GetState")
    if getState then
        local ok,state=pcall(function() return getState:InvokeServer() end)
        if ok and type(state)=="table" then
            local inventory=state.inventory or state.rawInventory
            if type(inventory)=="table" then extra.mailInventoryCache=inventory
            elseif state.sameInventory~=true then extra.mailInventoryCache=nil end
            local index=state.car
            if index==nil and state.hasCar==false then index=0 end
            if type(extra.mailInventoryCache)=="table" and type(index)=="number" and index>=0 then
                local mountedId=plateId(rawget(extra.mailInventoryCache,index))
                if index==0 or type(mountedId)=="string" then
                    hasMountState=true
                    currentInventory,currentState=extra.mailInventoryCache,state
                    markEquipped(state,extra.mailInventoryCache)
                    for _,item in ipairs(extra.mailInventoryCache) do
                        local idV,txtV=plateId(item),type(item)=="table" and rawget(item,"text")
                        if type(idV)=="string" and idV:sub(1,#pref)==pref and type(txtV)=="string" then
                            bestCnt+=1
                            if not sentPlates[idV] and available(item) then bestMap[idV]=txtV.." ["..tostring(rawget(item,"rarity") or "").."]" end
                        end
                    end
                end
            end
        end
    end
    if not hasMountState and type(getgc)=="function" then
        local gcOk,objects=pcall(getgc,true)
        for _,obj in ipairs(gcOk and type(objects)=="table" and objects or {}) do
            if type(obj)~="table" then continue end
            local inventory,index = rawget(obj,"inventory"),rawget(obj,"car")
            if index == nil and rawget(obj,"hasCar") == false then index = 0 end
            if type(inventory)=="table" and type(index)=="number" and index>=0 and type(rawget(obj,"wall"))=="table" then
                local id = plateId(rawget(inventory,index))
                if index ~= 0 and (type(id)~="string" or id:sub(1,#pref)~=pref) then continue end
                hasMountState = true
                extra.mailInventoryCache=rawget(obj,"rawInventory") or inventory
                markEquipped(obj,inventory)
                local valid,tmp=0,{}
                for _,item in ipairs(inventory) do
                    if type(item)=="table" then
                        local idV=plateId(item)
                        local txtV=rawget(item,"text")
                        if type(idV)=="string" and idV:sub(1,#pref)==pref and type(txtV)=="string" then
                            valid=valid+1
                            if not sentPlates[idV] and available(item) then
                                tmp[idV]=txtV.." ["..tostring(rawget(item,"rarity") or "").."]"
                            end
                        end
                    end
                end
                if valid>=bestCnt and valid>0 then bestCnt,bestMap=valid,tmp currentInventory,currentState=inventory,obj end
            end
        end
    end
    local list={}
    if hasMountState then
        for idV,lblTxt in pairs(bestMap) do
            if not mounted[idV] then table.insert(list,{id=idV,label=lblTxt}) end
        end
    end
    if sortByLabel then table.sort(list,function(a,b) return a.label<b.label end) end
    local garageCounts=nil
    if type(currentInventory)=="table" and type(currentState)=="table" and type(currentState.car)=="number" and type(currentState.wall)=="table" then
        garageCounts={}
        local hidden={}
        if currentState.car>0 then hidden[currentState.car]=true end
        for _,index in ipairs(currentState.wall) do if type(index)=="number" and index>0 then hidden[index]=true end end
        for index,item in ipairs(currentInventory) do
            if not hidden[index] and type(item)=="table" and not rawget(item,"sold") and not rawget(item,"deleted") and not rawget(item,"inPost") then
                local rarity=tostring(rawget(item,"rarity") or "UNKNOWN")
                garageCounts[rarity]=(garageCounts[rarity] or 0)+1
            end
        end
    end
    return list,hasMountState,garageCounts
end

local pickerItems,pickerRows = {},{}
local function renderPlateRows()
    local rowHeight = 30
    local first = math.max(1,math.floor(pScroll.CanvasPosition.Y/rowHeight)+1)
    local count = math.max(0,math.min(#pickerItems-first+1,math.ceil(pScroll.AbsoluteSize.Y/rowHeight)+1))
    for offset=1,count do
        local slot = pickerRows[offset]
        if not slot then
            local button = bt(pScroll,"",u(1,-8,0,26),u(0,2,0,0),cd,6,1)
            button.ZIndex = 10
            slot = {button=button}
            pickerRows[offset] = slot
            button.Activated:Connect(function()
                local item = slot.item
                if not item then return end
                selPlates[item.id] = not selPlates[item.id] or nil
                button.BackgroundColor3 = selPlates[item.id] and ac or cd
                updPickTxt()
            end)
        end
        local index = first+offset-1
        local item = pickerItems[index]
        slot.item = item
        slot.button.Position = u(0,2,0,(index-1)*rowHeight)
        slot.button.Text = item.label
        slot.button.BackgroundColor3 = selPlates[item.id] and ac or cd
        slot.button.Visible = true
    end
    for offset=count+1,#pickerRows do
        pickerRows[offset].item = nil
        pickerRows[offset].button.Visible = false
    end
end
pScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(renderPlateRows)
pScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(renderPlateRows)

local function refreshModal()
    local items=scanMyPlates(true)
    local validSet={} for _,it in ipairs(items) do validSet[it.id]=true end
    for k in pairs(selPlates) do if not validSet[k] then selPlates[k]=nil end end
    updPickTxt()
    pickerItems = items
    pScroll.CanvasSize=u(0,0,0,#items*30)
    renderPlateRows()
    return #items
end

local function checkMailPlates(ids)
    if #ids==0 then return {} end
    local items,hasMountState = scanMyPlates()
    if not hasMountState then return nil,"Не удалось проверить номер на машине. Открой сейф и попробуй снова." end
    local labels = {}
    for _,item in ipairs(items) do labels[item.id] = item.label end
    local names,invalid = {},false
    for _,id in ipairs(ids) do
        if labels[id] then
            table.insert(names,labels[id])
        else
            selPlates[id] = nil
            invalid = true
        end
    end
    if invalid then
        updPickTxt()
        return nil,"Выбор изменился: номер на машине или недоступен. Проверь вложения."
    end
    return names
end

pickB.MouseButton1Click:Connect(function()
    if refreshModal()==0 then
        mSt.Text="Доступных номеров нет. Открой сейф для обновления инвентаря."
        return
    end
    pModal.Visible=true
end)

do
    local panel=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=11},p5,8,1)
    local heading=lb(panel,"Роллы, эликсиры, зелья V",u(1,-16,0,24),u(0,8,0,4),tx,18) heading.ZIndex=12
    local list=ui("ScrollingFrame",{Size=u(1,-10,1,-96),Position=u(0,5,0,30),BackgroundTransparency=1,ScrollBarThickness=4,CanvasSize=u(0,0,0,0),ZIndex=12},panel)
    local status=lb(panel,"",u(1,-12,0,23),u(0,6,1,-58),sb,17) status.ZIndex=12
    local selectAll=bt(panel,"Выбрать всё",u(0.5,-9,0,27),u(0,6,1,-33),cd,6,1) selectAll.ZIndex=12
    local done=bt(panel,"Готово",u(0.5,-9,0,27),u(0.5,3,1,-33),ac,6) done.ZIndex=12
    local function total() local n=0 for _,v in pairs(mailItems) do n+=v end return n end
    local function refreshButton() extra.itemPickB.Text="Предм.: "..total() end
    local function eligible(id)
        return type(id)=="string" and (id:match("^potion_%a+_5$") or id:match("^elixir_%d+$") or id:match("^roll_%d+$"))~=nil
    end
    local refreshId=0
    local displayed,quantityBoxes={},{}
    local function inventory()
        local stateRemote=Rem:FindFirstChild("GetState")
        if stateRemote then
            local ok,state=pcall(function() return stateRemote:InvokeServer() end)
            if ok and type(state)=="table" and type(state.inv)=="table" and type(state.inv.slots)=="table" then return state.inv.slots end
        end
        if type(getgc)=="function" then
            local gcOk,objects=pcall(getgc,true)
            for _,object in ipairs(gcOk and type(objects)=="table" and objects or {}) do
                if type(object)=="table" and type(rawget(object,"slots"))=="table" then
                    local slots=rawget(object,"slots")
                    for _,slot in ipairs(slots) do if type(slot)=="table" and eligible(rawget(slot,"id")) and type(rawget(slot,"n"))=="number" then return slots end end
                end
            end
        end
    end
    extra.validateMailItems=function(items)
        local slots=inventory()
        if type(slots)~="table" then return false,"Не удалось проверить инвентарь предметов." end
        local available={}
        for _,slot in ipairs(slots) do
            if type(slot)=="table" and eligible(slot.id) and type(slot.n)=="number" then available[slot.id]=slot.n end
        end
        for id,count in pairs(items) do
            if not eligible(id) or count>(available[id] or 0) then return false,"Количество предметов изменилось. Проверь вложения." end
        end
        return true
    end
    local function displayName(id)
        local kind,level=id:match("^potion_(%a+)_(%d+)$")
        local names={luck="Удача",speed="Скорость",money="Деньги"}
        if kind then return "🧪 "..(names[kind] or kind).." · тир "..level end
        local n=id:match("^roll_(%d+)$")
        if n then return "🎲 Ролл ×"..n end
        return "✨ "..id
    end
    extra.itemPickB.Activated:Connect(function()
        refreshId+=1 local current=refreshId
        displayed,quantityBoxes={},{}
        panel.Visible=true status.Text="Обновляю инвентарь..."
        for _,child in ipairs(list:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        local slots=inventory()
        if current~=refreshId or not panel.Visible or not g.Parent then return end
        if type(slots)~="table" then status.Text="Нет данных инвентаря." return end
        local row=0
        for _,slot in ipairs(slots) do
            if type(slot)=="table" and eligible(slot.id) and type(slot.n)=="number" and slot.n>0 then
                local id,available=slot.id,math.floor(slot.n)
                table.insert(displayed,{id=id,available=available})
                row+=1
                local frame=ui("Frame",{Size=u(1,-6,0,32),Position=u(0,2,0,(row-1)*35),BackgroundColor3=cd,ZIndex=12},list,6,1)
                local title=lb(frame,displayName(id).." ("..available..")",u(1,-68,1,0),u(0,6,0,0),tx,17) title.ZIndex=13 title.TextTruncate=Enum.TextTruncate.AtEnd
                local quantity=bx(frame,tostring(mailItems[id] or 0),u(0,54,0,24),u(1,-60,0,4)) quantity.ZIndex=13
                quantityBoxes[id]=quantity
                quantity.FocusLost:Connect(function()
                    local old=mailItems[id] or 0
                    local number=math.floor(tonumber(quantity.Text) or 0)
                    number=math.clamp(number,0,math.min(available,90-(total()-old)))
                    mailItems[id]=number>0 and number or nil quantity.Text=tostring(number)
                    refreshButton() status.Text="Всего: "..total().." / 90"
                end)
            end
        end
        list.CanvasSize=u(0,0,0,row*35)
        status.Text=row>0 and ("Всего: "..total().." / 90") or "Доступных предметов нет."
    end)
    selectAll.Activated:Connect(function()
        if #displayed==0 then return end
        table.clear(mailItems)
        local remaining,availableTotal=90,0
        for _,entry in ipairs(displayed) do
            availableTotal+=entry.available
            local amount=math.min(entry.available,remaining)
            if amount>0 then mailItems[entry.id]=amount remaining-=amount end
            if quantityBoxes[entry.id] then quantityBoxes[entry.id].Text=tostring(amount) end
        end
        refreshButton()
        status.Text=availableTotal>90 and "Выбрано 90: лимит посылки." or ("Выбрано: "..total().." / 90")
    end)
    done.Activated:Connect(function() refreshId+=1 panel.Visible=false refreshButton() end)
end
pAllB.Activated:Connect(function()
    if refreshModal()==0 then return end
    for _,item in ipairs(pickerItems) do selPlates[item.id]=true end
    updPickTxt()
    renderPlateRows()
end)
pDoneB.MouseButton1Click:Connect(function() pModal.Visible=false updPickTxt() end)

local run,takeRun,stRun,okC,lN=false,false,false,0,0
local sniperSession=0
local takenPosts={}
local menuKey,waitingBind=Enum.KeyCode.RightControl,false
extra.afkKey,extra.waitingAfkBind=Enum.KeyCode.Unknown,false
local function configMenuKey(name)
    if type(name)=="string" then
        local ok,key = pcall(function() return Enum.KeyCode[name] end)
        if ok and key and key~=Enum.KeyCode.Unknown then return key end
    end
    return Enum.KeyCode.RightControl
end
menuKey=configMenuKey(savedConfig.menuKey)
bindB.Text=menuKey.Name
if type(savedConfig.afkKey)=="string" then local ok,key=pcall(function() return Enum.KeyCode[savedConfig.afkKey] end) if ok and key then extra.afkKey=key end end
extra.afkBindB.Text=extra.afkKey~=Enum.KeyCode.Unknown and extra.afkKey.Name or "Не задана"

local originalProperties,originalGuiProperties={},{}
local sceneConnections,guiConnections={},{}
local appliedOpt
local darkBg=ui("Frame",{Size=u(1,0,1,60),Position=u(0,0,0,-60),BackgroundColor3=c(12,12,17),Visible=false,ZIndex=-1},g)

local function setOptimizedProperty(object, property, value, saved)
    local current = object[property]
    if current == value then return end
    saved = saved or originalProperties
    local original = saved[object]
    if not original then
        original = {}
        saved[object] = original
    end
    if original[property] == nil then original[property] = current end
    object[property] = value
end

local function cleanObj(v, config)
    if config.cleanup then
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end) return
        elseif v:IsA("BasePart") and not v.CanCollide and not v:FindFirstAncestor("TraderWalker") and not v:FindFirstAncestorOfClass("Player") then
            if v.Size.Magnitude<12 and not v:FindFirstChildWhichIsA("ProximityPrompt",true) then pcall(function() v:Destroy() end) return end
        end
    end
    if v:IsA("BasePart") then
        if config.materials then
            setOptimizedProperty(v, "Material", Enum.Material.SmoothPlastic)
            setOptimizedProperty(v, "Reflectance", 0)
        end
        if config.materials or config.shadows then setOptimizedProperty(v, "CastShadow", false) end
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if config.textures and not v:FindFirstAncestor("PlatesUI") then setOptimizedProperty(v, "Transparency", 1) end
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
        if config.particles then setOptimizedProperty(v, "Enabled", false) end
    end
end

local function restoreOptimizedObject(saved,object)
    local properties = saved[object]
    if not properties then return end
    saved[object] = nil
    for property,value in pairs(properties) do
        pcall(function() object[property] = value end)
    end
end

local function clearOptimization(connections,saved)
    for _,connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    for object in pairs(saved) do restoreOptimizedObject(saved,object) end
end

local sceneOptions = {"shadows","materials","textures","particles","cleanup"}
local function applySceneOpt(config)
    clearOptimization(sceneConnections,originalProperties)
    if config.shadows or config.materials then
        pcall(function() setOptimizedProperty(settings().Rendering, "QualityLevel", Enum.QualityLevel.Level01) end)
    end
    if config.shadows then
        setOptimizedProperty(L, "GlobalShadows", false)
        setOptimizedProperty(L, "FogEnd", 9e9)
    end
    if not (config.shadows or config.materials or config.textures or config.particles or config.cleanup) then return end
    local function optimizeDescendant(object)
        if config.shadows and object.Parent==L and object:IsA("PostEffect") then
            setOptimizedProperty(object,"Enabled",false)
        end
        cleanObj(object,config)
    end
    for _,root in ipairs({workspace,P,L}) do
        for _,object in ipairs(root:GetDescendants()) do optimizeDescendant(object) end
        table.insert(sceneConnections,root.DescendantAdded:Connect(optimizeDescendant))
        table.insert(sceneConnections,root.DescendantRemoving:Connect(function(object)
            restoreOptimizedObject(originalProperties,object)
        end))
    end
end

local function applyGuiOpt(enabled)
    clearOptimization(guiConnections,originalGuiProperties)
    if not enabled then return end
    local pg = plr:FindFirstChild("PlayerGui")
    if not pg then return end
    local function hideGui(gui)
        if gui:IsA("ScreenGui") then setOptimizedProperty(gui,"Enabled",false,originalGuiProperties) end
    end
    for _,gui in ipairs(pg:GetChildren()) do hideGui(gui) end
    table.insert(guiConnections,pg.ChildAdded:Connect(hideGui))
    table.insert(guiConnections,pg.ChildRemoved:Connect(function(gui)
        restoreOptimizedObject(originalGuiProperties,gui)
    end))
end

local emptyOpt = {}
local function applyCustomOpt(config)
    local before,after = appliedOpt or emptyOpt,config or emptyOpt
    appliedOpt = config
    for _,key in ipairs(sceneOptions) do
        if (not not before[key]) ~= (not not after[key]) then applySceneOpt(after) break end
    end
    if (not not before.hideui) ~= (not not after.hideui) then applyGuiOpt(after.hideui) end
    if (not not before.no3d) ~= (not not after.no3d) then
        darkBg.Visible = after.no3d == true
        pcall(function() RS:Set3dRenderingEnabled(not darkBg.Visible) end)
    end
    if before.fps ~= after.fps and type(setfpscap)=="function" then
        pcall(setfpscap,after.fps or 0)
    end
end

g.Destroying:Connect(function()
    if appliedOpt then applyCustomOpt(nil) end
end)

for _,it in ipairs(optItems) do
    local sw,rw=optBtns[it.k],optRows[it.k]
    bindTip(rw,string.format("<b>%s</b>\n<font color=\"#B0B0C8\">%s</font>",it.n,it.tip),8)
    sw.MouseButton1Click:Connect(function() optCfg[it.k]=not optCfg[it.k] sw.BackgroundColor3=optCfg[it.k] and ac or bg sw.Text=optCfg[it.k] and "ON" or "OFF" end)
end
bindTip(fpsRow,"<b>Лимит FPS</b>\n<font color=\"#B0B0C8\">Ограничивает частоту кадров в секунду (например, 15 или 30 для твинков). Впиши 0, чтобы снять лимит.</font>",8)

fpsBox.FocusLost:Connect(function() local val=tonumber((fpsBox.Text:gsub("%D",""))) or 30 optCfg.fps=val fpsBox.Text=tostring(val) end)
optOpenB.MouseButton1Click:Connect(function() optModal.Visible=true end)
optCloseB.MouseButton1Click:Connect(function() tipBox.Visible=false optModal.Visible=false end)
optApplyB.MouseButton1Click:Connect(function()
    optCfg.fps=tonumber((fpsBox.Text:gsub("%D",""))) or 30
    fpsBox.Text=tostring(optCfg.fps)
    applyCustomOpt(table.clone(optCfg))
    tipBox.Visible=false
    optModal.Visible=false
end)

local modernTheme,menuAnimating = false,false
local refreshResponsiveText,setTheme
do
    local classicColors = {bg,sd,cd,ac,tx,sb,strokeColor,danger}
    local modernColors = {c(14,17,29),c(21,27,46),c(31,40,64),c(79,99,213),c(246,249,255),c(171,188,219),c(53,68,103),c(177,64,89)}
    local modal = ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p7,10,1)
    hideSettingsActionsBehind(modal)
    local title = lb(modal,"Оформление меню",u(1,-24,0,34),u(0,12,0,8),tx,18)
    title.TextSize,title.ZIndex = 15,9
    local classic = bt(modal,"Старый дизайн",u(1,-24,0,44),u(0,12,0,54),cd,8,1)
    local modern = bt(modal,"Новый дизайн",u(1,-24,0,44),u(0,12,0,106),ac,8,1)
    local back = bt(modal,"Готово",u(1,-24,0,36),u(0,12,1,-48),cd,8,1)
    classic.ZIndex,modern.ZIndex,back.ZIndex = 9,9,9
    local headerTint = Instance.new("UIGradient",tp)
    headerTint.Color = ColorSequence.new(c(255,255,255),c(128,151,245))
    local surfaceTint = Instance.new("UIGradient",m)
    surfaceTint.Color = ColorSequence.new(c(255,255,255),c(166,180,233))
    surfaceTint.Rotation = 65
    local divider = ui("Frame",{
        Size=u(1,-16,0,1), Position=u(0,8,1,-1), BorderSizePixel=0, BackgroundColor3=c(111,148,255),
    },tp)
    local dividerTint = Instance.new("UIGradient",divider)
    dividerTint.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(0.33,0.12),NumberSequenceKeypoint.new(1,1)})

    setTheme=function(useModern)
        local from,to = classicColors,modernColors
        if not useModern then from,to = modernColors,classicColors end
        if modernTheme ~= useModern then
            local function recolor(object,property)
                for index,color in ipairs(from) do
                    if object[property] == color then
                        object[property] = to[index]
                        break
                    end
                end
            end
            for _,object in ipairs(g:GetDescendants()) do
                if object:IsA("GuiObject") then recolor(object,"BackgroundColor3") end
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    recolor(object,"TextColor3")
                elseif object:IsA("UIStroke") then
                    recolor(object,"Color")
                end
            end
            bg,sd,cd,ac,tx,sb,strokeColor,danger = table.unpack(to)
            modernTheme = useModern
        end

        local navWidth = useModern and 112 or 98
        sdF.Size = u(navWidth/435,0,1,-34)
        for _,page in ipairs(pgs) do
            page.Position = u(navWidth/435,7,0,39)
            page.Size = u(1-navWidth/435,-14,1,-44)
        end
        local navHeight = useModern and 34 or 28
        for index,button in ipairs(tbs) do
            button.Size = u(1,-12,0,navHeight)
            button.Position = u(0,6,0,8+(index-1)*(navHeight+6))
            button.TextSize = useModern and 12 or 11
        end
        extra.navScroll.CanvasSize=u(0,0,0,8+#tbs*(navHeight+6))
        mB.Size,cB.Size = u(0,useModern and 28 or 24,0,useModern and 26 or 22),u(0,useModern and 28 or 24,0,useModern and 26 or 22)
        mB.Position,cB.Position = u(1,useModern and -68 or -54,0,useModern and 4 or 6),u(1,useModern and -34 or -27,0,useModern and 4 or 6)
        for _,button in ipairs({optOpenB,customB,configB,openAfk,tB,stAutoB,mSendB,mTakeB}) do
            button.TextSize = useModern and 13 or 11
            button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0,useModern and 10 or 8)
        end
        m:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0,useModern and 14 or 10)
        headerTint.Enabled,surfaceTint.Enabled,divider.Visible = useModern,useModern,useModern
        menuTitle.TextSize = useModern and 16 or 11
        menuTitle.TextColor3 = useModern and tx or ac
        oB.Size = useModern and u(0,104,0,34) or u(0,86,0,28)
        oB.TextSize = useModern and 13 or 11
        classic.BackgroundColor3 = useModern and cd or ac
        modern.BackgroundColor3 = useModern and ac or cd
        if refreshResponsiveText then refreshResponsiveText() end
    end

    customB.Activated:Connect(function() modal.Visible = true end)
    classic.Activated:Connect(function() setTheme(false) end)
    modern.Activated:Connect(function() setTheme(true) end)
    back.Activated:Connect(function() modal.Visible = false end)
    setTheme(false)
    if savedConfig.modern==true then
        task.defer(function() if g.Parent then setTheme(true) end end)
    end
end

do
    local baseWidth,baseHeight = m.Size.X.Offset,m.Size.Y.Offset
    local fonts = {}
    local emphasis = {[menuTitle]=true,[optOpenB]=true,[customB]=true,[configB]=true,[openAfk]=true,[tB]=true,[stAutoB]=true,[mSendB]=true,[mTakeB]=true}
    local function adaptFields(parent,width,height)
        for _,object in ipairs(parent:GetChildren()) do
            if not object:IsA("GuiObject") then continue end
            local size,position = object.Size,object.Position
            local childWidth,childHeight = size.X.Scale*width+size.X.Offset,size.Y.Scale*height+size.Y.Offset
            object.Size = u(size.X.Scale+size.X.Offset/width,0,size.Y.Scale+size.Y.Offset/height,0)
            object.Position = u(position.X.Scale+position.X.Offset/width,0,position.Y.Scale+position.Y.Offset/height,0)
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                fonts[object] = object.TextSize
            end
            if not object:IsA("ScrollingFrame") and childWidth>0 and childHeight>0 then
                adaptFields(object,childWidth,childHeight)
            end
        end
    end
    for _,page in ipairs(pgs) do
        adaptFields(page,baseWidth*page.Size.X.Scale+page.Size.X.Offset,baseHeight*page.Size.Y.Scale+page.Size.Y.Offset)
    end
    adaptFields(dlg,baseWidth,baseHeight)
    fonts[menuTitle] = menuTitle.TextSize
    for _,button in ipairs(tbs) do fonts[button] = button.TextSize end
    refreshResponsiveText = function()
        local factor = math.clamp(math.min(m.Size.X.Offset/baseWidth,m.Size.Y.Offset/baseHeight),1,1.35)
        for label,original in pairs(fonts) do
            local size = original
            if modernTheme then
                if label == menuTitle then size = 16
                elseif emphasis[label] then size = math.max(size,13)
                else size += 1 end
            end
            label.TextSize = math.floor(size*factor+0.5)
        end
    end
    m:GetPropertyChangedSignal("Size"):Connect(refreshResponsiveText)
end

local tog
do
    local TweenService = game:GetService("TweenService")
    local menuOpen = true
    local tween,animationId = nil,0
    local phase = Instance.new("NumberValue",g)
    phase.Value = 1
    local morph = ui("Frame",{
        Size=u(1,0,1,0), BackgroundTransparency=1, Visible=false, Active=true, ZIndex=27,
    },g)
    local bands = {}
    for index=1,22 do
        local band = ui("Frame",{
            BorderSizePixel=0, BackgroundColor3=c(54,73,151), ZIndex=28,
        },morph)
        local tint = Instance.new("UIGradient",band)
        tint.Color = ColorSequence.new(c(105,124,255),c(113,218,255))
        bands[index] = band
    end

    local function absolute(value,area)
        return Vector2.new(value.X.Scale*area.X+value.X.Offset,value.Y.Scale*area.Y+value.Y.Offset)
    end

    local function drawMorph(progress)
        if not menuAnimating then return end
        local area = g.AbsoluteSize
        local buttonPos,buttonSize = absolute(oB.Position,area),absolute(oB.Size,area)
        local windowPos,windowSize = absolute(m.Position,area),absolute(m.Size,area)
        local buttonCenter,windowCenter = buttonPos+buttonSize/2,windowPos+windowSize/2
        local arc = math.sin(math.pi*progress)
        local height = buttonSize.Y+(windowSize.Y-buttonSize.Y)*progress
        local top = buttonCenter.Y+(windowCenter.Y-buttonCenter.Y)*progress-height/2-22*arc
        for index,band in ipairs(bands) do
            local row = (index-0.5)/#bands
            local spread = progress^(0.65+row*1.15)
            local width = buttonSize.X+(windowSize.X-buttonSize.X)*spread
            local center = buttonCenter.X+(windowCenter.X-buttonCenter.X)*spread+arc*24*math.sin(math.pi*row)
            band.Position = u(0,center-width/2,0,top+(index-1)*height/#bands)
            band.Size = u(0,width,0,height/#bands+1)
            local fade = math.max(0,progress-0.79)*4.8+math.max(0,0.065-progress)*13
            band.BackgroundTransparency = math.clamp(0.09+0.25*row+fade,0,1)
        end
        m.Visible = progress>=0.86
        oB.Visible = progress<=0.075
    end
    phase:GetPropertyChangedSignal("Value"):Connect(function() drawMorph(phase.Value) end)

    tog = function(open,immediate)
        if open == nil then open = not menuOpen end
        if open == menuOpen and not immediate then return end
        menuOpen = open
        animationId += 1
        local id = animationId
        if tween then tween:Cancel() tween = nil end

        local target = open and 1 or 0
        if not modernTheme or immediate then
            menuAnimating,morph.Visible = false,false
            phase.Value = target
            m.Visible,oB.Visible = open,not open
            return
        end

        menuAnimating,morph.Visible = true,true
        drawMorph(phase.Value)
        local duration = math.max(0.09,(open and 0.47 or 0.39)*math.abs(target-phase.Value))
        tween = TweenService:Create(phase,TweenInfo.new(duration,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Value=target})
        tween.Completed:Once(function(state)
            if state ~= Enum.PlaybackState.Completed or animationId ~= id then return end
            tween = nil
            menuAnimating,morph.Visible = false,false
            m.Visible,oB.Visible = open,not open
        end)
        tween:Play()
    end
    g.Destroying:Connect(function() if tween then tween:Cancel() end end)
end
mB.MouseButton1Click:Connect(function() tog(false) end)

local afkPurchases = {count=0, spent=0, byRarity={}, last="—"}
local afkRolls = (function()
    local afkRolls = {available=false, count=0, caught=0, byRarity={}, last="—", lastPrice="—"}
    local rarityByText = {
        ["ОБЫЧНЫЙ"]="COMMON", ["Обычный"]="COMMON",
        ["НЕОБЫЧНЫЙ"]="UNCOMMON", ["Необычный"]="UNCOMMON",
        ["РЕДКИЙ"]="RARE", ["ЭПИЧЕСКИЙ"]="EPIC",
        ["МИФИЧЕСКИЙ"]="MYTHIC", ["ЛЕГЕНДАРНЫЙ"]="LEGENDARY",
    }
    for _,rarity in ipairs(rars) do
        rarityByText[rarity.n] = rarity.id
        rarityByText[rarity.id] = rarity.id
    end

    local function plainText(label)
        return label.Text:gsub("<[^>]*>", ""):match("^%s*(.-)%s*$")
    end

    local function parsePrice(label, requireCurrency)
        if not label or not label:IsA("TextLabel") then return end
        local value = plainText(label)
        if requireCurrency and not value:match("₽$") then return end
        local digits = value:gsub("₽$", ""):gsub("%s", "")
        digits = digits:gsub(utf8.char(160), ""):gsub(utf8.char(8239), "")
        return tonumber(digits:match("^%d+$"))
    end

    local function readPrice(card)
        local body = card:FindFirstChild("Body")
        local priceBox = body and body:FindFirstChild("CanvasGroup")
        if priceBox then
            local price = parsePrice(priceBox:GetChildren()[3],false)
            if price then return fmtNum(price).." ₽" end
        end
        for _,root in ipairs(priceBox and {priceBox,card} or {card}) do
            for _,label in ipairs(root:GetChildren()) do
                local price = parsePrice(label,true)
                if price then return fmtNum(price).." ₽" end
            end
        end
    end

    local miniPrices = {}
    local function readMiniPrices(container, depth)
        if depth > 0 then
            local best, bestCount, bestTotal = nil,0,0
            for _,frame in ipairs(container:GetChildren()) do
                if frame.Name == "Frame" and frame:IsA("Frame") and frame.Visible then
                    local prices,count,total = readMiniPrices(frame,depth-1)
                    if count > bestCount then best,bestCount,bestTotal = prices,count,total end
                end
            end
            return best,bestCount,bestTotal
        end

        local prices,count,total = {},0,0
        for _,card in ipairs(container:GetChildren()) do
            if card:IsA("Frame") and card.Visible then
                local label = card:FindFirstChild("TextLabel")
                local price = parsePrice(label,false)
                if price then
                    prices[label] = price
                    count += 1
                    total += price
                end
            end
        end
        return prices,count,total
    end

    local function observeMiniRoll(mini)
        local prices,count,total
        if mini and mini.Visible then prices,count,total = readMiniPrices(mini,3) end
        if not prices or count == 0 then
            table.clear(miniPrices)
            return
        end

        local changed = false
        for label,price in pairs(prices) do
            if miniPrices[label] ~= price then changed = true break end
        end
        if not changed then
            for label in pairs(miniPrices) do
                if prices[label] == nil then changed = true break end
            end
        end
        miniPrices = prices
        if changed then afkRolls.batchPrice = fmtNum(total).." ₽" end
    end

    local function readPlate(plate)
        local labels = {}
        local function normalize(value)
            local compact = value:gsub("%s", ""):gsub(utf8.char(160), ""):gsub("RUS$", "")
            local first,digits,ending,region = compact:match("^(%D+)(%d%d%d)(%D+)(%d%d%d?)$")
            if first and utf8.len(first)==1 and utf8.len(ending)==2 then
                return first..digits..ending.." "..region
            end
        end
        for _,label in ipairs(plate:GetDescendants()) do
            if label:IsA("TextLabel") and label.Visible then
                local value = plainText(label)
                local number = normalize(value)
                if number then return number end
                if value ~= "" and value ~= "RUS" then table.insert(labels,label) end
            end
        end
        table.sort(labels,function(a,b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
        local parts = {}
        for _,label in ipairs(labels) do table.insert(parts,plainText(label)) end
        return normalize(table.concat(parts))
    end

    local seen = {}
    local latestCard,results
    local function observeCard(card,baseline)
        if not card:IsA("GuiObject") or not card.Visible then return end
        local header,plate = card:FindFirstChild("Frame"),card:FindFirstChild("Plate")
        if not header or not plate then return end

        local rarity,caption
        for _,label in ipairs(header:GetChildren()) do
            if label:IsA("TextLabel") and label.Visible then
                caption = plainText(label)
                rarity = rarityByText[caption]
                if rarity then break end
            end
        end
        if not rarity then return end

        local number = readPlate(plate)
        local previous = seen[card]
        if previous and previous.rarity == rarity and (not number or not previous.number or previous.number == number) then
            if number and not previous.number then
                previous.number = number
                if latestCard == card then afkRolls.last = number end
            end
            if latestCard == card then
                afkRolls.lastPrice = readPrice(card) or afkRolls.lastPrice
            end
            return
        end
        seen[card] = {rarity=rarity, number=number}
        if baseline then return end

        afkRolls.count += 1
        if rarMap[rarity] then
            afkRolls.caught += 1
            afkRolls.byRarity[rarity] = (afkRolls.byRarity[rarity] or 0) + 1
        end
        latestCard = card
        afkRolls.last = number or caption
        afkRolls.lastPrice = readPrice(card) or "—"
        afkRolls.batchPrice = nil
    end

    local mini,stopResults,stopMini
    local resultsDirty,miniDirty,scanQueued = false,false,false
    local function queueScan(fullChanged,miniChanged)
        resultsDirty,miniDirty = resultsDirty or fullChanged,miniDirty or miniChanged
        if scanQueued then return end
        scanQueued = true
        task.defer(function()
            scanQueued = false
            if not g.Parent then return end
            if resultsDirty and results then
                for _,card in ipairs(results:GetChildren()) do observeCard(card,not afkRolls.available) end
                afkRolls.available = true
                for card in pairs(seen) do
                    if card.Parent ~= results then seen[card] = nil end
                end
            end
            if miniDirty then observeMiniRoll(mini) end
            resultsDirty,miniDirty = false,false
        end)
    end

    local function watchRollTree(root,changed)
        local watched = {}
        local function watch(object)
            if not object:IsA("GuiObject") then return end
            local connections = {object:GetPropertyChangedSignal("Visible"):Connect(changed)}
            if object:IsA("TextLabel") then
                table.insert(connections,object:GetPropertyChangedSignal("Text"):Connect(changed))
            end
            watched[object] = connections
        end
        local function release(object)
            local connections = watched[object]
            if not connections then return end
            for _,connection in ipairs(connections) do connection:Disconnect() end
            watched[object] = nil
        end
        watch(root)
        for _,object in ipairs(root:GetDescendants()) do watch(object) end
        local inserted = root.DescendantAdded:Connect(function(object) watch(object) changed() end)
        local removed = root.DescendantRemoving:Connect(function(object) release(object) changed() end)
        return function()
            inserted:Disconnect()
            removed:Disconnect()
            for object in pairs(watched) do release(object) end
        end
    end

    local function bindRollTrees()
        local pg = plr:FindFirstChild("PlayerGui")
        local plates = pg and pg:FindFirstChild("PlatesUI")
        local window = plates and plates:FindFirstChild("RollWindow") or (pg and pg:FindFirstChild("RollWindow",true))
        local nextResults = window and window:FindFirstChild("Results")
        local nextMini = plates and plates:FindFirstChild("RollMini")
        if nextResults ~= results then
            if stopResults then stopResults() stopResults = nil end
            results = nextResults
            table.clear(seen)
            latestCard = nil
            if results then stopResults = watchRollTree(results,function() queueScan(true,false) end) end
            queueScan(true,false)
        end
        if nextMini ~= mini then
            if stopMini then stopMini() stopMini = nil end
            mini = nextMini
            table.clear(miniPrices)
            if mini then stopMini = watchRollTree(mini,function() queueScan(false,true) end) end
            queueScan(false,true)
        end
    end

    local rollRootNames = {PlayerGui=true,PlatesUI=true,RollWindow=true,Results=true,RollMini=true}
    local bindQueued = false
    local function onRollTreeChanged(object)
        if bindQueued or not rollRootNames[object.Name] then return end
        bindQueued = true
        task.defer(function()
            bindQueued = false
            if g.Parent then bindRollTrees() end
        end)
    end
    local rollAdded = plr.DescendantAdded:Connect(onRollTreeChanged)
    local rollRemoved = plr.DescendantRemoving:Connect(onRollTreeChanged)
    g.Destroying:Connect(function()
        rollAdded:Disconnect()
        rollRemoved:Disconnect()
        if stopResults then stopResults() end
        if stopMini then stopMini() end
    end)
    bindRollTrees()
    return afkRolls
end)()

local exitAfkMode = (function()
    local overlay = ui("Frame", {
        Size=u(1,0,1,0), BackgroundColor3=bg, BackgroundTransparency=0.15,
        Visible=false, Active=true, ZIndex=30, BorderSizePixel=0,
    },g)
    local card = ui("Frame", {
        Size=u(0,520,0,356), Position=u(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=bg, ZIndex=31,
    },overlay,12,1)
    local scale = Instance.new("UIScale",card)
    local function fitCard()
        local area = overlay.AbsoluteSize
        scale.Scale = math.clamp(math.min((area.X-16)/520,(area.Y-16)/356),0.25,1)
    end
    overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCard)

    local green = c(74,222,128)
    local function frame(parent,size,position,color,radius)
        return ui("Frame",{
            Size=size, Position=position, BackgroundColor3=color or sd,
            BorderSizePixel=0, ZIndex=32,
        },parent,radius or 8,1)
    end
    local function text(parent,value,size,position,color,alignment)
        local label = lb(parent,value,size,position,color,18,alignment)
        label.ZIndex = 33
        return label
    end

    local timerBox = frame(card,u(0,186,0,48),u(0,12,0,19))
    local timer = text(timerBox,"AFK 00:00:00",u(1,0,1,0),u(0,0,0,0),tx,Enum.TextXAlignment.Center)
    timer.TextSize = 14
    local avatar = ui("ImageLabel",{
        Size=u(0,50,0,50), Position=u(0.5,-25,0,10), BackgroundColor3=cd,
        Image=avatarImage, ZIndex=33,
    },card,25,1)
    ui("Frame",{Size=u(0,9,0,9),Position=u(1,-9,1,-9),BackgroundColor3=green,BorderSizePixel=0,ZIndex=34},avatar,5)
    local name = text(card,plr.DisplayName,u(0,118,0,16),u(0.5,-59,0,60),tx,Enum.TextXAlignment.Center)
    name.TextTruncate = Enum.TextTruncate.AtEnd

    local balanceBox = frame(card,u(0,186,0,48),u(1,-198,0,19))
    text(balanceBox,"Текущий баланс",u(1,0,0,18),u(0,0,0,5),sb,Enum.TextXAlignment.Center)
    local balance = text(balanceBox,"—",u(1,0,0,20),u(0,0,0,22),green,Enum.TextXAlignment.Center)
    balance.TextSize = 14

    local function section(title,x,firstCaption,secondCaption,lastCaption,extraCaption)
        local column = frame(card,u(0,244,0,231),u(0,x,0,82))
        local heading = text(column,title,u(1,-20,0,21),u(0,10,0,6),ac)
        heading.TextSize = 14
        local function metric(parent,caption,y,initial,color)
            local captionLabel = text(parent,caption,u(0.46,-7,0,19),u(0,8,0,y),sb)
            captionLabel.TextTruncate = Enum.TextTruncate.AtEnd
            local value = text(parent,initial,u(0.55,-8,0,19),u(0.45,0,0,y),color or tx,Enum.TextXAlignment.Right)
            value.TextTruncate = Enum.TextTruncate.AtEnd
            return value,captionLabel
        end
        local first = metric(column,firstCaption,32,"—")
        local second = metric(column,secondCaption,51,"—",green)
        local counts = {}
        for index,rarity in ipairs(rars) do
            local row = frame(column,u(1,-16,0,21),u(0,8,0,72+(index-1)*23),cd,5)
            ui("Frame",{Size=u(0,3,0,13),Position=u(0,4,0,4),BackgroundColor3=rarity.col,BorderSizePixel=0,ZIndex=33},row,2)
            counts[rarity.id] = metric(row,rarity.n,1,"—")
        end
        local lastBox = frame(column,u(1,-16,0,48),u(0,8,0,175),bg,5)
        local last = metric(lastBox,lastCaption,extraCaption and 4 or 14,"—")
        local extra,extraLabel
        if extraCaption then extra,extraLabel = metric(lastBox,extraCaption,24,"—",green) end
        return first,second,counts,last,extra,extraLabel
    end

    local bought,spent,counts,last = section("Снайпер рынка",12,"Куплено лотов","Потрачено","Последний")
    local rolled,caught,rollCounts,lastRoll,lastPrice,priceLabel = section("Крутки номеров",264,"Прокруты","Улов (редкие+)","Выпавший","Стоимость")
    local closeAfk = bt(card,"Выйти из AFK-режима",u(0,184,0,26),u(0.5,-92,1,-34),cd,6,1)
    closeAfk.ZIndex = 33

    local function readBalanceLabel(label)
        if not label or not (label:IsA("TextLabel") or label:IsA("TextButton")) then return end
        local amountText = label.Text:gsub("<[^>]*>", ""):gsub("%s", "")
        amountText = amountText:gsub(utf8.char(160), ""):gsub(utf8.char(8239), "")
        local currency = amountText:match("^(%d+)₽$") or amountText:match("^₽(%d+)$")
        return tonumber(currency or amountText:match("^%d+$")), currency ~= nil
    end

    local function readBalance()
        local pg = plr:FindFirstChild("PlayerGui")
        local plates = pg and pg:FindFirstChild("PlatesUI")
        local dock = plates and plates:FindFirstChild("Dock")
        local money = dock and dock:FindFirstChild("Money")
        if money then
            local value = readBalanceLabel(money)
            if value ~= nil then return value end
            if money:IsA("IntValue") or money:IsA("NumberValue") then return money.Value end

            local unique, hasCurrency, conflict
            for _,label in ipairs(money:GetDescendants()) do
                local amount, withCurrency = readBalanceLabel(label)
                if amount ~= nil then
                    if withCurrency and not hasCurrency then
                        unique,hasCurrency,conflict = amount,true,false
                    elseif withCurrency == (hasCurrency == true) then
                        conflict = conflict or (unique ~= nil and unique ~= amount)
                        unique = amount
                    end
                end
            end
            if unique ~= nil and not conflict then return unique end
        end

        local leaderstats = plr:FindFirstChild("leaderstats")
        for _,key in ipairs({"Money","Cash","Balance","RUB","Баланс","Деньги","₽"}) do
            local value = plr:GetAttribute(key)
            if type(value) == "number" then return value end
            local stat = leaderstats and leaderstats:FindFirstChild(key)
            if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return stat.Value end
        end

        local top = plates and plates:FindFirstChild("TopPanel")
        if not top then return end

        local function isBalanceName(name)
            local lower = name:lower()
            return lower:find("money",1,true) or lower:find("cash",1,true)
                or lower:find("balance",1,true) or lower == "rub"
                or name == "Баланс" or name == "Деньги" or name == "₽"
        end

        local named, currency
        local namedConflict, currencyConflict = false,false
        for _,label in ipairs(top:GetDescendants()) do
            local value, withCurrency = readBalanceLabel(label)
            if withCurrency and label:IsA("TextLabel") then
                currencyConflict = currencyConflict or (currency ~= nil and currency ~= value)
                currency = value
            end
            if value and (isBalanceName(label.Name) or isBalanceName(label.Parent.Name)) then
                namedConflict = namedConflict or (named ~= nil and named ~= value)
                named = value
            end
        end
        if named ~= nil and not namedConflict then return named end
        if not currencyConflict then return currency end
    end

    local startedAt, previousOpt, previousOrder
    local function refreshAfk()
        local elapsed = math.floor(os.clock()-startedAt)
        timer.Text = string.format("AFK %02d:%02d:%02d",math.floor(elapsed/3600),math.floor(elapsed/60)%60,elapsed%60)
        local money = readBalance()
        balance.Text = money and fmtNum(money).." ₽" or "—"
        bought.Text = tostring(afkPurchases.count)
        spent.Text = fmtNum(afkPurchases.spent).." ₽"
        for id,label in pairs(counts) do label.Text = "×"..(afkPurchases.byRarity[id] or 0) end
        last.Text = afkPurchases.last
        if afkRolls.available then
            rolled.Text = tostring(afkRolls.count)
            caught.Text = tostring(afkRolls.caught)
            for id,label in pairs(rollCounts) do label.Text = "×"..(afkRolls.byRarity[id] or 0) end
            lastRoll.Text = afkRolls.last
        end
        lastPrice.Text = afkRolls.batchPrice or afkRolls.lastPrice
        priceLabel.Text = afkRolls.batchPrice and "Стоимость пачки" or "Стоимость"
    end

    local function exitAfkMode()
        if not overlay.Visible then return false end
        overlay.Visible = false
        g.DisplayOrder = previousOrder
        applyCustomOpt(previousOpt)
        tog(true)
        return true
    end
    closeAfk.Activated:Connect(exitAfkMode)
    extra.enterAfkMode=function()
        if overlay.Visible then return end
        previousOpt,previousOrder = appliedOpt,g.DisplayOrder
        startedAt = os.clock()
        tipBox.Visible = false
        tog(false,true)
        oB.Visible = false
        g.DisplayOrder = 10000
        overlay.Visible = true
        fitCard()
        refreshAfk()
        applyCustomOpt({
            shadows=true, materials=true, textures=true, particles=true,
            cleanup=optCfg.cleanup, no3d=true, hideui=true, fps=optCfg.fps,
        })
    end
    openAfk.Activated:Connect(extra.enterAfkMode)
    task.spawn(function()
        while g.Parent do
            if overlay.Visible then refreshAfk() end
            task.wait(1)
        end
    end)
    return exitAfkMode
end)()

-- Telegram credentials remain in the executor's local workspace, never in shared configs.
do
    local endpointFile="GGT/stats_"..tostring(plr.UserId)..".json"
    local sharedFile="GGT/stats_link.json"
    local requestFn=type(request)=="function" and request or type(http_request)=="function" and http_request or (type(syn)=="table" and syn.request)
    local cfg={url="https://hub-popcontrol.ru",token="",enabled=false}
    if type(readfile)=="function" then
        local ok,data=pcall(function() return Http:JSONDecode(readfile(endpointFile)) end)
        if ok and type(data)=="table" and type(data.url)=="string" and type(data.token)=="string" then
            cfg.url=data.url cfg.token=data.token cfg.enabled=data.enabled==true
        end
    end
    local function validUrl(url)
        return type(url)=="string" and #url<=200 and url:match("^https://[%w%.%-]+:?%d*$")~=nil
    end
    extra.mailRequest=function(method,path,body)
        if not cfg.enabled or type(requestFn)~="function" or cfg.token=="" or not validUrl(cfg.url) then return nil end
        local headers={Authorization="Bearer "..cfg.token}
        local options={Url=cfg.url..path,Method=method,Headers=headers}
        if body then
            local encodedOk,encoded=pcall(function() return Http:JSONEncode(body) end)
            if not encodedOk then return nil end
            headers["Content-Type"]="application/json" options.Body=encoded
        end
        local ok,response=pcall(function() return requestFn(options) end)
        if not ok or type(response)~="table" then return nil end
        return response
    end
    do
        local recent={}
        extra.reportGameError=function(source,message)
            if type(message)~="string" or message=="" or not cfg.enabled then return end
            local key=tostring(source).."\0"..message
            local now=os.clock()
            if recent[key] and now-recent[key]<120 then return end
            recent[key]=now
            for k,t in pairs(recent) do if now-t>600 then recent[k]=nil end end
            task.spawn(function() extra.mailRequest("POST","/api/events/error",{source=tostring(source):sub(1,32),message=message:sub(1,300)}) end)
        end
        local toast=Rem:FindFirstChild("Toast")
        local connection=toast and toast:IsA("RemoteEvent") and toast.OnClientEvent:Connect(function(message,kind)
            if kind=="err" or kind=="error" then extra.reportGameError("Игра",message) end
        end)
        g.Destroying:Connect(function() if connection then connection:Disconnect() end end)
    end
    if not validUrl(cfg.url) then cfg.enabled=false cfg.token="" cfg.url="https://hub-popcontrol.ru" end
    local shared=nil
    if type(readfile)=="function" then
        local ok,data=pcall(function() return Http:JSONDecode(readfile(sharedFile)) end)
        if ok and type(data)=="table" and validUrl(data.url) and type(data.code)=="string" and #data.code>=20 and #data.code<=100 then shared=data end
    end
    local function writeVerified(path,data)
        if type(writefile)~="function" or type(readfile)~="function" then return false end
        if type(makefolder)=="function" then pcall(makefolder,"GGT") end
        local encoded=Http:JSONEncode(data)
        local ok=pcall(function() writefile(path,encoded) end)
        local readOk,stored=pcall(readfile,path)
        return ok and readOk and stored==encoded
    end
    local function saveSettings()
        return writeVerified(endpointFile,cfg)
    end
    local panel=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,Active=true,ZIndex=40},m,10,1)
    hideSettingsActionsBehind(panel)
    local title=lb(panel,"Telegram: привязка аккаунта",u(1,-55,0,26),u(0,12,0,8),tx,18)
    title.ZIndex=41
    local close=bt(panel,"×",u(0,32,0,26),u(1,-40,0,8),cd,6,1) close.ZIndex=41
    local url=bx(panel,cfg.url,u(1,-24,0,28),u(0,12,0,43)) url.ZIndex=41 url.PlaceholderText="https://адрес-сервера"
    local code=bx(panel,"",u(1,-24,0,28),u(0,12,0,77)) code.ZIndex=41 code.PlaceholderText="Общий код из /link"
    local link=bt(panel,"ПРИВЯЗАТЬ",u(0.48,-12,0,32),u(0,12,0,112),ac,6) link.ZIndex=41
    local toggle=bt(panel,"",u(0.52,-12,0,32),u(0.48,0,0,112),cd,6,1) toggle.ZIndex=41
    local status=lb(panel,"",u(1,-24,0,68),u(0,12,0,151),sb,17) status.TextWrapped=true status.ZIndex=41
    local function updateToggle()
        toggle.Text=cfg.enabled and "ОТПРАВКА: ВКЛ" or "ОТПРАВКА: ВЫКЛ"
        toggle.BackgroundColor3=cfg.enabled and ac or cd
    end
    updateToggle()
    status.Text=cfg.token~="" and (cfg.enabled and "Аккаунт привязан. Отправка включена." or "Аккаунт привязан. Отправка выключена.") or (shared and "Общий код найден; подключаю аккаунт." or "Вставь общий код из /link.")
    close.Activated:Connect(function() panel.Visible=false end)
    statsOpenB.Activated:Connect(function() panel.Visible=true end)
    local busy=false
    local function pairAccount(target,pairing)
        if busy or type(requestFn)~="function" then return end
        busy=true status.Text="Привязываю..."
        task.spawn(function()
            local ok,response=pcall(function() return requestFn({Url=target.."/api/pair",Method="POST",Headers={["Content-Type"]="application/json"},Body=Http:JSONEncode({code=pairing,roblox_user_id=plr.UserId,username=plr.Name})}) end)
            busy=false code.Text=""
            if not g.Parent then return end
            local statusCode=ok and type(response)=="table" and (response.StatusCode or response.Status)
            local parsed,data=pcall(function() return Http:JSONDecode(response.Body) end)
            if statusCode==200 and parsed and type(data)=="table" and type(data.client_token)=="string" and #data.client_token>=32 then
                cfg={url=target,token=data.client_token,enabled=true}
                if saveSettings() then updateToggle() status.Text="Аккаунт привязан. Отправка статистики включена."
                else updateToggle() status.Text="Ключ не сохранён executor; общий код поможет восстановить привязку." end
            else status.Text="Не удалось привязать аккаунт: проверь адрес и код." end
        end)
    end
    link.Activated:Connect(function()
        if busy then return end
        if type(requestFn)~="function" then status.Text="Executor не поддерживает HTTP-запросы." return end
        local target=url.Text:gsub("%s+",""):gsub("/+$","")
        local pairing=code.Text:gsub("%s+","")
        if not validUrl(target) or #pairing<20 or #pairing>100 then status.Text="Укажи HTTPS-адрес и код из /link." return end
        local candidate={url=target,code=pairing}
        if not writeVerified(sharedFile,candidate) then status.Text="Executor не сохранил код. Проверь доступ к файлам." return end
        shared=candidate
        pairAccount(target,pairing)
    end)
    toggle.Activated:Connect(function()
        if cfg.token=="" then status.Text="Сначала привяжи аккаунт." return end
        cfg.enabled=not cfg.enabled
        if not saveSettings() then cfg.enabled=not cfg.enabled status.Text="Не удалось сохранить настройку." else status.Text=cfg.enabled and "Отправка включена." or "Отправка выключена." end
        updateToggle()
    end)
    local latestBalance=nil
    local stateRemote=Rem:FindFirstChild("StateChanged")
    local stateConnection=stateRemote and stateRemote.OnClientEvent:Connect(function(state)
        if type(state)=="table" and type(state.money)=="number" and state.money>=0 then latestBalance=math.floor(state.money) end
    end)
    g.Destroying:Connect(function() if stateConnection then stateConnection:Disconnect() end end)
    local session=Http:GenerateGUID(false)
    local seq=0
    extra.statsSession=session extra.statsSequence=0
    if cfg.token=="" and shared then pairAccount(shared.url,shared.code) end
    task.spawn(function()
        local getState=Rem:FindFirstChild("GetState")
        if getState then
            local ok,state=pcall(function() return getState:InvokeServer() end)
            if ok and type(state)=="table" and type(state.money)=="number" and state.money>=0 then latestBalance=math.floor(state.money) end
        end
    end)
    task.spawn(function()
        while g.Parent do
            if cfg.enabled and type(requestFn)=="function" and validUrl(cfg.url) and cfg.token~="" then
                seq=seq+1
                extra.statsSequence=seq
                local data={session_id=session,sequence=seq,rolls_available=afkRolls.available,rolls=afkRolls.count,caught=afkRolls.caught,purchases=afkPurchases.count,spent=afkPurchases.spent,balance=latestBalance,last_roll=afkRolls.last,last_purchase=afkPurchases.last,purchased_mythic=afkPurchases.byRarity.MYTHIC or 0,rolled_mythic=afkRolls.byRarity.MYTHIC or 0,rolled_epic=afkRolls.byRarity.EPIC or 0}
                local scanOk,plates,verified,counts=pcall(scanMyPlates)
                if scanOk and verified then
                    local candidates={}
                    for _,plate in ipairs(plates) do
                        if #candidates>=3000 then break end
                        candidates[#candidates+1]={id=plate.id,rarity=plate.label:match("%[([^%]]+)%]$") or "UNKNOWN"}
                    end
                    data.mail_plates=candidates data.mail_truncated=#plates>3000 data.garage_counts=counts
                end
                local ok,response=pcall(function() return requestFn({Url=cfg.url.."/api/heartbeat",Method="POST",Headers={["Content-Type"]="application/json",Authorization="Bearer "..cfg.token},Body=Http:JSONEncode(data)}) end)
                if ok and type(response)=="table" and (response.StatusCode or response.Status)==401 and shared and shared.url==cfg.url then pairAccount(shared.url,shared.code) end
                if panel.Visible then status.Text=ok and type(response)=="table" and (response.StatusCode or response.Status)==200 and "Статистика отправлена." or "Не удалось отправить статистику." end
            end
            task.wait(60)
        end
    end)
end

do
    local resizeInput,resizeStart,edge,baseSize,basePosition
    local minimumWidth,minimumHeight = m.Size.X.Offset,m.Size.Y.Offset

    local function resizeHandle(size,position,xDirection,yDirection)
        local handle = ui("Frame",{
            Size=size, Position=position, BackgroundTransparency=1, Active=true, ZIndex=6,
        },m)
        handle.InputBegan:Connect(function(input)
            local kind = input.UserInputType
            if resizeInput or menuAnimating or dlg.Visible then return end
            if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end
            resizeInput,resizeStart = input,input.Position
            edge = Vector2.new(xDirection,yDirection)
            baseSize,basePosition = m.Size,m.Position
        end)
    end

    resizeHandle(u(1,-20,0,6),u(0,10,0,0),0,-1)
    resizeHandle(u(1,-20,0,6),u(0,10,1,-6),0,1)
    resizeHandle(u(0,6,1,-20),u(0,0,0,10),-1,0)
    resizeHandle(u(0,6,1,-20),u(1,-6,0,10),1,0)
    for _,x in ipairs({-1,1}) do
        for _,y in ipairs({-1,1}) do
            resizeHandle(u(0,10,0,10),u(x==1 and 1 or 0,x==1 and -10 or 0,y==1 and 1 or 0,y==1 and -10 or 0),x,y)
        end
    end

    local resizeMove = U.InputChanged:Connect(function(input)
        if not resizeInput or not m.Visible or menuAnimating then return end
        local mouseMove = resizeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        if not mouseMove and input ~= resizeInput then return end

        local delta = input.Position-resizeStart
        local width = math.max(minimumWidth,baseSize.X.Offset+delta.X*edge.X)
        local height = math.max(minimumHeight,baseSize.Y.Offset+delta.Y*edge.Y)
        local shiftX = edge.X < 0 and baseSize.X.Offset-width or 0
        local shiftY = edge.Y < 0 and baseSize.Y.Offset-height or 0
        m.Size = u(0,width,0,height)
        m.Position = u(basePosition.X.Scale,basePosition.X.Offset+shiftX,basePosition.Y.Scale,basePosition.Y.Offset+shiftY)
    end)
    local resizeEnd = U.InputEnded:Connect(function(input)
        if input == resizeInput then resizeInput = nil end
    end)
    m:GetPropertyChangedSignal("Visible"):Connect(function()
        if not m.Visible then resizeInput = nil end
    end)
    g.Destroying:Connect(function()
        resizeMove:Disconnect()
        resizeEnd:Disconnect()
    end)
end

local dragWin,winStart,winPos=false,nil,nil
tp.InputBegan:Connect(function(i)
    if menuAnimating then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragWin,winStart,winPos=true,i.Position,m.Position
    end
end)

local draggingBtn,movedBtn,dragStart,startPos=false,false,nil,nil
oB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        draggingBtn,movedBtn,dragStart,startPos=true,false,i.Position,oB.Position
    end
end)

local dragMove = U.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        if dragWin and not menuAnimating then
            local d=i.Position-winStart
            m.Position=UDim2.new(winPos.X.Scale,winPos.X.Offset+d.X,winPos.Y.Scale,winPos.Y.Offset+d.Y)
        elseif draggingBtn then
            local d=i.Position-dragStart
            if d.Magnitude>5 then movedBtn=true oB.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
        end
    end
end)

local dragEnd = U.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragWin=false
        if draggingBtn then
            draggingBtn=false
            if not movedBtn then tog(true) end
        end
    end
end)

cB.MouseButton1Click:Connect(function() dlg.Visible=true end)
nB.MouseButton1Click:Connect(function() dlg.Visible=false end)
yB.MouseButton1Click:Connect(function()
    run,takeRun,stRun=false,false,false
    if appliedOpt then applyCustomOpt(nil) end
    g:Destroy()
end)
bindB.MouseButton1Click:Connect(function() extra.waitingAfkBind=false waitingBind=true bindB.Text="Нажми клавишу..." end)
extra.afkBindB.MouseButton1Click:Connect(function() waitingBind=false extra.waitingAfkBind=true extra.afkBindB.Text="Нажми клавишу..." end)
afkB.MouseButton1Click:Connect(function() afkOn=not afkOn afkB.BackgroundColor3=afkOn and ac or bg afkB.Text=afkOn and "ON" or "OFF" end)
local idleConnection = plr.Idled:Connect(function() if afkOn and g.Parent then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end end)
local hotkey = U.InputBegan:Connect(function(i,gp)
    if not g.Parent then return end
    if extra.waitingAfkBind and i.UserInputType==Enum.UserInputType.Keyboard then
        extra.waitingAfkBind=false
        if i.KeyCode==Enum.KeyCode.Escape then extra.afkKey=Enum.KeyCode.Unknown
        elseif i.KeyCode~=menuKey then extra.afkKey=i.KeyCode end
        extra.afkBindB.Text=extra.afkKey~=Enum.KeyCode.Unknown and extra.afkKey.Name or "Не задана"
        return
    end
    if waitingBind and i.UserInputType==Enum.UserInputType.Keyboard then
        waitingBind=false if i.KeyCode~=extra.afkKey then menuKey=i.KeyCode end bindB.Text=menuKey.Name return
    end
    if not gp and extra.afkKey~=Enum.KeyCode.Unknown and i.KeyCode==extra.afkKey then
        if not exitAfkMode() then extra.enterAfkMode() end
        return
    end
    if not gp and i.KeyCode==menuKey then
        if exitAfkMode() then return end
        dlg.Visible=false
        tog()
    end
end)
g.Destroying:Connect(function()
    dragMove:Disconnect()
    dragEnd:Disconnect()
    idleConnection:Disconnect()
    hotkey:Disconnect()
end)

-- Выбор тира и запуск по таймеру или один раз по счётчику круток.
local itemRule={tiers={true,false,false},mode="timer"}
do
    lb(p9,"Выбери тиры зелий (удача, скорость, деньги):",u(1,-8,0,20),u(0,4,0,0),sb,17)
    local tierButtons={}
    local info
    local armed,starting,generation=false,false,0
    local lastCount,target,observedCount,observedVersion=nil,nil,nil,0
    local function stop()
        generation+=1 armed=false starting=false
        if itemRule.button then itemRule.button.Text="АВТО-ЗЕЛЬЯ: ВЫКЛ" itemRule.button.BackgroundColor3=ac end
    end
    itemRule.stop=stop
    function itemRule.setTiers(tiers)
        for i,button in ipairs(tierButtons) do
            itemRule.tiers[i]=type(tiers)=="table" and tiers[i]==true
            button.BackgroundColor3=itemRule.tiers[i] and ac or cd
        end
    end
    for i=1,3 do
        local b=bt(p9,"🧪\n"..i.." ТИР",u(1/3,-8,0,55),u((i-1)/3,4,0,23),cd,8,1)
        b.TextSize=14 b.TextWrapped=true tierButtons[i]=b
        b.Activated:Connect(function()
            if armed or starting then stop() end
            itemRule.tiers[i]=not itemRule.tiers[i]
            b.BackgroundColor3=itemRule.tiers[i] and ac or cd
        end)
    end
    itemRule.setTiers({true,false,false})
    lb(p9,"Интервал (мин):",u(0.52,0,0,25),u(0,4,0,85),sb,17)
    itemRule.interval=bx(p9,"15",u(0.42,-4,0,25),u(0.58,0,0,85))
    lb(p9,"Порог круток:",u(0.52,0,0,25),u(0,4,0,116),sb,17)
    itemRule.threshold=bx(p9,"100",u(0.42,-4,0,25),u(0.58,0,0,116))
    local mode=bt(p9,"РЕЖИМ: ТАЙМЕР",u(1,-8,0,28),u(0,4,0,148),cd,6,1)
    function itemRule.setMode(value)
        itemRule.mode=value=="rolls" and "rolls" or "timer"
        mode.Text=itemRule.mode=="timer" and "РЕЖИМ: ТАЙМЕР" or "РЕЖИМ: ПО КРУТКАМ"
    end
    mode.Activated:Connect(function() if armed or starting then stop() end itemRule.setMode(itemRule.mode=="timer" and "rolls" or "timer") end)
    info=lb(p9,"По три зелья каждого выбранного тира.",u(1,-8,0,36),u(0,4,0,182),sb,17) info.TextWrapped=true
    itemRule.button=bt(p9,"АВТО-ЗЕЛЬЯ: ВЫКЛ",u(1,-8,0,36),u(0,4,1,-40),ac,8)
    local function useTiers(current,tiers)
        local inventory=Rem:FindFirstChild("Inventory")
        if not inventory then info.Text="Ошибка: Inventory не найден." return end
        local successes,attempts=0,0
        for tier=1,3 do
            if tiers[tier] then
                for _,kind in ipairs({"luck","speed","money"}) do
                    if current~=generation or not g.Parent then return end
                    attempts+=1
                    local ok,result=pcall(function() return inventory:InvokeServer("use","potion_"..kind.."_"..tier) end)
                    if ok and type(result)=="number" and result>0 then successes+=1 end
                    task.wait(0.5)
                end
            end
        end
        if current==generation then info.Text="Использовано зелий: "..successes.." из "..attempts.."." end
    end
    local connection=Rem:WaitForChild("StateChanged").OnClientEvent:Connect(function(state)
        if type(state)~="table" or type(state.rollCount)~="number" then return end
        local count=state.rollCount
        observedCount=count observedVersion+=1
        if not armed or itemRule.mode~="rolls" then return end
        if lastCount and lastCount<target and count>=target then
            local current,tiers=generation,table.clone(itemRule.tiers)
            armed=false itemRule.button.Text="АВТО-ЗЕЛЬЯ: ВЫКЛ" itemRule.button.BackgroundColor3=ac
            task.spawn(useTiers,current,tiers)
        end
        lastCount=count
    end)
    g.Destroying:Connect(function() stop() connection:Disconnect() end)
    itemRule.button.Activated:Connect(function()
        if armed or starting then stop() info.Text="Авто-зелья остановлены." return end
        if not (itemRule.tiers[1] or itemRule.tiers[2] or itemRule.tiers[3]) then info.Text="Выбери хотя бы один тир." return end
        local interval=tonumber(itemRule.interval.Text)
        if itemRule.mode=="timer" then
            if not interval or interval<1 or interval>1440 then info.Text="Укажи интервал от 1 до 1440 минут." return end
            generation+=1 local current=generation
            armed=true itemRule.button.Text="АВТО-ЗЕЛЬЯ: ВКЛ" itemRule.button.BackgroundColor3=danger
            task.spawn(function()
                while armed and current==generation and g.Parent do
                    useTiers(current,itemRule.tiers)
                    local untilTime=os.clock()+interval*60
                    while armed and current==generation and g.Parent and os.clock()<untilTime do task.wait(math.min(5,math.max(0.1,untilTime-os.clock()))) end
                end
            end)
        else
            local n=tonumber(itemRule.threshold.Text)
            if not n or n<1 or n%1~=0 then info.Text="Укажи целое число круток." return end
            local remote=Rem:FindFirstChild("GetState")
            local ok,state=false,nil
            generation+=1 local current=generation starting=true
            info.Text="Получаю счётчик круток..."
            local beforeRequest=observedVersion
            if remote then ok,state=pcall(function() return remote:InvokeServer() end) end
            if current~=generation or not g.Parent then return end
            starting=false
            if not ok or type(state)~="table" or type(state.rollCount)~="number" then info.Text="Не удалось получить счётчик." return end
            if observedVersion~=beforeRequest and observedCount then state.rollCount=observedCount end
            if state.rollCount>=n then info.Text="Порог уже достигнут. Укажи число выше "..state.rollCount.."." return end
            target,lastCount=n,state.rollCount armed=true
            itemRule.button.Text="АВТО-ЗЕЛЬЯ: ВКЛ" itemRule.button.BackgroundColor3=danger
            info.Text="Ожидаю "..n.." круток. Сейчас: "..lastCount.."."
        end
    end)
end

do
    (function()
    local width=configNumber(savedConfig.width,435,435,1600)
    local height=configNumber(savedConfig.height,320,320,1000)
    m.Size=u(0,width,0,height)
    m.Position=u(0.5,-math.floor(width/2),0.3,0)

    local function applyTabFields(config)
        itemRule.stop()
        local oldTier=math.clamp(math.floor(tonumber(config.potionTier) or (type(config.itemIds)=="string" and tonumber(config.itemIds:match("potion_%a+_(%d)"))) or 1),1,3)
        itemRule.setTiers(type(config.potionTiers)=="table" and config.potionTiers or {oldTier==1,oldTier==2,oldTier==3})
        itemRule.setMode(config.potionMode)
        itemRule.interval.Text=tostring(configNumber(tonumber(config.potionInterval),15,1,1440))
        itemRule.threshold.Text=type(config.itemThreshold)=="string" and config.itemThreshold or "100"
        if type(config.afkOn)=="boolean" then afkOn=config.afkOn afkB.Text=afkOn and "ON" or "OFF" afkB.BackgroundColor3=afkOn and ac or bg end
        local market=type(config.market)=="table" and config.market or {}
        lBox.Text=tostring(math.floor(configNumber(market.limit,0,0,1e9)))
        dBox.Text=tostring(configNumber(market.delay,1.5,1.4,3600))
        curSort=sorts[2]
        for _,sort in ipairs(sorts) do
            if sort.id==market.sort then curSort=sort break end
        end
        sB.Text=curSort.n
        for i,sort in ipairs(sorts) do
            sBtns[i].BackgroundColor3=sort.id==curSort.id and ac or cd
        end
        local byRarity=type(market.rarities)=="table" and market.rarities or {}
        for _,rarity in ipairs(rars) do
            local rule=byRarity[rarity.id]
            local defaultPrice=tonumber(rarity.def)
            local price=defaultPrice
            rarity.on=false
            if type(rule)=="table" then
                price=math.floor(configNumber(rule.price,defaultPrice,0,1e15))
                rarity.on=rule.enabled==true
            end
            rarity.box.Text=tostring(price)
            rarity.toggle.Text=rarity.on and "ON" or "OFF"
            rarity.toggle.BackgroundColor3=rarity.on and ac or bg
        end
        bl={}
        applyStallLevels(config.stallLevels)
        sumBox.Text=tostring(math.floor(configNumber(config.mailAmount,0,0,1e15)))
    end

    applyTabFields(savedConfig)

    local lastSavedData=nil
    saveConfig=function(recipientOnly)
        if type(writefile)~="function" then return false end
        local entry=recipientOnly and readConfig()
        if entry then
            entry.recipient=recipientBook.primary
            entry.recipients=table.clone(recipientBook.names)
        else
            entry={
                version=1, recipient=recipientBook.primary, recipients=table.clone(recipientBook.names),
                modern=modernTheme, menuKey=menuKey.Name, afkKey=extra.afkKey.Name,
                width=math.clamp(m.Size.X.Offset,435,1600), height=math.clamp(m.Size.Y.Offset,320,1000),
                mailDelay=configNumber(tonumber(mailDelayBox.Text),4,2,3600),
                stallDelay=configNumber(tonumber(stallDelayBox.Text),2,1,3600),
                optimization=table.clone(optCfg),
                traderFilters={true,true,false},
                traderReserve=configNumber(savedConfig.traderReserve,0,0,1e15),
                potionTiers=table.clone(itemRule.tiers), potionMode=itemRule.mode, potionInterval=itemRule.interval.Text, itemThreshold=itemRule.threshold.Text,
                afkOn=afkOn,
                mailAmount=configNumber(parseM(sumBox.Text),0,0,1e15),
                stallLevels=table.clone(stallLevels),
                market={
                    sort=curSort.id, limit=configNumber(tonumber((lBox.Text:gsub("%D",""))),0,0,1e9),
                    delay=configNumber(tonumber(dBox.Text),1.5,1.4,3600), rarities={},
                },
            }
            for _,rarity in ipairs(rars) do
                entry.market.rarities[rarity.id]={enabled=rarity.on,price=configNumber(parseM(rarity.box.Text),0,0,1e15)}
            end
            if type(savedConfig.traderFilters)=="table" then
                for i=1,2 do entry.traderFilters[i]=savedConfig.traderFilters[i]~=false end
                entry.traderFilters[3]=savedConfig.traderFilters[3]==true
            end
        end
        if type(makefolder)=="function" then pcall(makefolder,"GGT") end
        local ok,encoded=pcall(function() return Http:JSONEncode(entry) end)
        if not ok then return false end
        if encoded==lastSavedData then return true end
        local saved=pcall(function() writefile(configPath,encoded) end)
        if saved then lastSavedData=encoded end
        return saved
    end

    local configOverlay=ui("Frame",{
        Size=u(1,0,1,0),BackgroundColor3=bg,BackgroundTransparency=0.2,
        Visible=false,Active=true,ZIndex=20,
    },m,10)
    hideSettingsActionsBehind(configOverlay)
    local card=ui("Frame",{
        Size=u(0.8,0,0,240),Position=u(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=sd,ZIndex=21,
    },configOverlay,10,1)
    Instance.new("UISizeConstraint",card).MaxSize=Vector2.new(360,240)
    local heading=lb(card,"Конфиги",u(1,-66,0,27),u(0,14,0,9),tx,18)
    heading.TextSize,heading.ZIndex=15,22
    local close=bt(card,"×",u(0,32,0,28),u(1,-42,0,9),cd,6,1)
    local save=bt(card,"Сохранить",u(0.5,-16,0,38),u(0,12,0,53),ac,8)
    local apply=bt(card,"Применить",u(0.5,-16,0,38),u(0.5,4,0,53),cd,8,1)
    close.ZIndex,save.ZIndex,apply.ZIndex=22,22,22
    local status=lb(card,"",u(1,-24,0,42),u(0,12,0,106),sb,17)
    status.TextWrapped,status.ZIndex=true,22
    local nameBox=bx(card,"",u(0.62,-16,0,28),u(0,12,0,152))
    nameBox.PlaceholderText="Имя нового конфига"
    local createProfile=bt(card,"Создать",u(0.38,-8,0,28),u(0.62,4,0,152),ac,6)
    local nextProfile=bt(card,"Выбрать конфиг ▾",u(0.62,-16,0,28),u(0,12,0,187),cd,6,1)
    local publishProfile=bt(card,"Общий ↑",u(0.38,-8,0,28),u(0.62,4,0,187),cd,6,1)
    local profileList=ui("ScrollingFrame",{Size=u(1,-24,0,120),Position=u(0,12,0,63),BackgroundColor3=cd,Visible=false,ScrollBarThickness=4,CanvasSize=u(0,0,0,0),ZIndex=25},card,6,1)
    nameBox.ZIndex,createProfile.ZIndex,nextProfile.ZIndex,publishProfile.ZIndex=22,22,22,22

    configB.Activated:Connect(function()
        status.Text="Активный: "..activeConfig.." · автосохранение"
        configOverlay.Visible=true
    end)
    close.Activated:Connect(function() configOverlay.Visible=false end)
    save.Activated:Connect(function()
        if not configReadable then status.Text="Конфиг повреждён или недоступен; запись отключена." return end
        status.Text=saveConfig() and "Текущие настройки сохранены." or "Не удалось записать файл конфига."
    end)
    local function applyCurrent(config)
        config=config or readConfig()
        if not config then
            status.Text="Не удалось прочитать сохранённый конфиг."
            return false
        end
        savedConfig=config
        configReadable=true
        setTheme(config.modern==true)
        m.Size=u(0,configNumber(config.width,435,435,1600),0,configNumber(config.height,320,320,1000))
        menuKey,waitingBind=configMenuKey(config.menuKey),false
        bindB.Text=menuKey.Name
        extra.afkKey=Enum.KeyCode.Unknown
        if type(config.afkKey)=="string" then local ok,key=pcall(function() return Enum.KeyCode[config.afkKey] end) if ok and key and key~=menuKey then extra.afkKey=key end end
        extra.waitingAfkBind=false extra.afkBindB.Text=extra.afkKey~=Enum.KeyCode.Unknown and extra.afkKey.Name or "Не задана"
        mailDelayBox.Text=tostring(configNumber(config.mailDelay,4,2,3600))
        stallDelayBox.Text=tostring(configNumber(config.stallDelay,2,1,3600))
        recipientBook.load(config)
        refreshTraderFilters()
        applyTabFields(config)
        optCfg=configOptimization(config.optimization)
        for key,button in pairs(optBtns) do
            button.Text=optCfg[key] and "ON" or "OFF"
            button.BackgroundColor3=optCfg[key] and ac or bg
        end
        fpsBox.Text=tostring(optCfg.fps)
        applyCustomOpt(table.clone(optCfg))
        status.Text="Конфиг загружен и применён."
        return true
    end
    apply.Activated:Connect(function() applyCurrent() end)
    local function profiles()
        local result={"default"}
        if type(listfiles)~="function" then return result end
        local ok,files=pcall(listfiles,"GGT")
        if not ok then return result end
        local prefix="config_"..tostring(plr.UserId).."_profile_"
        for _,file in ipairs(files) do
            local basename=file:gsub("\\","/"):match("([^/]+)$")
            if basename and basename:sub(1,#prefix)==prefix and basename:sub(-5)==".json" then
                local name=basename:sub(#prefix+1,-6)
                if validConfigName(name) and name~="default" then table.insert(result,name) end
            end
        end
        table.sort(result)
        return result
    end
    local function rememberActive()
        if type(writefile)=="function" then pcall(writefile,markerPath,activeConfig) end
    end
    createProfile.Activated:Connect(function()
        local name=nameBox.Text
        if not validConfigName(name) or name=="default" then status.Text="Имя: латинские буквы, цифры, - или _." return end
        if type(isfile)~="function" or type(writefile)~="function" then status.Text="Executor не поддерживает файлы." return end
        local newPath=configFile(name)
        local ok,exists=pcall(isfile,newPath)
        if not ok or exists then status.Text="Конфиг уже существует или недоступен." return end
        if not configReadable or not saveConfig() then status.Text="Текущий конфиг недоступен для сохранения." return end
        local oldName,oldPath=activeConfig,configPath
        activeConfig,configPath,lastSavedData=name,newPath,nil
        if not saveConfig() then activeConfig,configPath,lastSavedData=oldName,oldPath,nil status.Text="Ошибка создания конфига." return end
        rememberActive()
        status.Text="Активный: "..name.." · автосохранение"
    end)
    local function selectProfile(name,shared)
        if not configReadable or not saveConfig() then status.Text="Текущий конфиг недоступен для сохранения." return end
        local loaded=nil
        if shared then
            local ok,data=pcall(function() return Http:JSONDecode(readfile("GGT/shared_config_"..name..".json")) end)
            if not ok or type(data)~="table" or data.version~=1 then status.Text="Общий конфиг не удалось прочитать." return end
            loaded=data
            local base="shared_"..name:sub(1,20)
            local candidate,index=base,1
            if type(isfile)~="function" then status.Text="Executor не поддерживает проверку файлов." return end
            while true do
                local existsOk,exists=pcall(isfile,configFile(candidate))
                if not existsOk then status.Text="Не удалось проверить конфиги." return end
                if not exists then break end
                index+=1 candidate=base.."_"..index
                if index>999 then status.Text="Слишком много копий конфига." return end
            end
            name=candidate
            local ok,encoded=pcall(function() return Http:JSONEncode(loaded) end)
            if not ok or not pcall(writefile,configFile(name),encoded) then status.Text="Не удалось создать личную копию." return end
        end
        local oldName,oldPath=activeConfig,configPath
        activeConfig,configPath,lastSavedData=name,configFile(name),nil
        if not applyCurrent(loaded) then activeConfig,configPath,lastSavedData=oldName,oldPath,nil return end
        rememberActive()
        profileList.Visible=false
        status.Text="Активный: "..name.." · автосохранение"
    end
    publishProfile.Activated:Connect(function()
        if not configReadable or not saveConfig() then status.Text="Не удалось сохранить текущий конфиг." return end
        local ok,contents=pcall(readfile,configPath)
        if not ok or type(contents)~="string" then status.Text="Не удалось прочитать текущий конфиг." return end
        local written=pcall(writefile,"GGT/shared_config_"..activeConfig..".json",contents)
        status.Text=written and ("Общий шаблон: "..activeConfig) or "Не удалось создать общий шаблон."
    end)
    nextProfile.Activated:Connect(function()
        profileList.Visible=not profileList.Visible
        if not profileList.Visible then return end
        for _,child in ipairs(profileList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local entries={}
        for _,name in ipairs(profiles()) do table.insert(entries,{name=name,shared=false}) end
        if type(listfiles)=="function" then
            local ok,files=pcall(listfiles,"GGT")
            if ok then
                for _,file in ipairs(files) do
                    local basename=file:gsub("\\","/"):match("([^/]+)$")
                    local name=basename and basename:match("^shared_config_(.-)%.json$")
                    if validConfigName(name) then table.insert(entries,{name=name,shared=true}) end
                end
            end
        end
        table.sort(entries,function(a,b) return (a.shared and "1" or "0")..a.name < (b.shared and "1" or "0")..b.name end)
        for i,entry in ipairs(entries) do
            local b=bt(profileList,(entry.shared and "🌐 " or "👤 ")..entry.name,u(1,-8,0,27),u(0,3,0,(i-1)*30),entry.name==activeConfig and ac or bg,6)
            b.ZIndex=26
            b.Activated:Connect(function() selectProfile(entry.name,entry.shared) end)
        end
        profileList.CanvasSize=u(0,0,0,#entries*30)
    end)
    task.spawn(function()
        while g.Parent do
            task.wait(3)
            if g.Parent and configReadable and type(writefile)=="function" then saveConfig() end
        end
    end)

    end)()
end

local function formatBoxPost(item)
    local sender=tostring(item.fromName or item.senderName or item.from or "Игрок")
    local money=tonumber(item.money or item.cash or item.amount or 0) or 0
    local parts,tipLines={},{}
    table.insert(tipLines,string.format("<font color=\"#9191A5\">Отправитель:</font> <b>%s</b>",sender))
    if money>0 then
        table.insert(parts,fmtNum(money).." ₽")
        table.insert(tipLines,string.format("<font color=\"#9191A5\">Сумма:</font> <font color=\"#4ADE80\"><b>%s ₽</b></font>",fmtNum(money)))
    end
    local plates=item.plates
    if type(plates)=="table" and #plates>0 then
        table.insert(tipLines,"<font color=\"#9191A5\">Номера:</font>")
        for _,pl in ipairs(plates) do
            if type(pl)=="table" then
                local pt=tostring(pl.text or "Номер")
                local pr=tostring(pl.rarity or "")
                local itemStr=pt..(pr~="" and (" ["..pr.."]") or "")
                table.insert(parts,itemStr)
                table.insert(tipLines,fmtPlateRich(itemStr))
            elseif type(pl)=="string" then
                table.insert(parts,pl)
                table.insert(tipLines,fmtPlateRich(pl))
            end
        end
    end
    local summary=#parts>0 and table.concat(parts,", ") or "Посылка"
    return sender..": "..summary,table.concat(tipLines,"\n")
end

sumBox.FocusLost:Connect(function() local val=parseM(sumBox.Text) if val>0 then sumBox.Text=tostring(val) mSt.Text=string.format("Сумма: %s ₽",fmtNum(val)) end end)

local function sendMail()
    local clean=idBox.Text:gsub("%s+","")
    local amt=parseM(sumBox.Text)
    if amt>0 then sumBox.Text=tostring(amt) end
    local platesArr={}
    for k in pairs(selPlates) do table.insert(platesArr,k) end
    local items,totalItems={},0
    for id,count in pairs(mailItems) do
        if type(id)=="string" and type(count)=="number" and count>0 and count%1==0 then items[id]=count totalItems+=count end
    end
    if clean=="" then mSt.Text="Ошибка: впиши юзернейм." return end
    if amt<=0 and #platesArr==0 and totalItems==0 then mSt.Text="Выбери номера, предметы или впиши сумму." return end
    if totalItems>90 then mSt.Text="В посылке не больше 90 предметов." return end
    local plateNames,selectionError = checkMailPlates(platesArr)
    if not plateNames then mSt.Text=selectionError return end
    mSt.Text="Ищу игрока..."

    local okLook,lookRes=pcall(function() return PS:InvokeServer("look",clean) end)
    if not okLook then mSt.Text="Ошибка вызова look" return end
    if type(lookRes)=="table" and lookRes.ok==false then mSt.Text="Ошибка: "..tostring(lookRes.err or "игрок не найден") return end

    local uid=0
    if type(lookRes)=="table" then
        local uData=lookRes.user or lookRes.player or lookRes.data or lookRes
        if type(uData)=="table" then
            uid=tonumber(uData.toId) or tonumber(uData.userId) or tonumber(uData.id) or tonumber(uData.uid) or 0
        end
    end
    if uid<=0 then local okId,apiId=pcall(function() return P:GetUserIdFromNameAsync(clean) end) if okId and apiId then uid=apiId end end
    if uid<=0 then mSt.Text="Ошибка: не удалось получить ID игрока." return end

    task.wait(0.2)
    if not g.Parent then return end
    plateNames,selectionError = checkMailPlates(platesArr)
    if not plateNames then mSt.Text=selectionError return end
    if totalItems>0 then
        local valid,reason=extra.validateMailItems(items)
        if not g.Parent then return end
        if not valid then mSt.Text=reason return end
    end
    extra.lastMailSent=os.clock()
    local ok,res=pcall(function() return PS:InvokeServer("send",uid,platesArr,items,amt) end)
    if not g.Parent then return end
    if not ok or type(res)~="table" or not res.ok then
        mSt.Text = ok and type(res)=="table" and res.err and ("Отказ: "..tostring(res.err)) or "Отправка не подтверждена. Проверь исходящие."
        if extra.reportGameError then extra.reportGameError("Почта",mSt.Text) end
        return
    end

    for _,id in ipairs(platesArr) do
        sentPlates[id]=true
        selPlates[id]=nil
    end
    table.clear(mailItems) extra.itemPickB.Text="Предм.: 0"
    mSt.Text="Отправлено -> "..clean
    local pStr=#plateNames>0 and table.concat(plateNames,", ") or "без номеров"
    local shortLine=string.format("Отправлено (%s): %s / %s ₽",clean,pStr,fmtNum(amt))
    local tLines={
        string.format("<font color=\"#9191A5\">Получатель:</font> <b>%s</b>",clean),
        string.format("<font color=\"#9191A5\">Сумма:</font> <font color=\"#4ADE80\"><b>%s ₽</b></font>",fmtNum(amt))
    }
    if totalItems>0 then table.insert(tLines,"<font color=\"#9191A5\">Предметов:</font> "..totalItems) end
    if #plateNames>0 then
        table.insert(tLines,"<font color=\"#9191A5\">Номера:</font>")
        for _,pn in ipairs(plateNames) do table.insert(tLines,fmtPlateRich(pn)) end
    end
    addMailLog(shortLine,table.concat(tLines,"\n"))
    updPickTxt()
end

local sendInProgress = false
mSendB.Activated:Connect(function()
    if sendInProgress then return end
    sendInProgress = true
    mSendB.Text = "ОТПРАВЛЯЮ…"
    local ok = pcall(sendMail)
    sendInProgress = false
    if not g.Parent then return end
    mSendB.Text = "ОТПРАВИТЬ"
    if not ok then mSt.Text = "Ошибка отправки. Проверь исходящие." end
end)

do
    local pendingResult=nil
    local function responseStatus(response)
        return type(response)=="table" and (response.StatusCode or response.Status)
    end
    local function executeBatch(batch)
        if type(batch)~="table" or type(batch.id)~="string" or type(batch.recipient)~="string"
            or configNickname(batch.recipient)=="" or type(batch.plates)~="table" or #batch.plates<1 or #batch.plates>30 then
            return "failed","Некорректное задание"
        end
        local ok,plates,verified=pcall(scanMyPlates)
        if not ok or not verified then return "failed","Не удалось проверить инвентарь" end
        local available={}
        for _,plate in ipairs(plates) do available[plate.id]=true end
        local chosen,seen={},{}
        for _,uid in ipairs(batch.plates) do
            if type(uid)~="string" or not available[uid] or seen[uid] then return "failed","Номера изменились; требуется новая проверка" end
            seen[uid]=true chosen[#chosen+1]=uid
        end
        if not g.Parent then return "failed","Клиент закрыт до отправки" end
        local lookupOk,look=pcall(function() return PS:InvokeServer("look",batch.recipient) end)
        if not lookupOk or type(look)~="table" or not look.ok or not tonumber(look.toId) then
            return "failed",type(look)=="table" and tostring(look.err or "Получатель не найден") or "Не удалось найти получателя"
        end
        if not g.Parent then return "failed","Клиент закрыт до отправки" end
        local scanOk,fresh,stillVerified=pcall(scanMyPlates)
        if not scanOk or not stillVerified then return "failed","Не удалось повторно проверить инвентарь" end
        local stillAvailable={}
        for _,plate in ipairs(fresh) do stillAvailable[plate.id]=true end
        for _,uid in ipairs(chosen) do if not stillAvailable[uid] then return "failed","Номера изменились перед отправкой" end end
        if not g.Parent then return "failed","Клиент закрыт до отправки" end
        local permission=extra.mailRequest("POST","/api/mail/begin",{batch_id=batch.id})
        if responseStatus(permission)~=200 then
            if responseStatus(permission)==409 then return "failed","Задание отменено до отправки" end
            return "unknown","Связь прервалась до подтверждения отправки"
        end
        if not g.Parent then return "failed","Клиент закрыт до отправки" end
        extra.lastMailSent=os.clock()
        local sent,result=pcall(function() return PS:InvokeServer("send",tonumber(look.toId),chosen,{},0) end)
        if not sent or type(result)~="table" then return "unknown","Нет подтверждения; проверь исходящие" end
        if not result.ok then return "failed",tostring(result.err or "Игра отклонила отправку") end
        for _,uid in ipairs(chosen) do sentPlates[uid]=true selPlates[uid]=nil end
        updPickTxt()
        return "sent",""
    end
    task.spawn(function()
        while g.Parent do
            if pendingResult then
                local response=extra.mailRequest("POST","/api/mail/result",pendingResult)
                if responseStatus(response)==200 then pendingResult=nil end
            elseif not sendInProgress and (not extra.lastMailSent or os.clock()-extra.lastMailSent>=6) then
                sendInProgress=true
                local response=extra.mailRequest("GET","/api/mail/next")
                local ok,parsed=pcall(function() return Http:JSONDecode(response.Body) end)
                local batch=ok and type(parsed)=="table" and parsed.batch
                if responseStatus(response)==200 and type(batch)=="table" then
                    local callOk,status,err=pcall(executeBatch,batch)
                    if not callOk then status,err="unknown","Ошибка выполнения; проверь исходящие" end
                    pendingResult={batch_id=batch.id,status=status,error=tostring(err or ""):sub(1,300),session_id=extra.statsSession,sequence=extra.statsSequence}
                end
                sendInProgress=false
            end
            task.wait(10)
        end
    end)
end

extra.takeSession=0
mTakeB.MouseButton1Click:Connect(function()
    takeRun=not takeRun
    extra.takeSession+=1
    local session=extra.takeSession
    mTakeB.BackgroundColor3=takeRun and danger or cd
    mTakeB.Text=takeRun and "АВТО-ПРИЁМ: ВКЛ" or "АВТО-ПРИЁМ: ВЫКЛ"
    if not takeRun then mSt.Text="Авто-приём остановлен." return end
    mSt.Text="Авто-приём включен."
    task.spawn(function()
        local function scanBoxTable(tbl,visited)
            if not takeRun or session~=extra.takeSession or not g.Parent or type(tbl)~="table" or visited[tbl] then return end
            visited[tbl]=true
            local pid=rawget(tbl,"id")
            if type(pid)=="string" and pid:sub(1,5)=="post_" then
                if not rawget(tbl,"claimed") and not rawget(tbl,"taken") and not rawget(tbl,"claimedAt") and not takenPosts[pid] then
                    local okTake,takeRes=pcall(function() return PS:InvokeServer("take",{pid}) end)
                    if okTake and type(takeRes)=="table" and takeRes.ok then
                        takenPosts[pid]=true
                        if g.Parent then
                            local infoLine,fullTip=formatBoxPost(tbl)
                            mSt.Text="Принята новая посылка"
                            addMailLog(infoLine,fullTip)
                        end
                    end
                    task.wait(0.4)
                end
            end
            for _,v in pairs(tbl) do if type(v)=="table" then scanBoxTable(v,visited) end end
        end

        while takeRun and session==extra.takeSession and g.Parent do
            local okBox,boxRes=pcall(function() return PS:InvokeServer("box") end)
            if takeRun and session==extra.takeSession and g.Parent and okBox and type(boxRes)=="table" then scanBoxTable(boxRes,{}) end
            task.wait(math.max(2,tonumber(mailDelayBox.Text) or 4))
        end
    end)
end)
local allPotions={
    "potion_luck_1","potion_speed_1","potion_money_1",
    "potion_luck_2","potion_speed_2","potion_money_2",
    "potion_luck_3","potion_speed_3","potion_money_3",
    "potion_luck_4","potion_speed_4","potion_money_4"
}

local function getStallState()
    local sp=plr.PlayerGui:FindFirstChild("PlatesUI") and plr.PlayerGui.PlatesUI:FindFirstChild("StallPanel")
    if not sp then return false end
    for _,v in ipairs(sp:GetDescendants()) do
        if v:IsA("TextButton") and v.Text:find("₽") then return true end
    end
    return false
end

extra.stallSession=0
local function buyAllStall(session)
    local bought=0
    for _,pid in ipairs(allPotions) do
        local level=tonumber(pid:match("_(%d+)$"))
        if not stRun or session~=extra.stallSession or not g.Parent then break end
        if level and stallLevels[level] then
            for _=1,10 do
                if not stRun or session~=extra.stallSession or not g.Parent or not stallLevels[level] then break end
                local ok,res=pcall(function() return ST:InvokeServer("buy",pid) end)
                if ok and type(res)=="table" and res.ok then
                    bought=bought+1
                    stInfo.Text="Покупка ассортимента...\nКуплено за заход: "..bought.." шт."
                    task.wait(0.18)
                else break end
            end
        end
    end
    return bought
end

local totalStallBought=0
task.spawn(function()
    while g.Parent do
        if not stRun then
            stInfo.Text="Статус: ВЫКЛ"
        else
            local session=extra.stallSession
            local hasStock=getStallState()
            if hasStock then
                stInfo.Text="Вижу товар в ларьке. Скупаю..."
                local cnt=buyAllStall(session)
                totalStallBought=totalStallBought+cnt
            else
                stInfo.Text=string.format("Статус: ВКЛ (Всё раскуплено)\nВсего куплено: %d шт.",totalStallBought)
            end
        end
        task.wait(math.max(1,tonumber(stallDelayBox.Text) or 2))
    end
end)

stAutoB.MouseButton1Click:Connect(function()
    stRun=not stRun
    extra.stallSession+=1
    stAutoB.BackgroundColor3=stRun and danger or ac
    stAutoB.Text=stRun and "АВТО-ЛАРЁК: ВКЛ" or "АВТО-ЛАРЁК: ВЫКЛ"
end)

local function stop(msg) run=false tB.BackgroundColor3,tB.Text=ac,"СНАЙПЕР: ВЫКЛ" st.Text=msg.."\nУспешных покупок: "..okC if extra.reportGameError and msg:find("Ошибка",1,true) then extra.reportGameError("Снайпер",msg) end end
local function wN() local gp=math.max(1.4,tonumber(dBox.Text) or 1.5) local df=os.clock()-lN if df<gp then task.wait(gp-df) end lN=os.clock() end
local function getP(t) if type(t)~="table" then return 0 end local d=t.lot or t return tonumber(d.p) or tonumber(d.ask) or tonumber(d.start) or tonumber(d.price) or 0 end
local function freshP(id,session) wN() if not run or session~=sniperSession then return 0 end local ok,inf=pcall(function() return ML:InvokeServer(id) end) return ok and getP(inf) or 0 end

local function getRarMax(rarId)
    local r=rarMap[rarId]
    if not (r and r.on) then return 0 end
    return parseM(r.box.Text)
end

local function hold(lot,maxP,lim,session)
    local act,fixed=getP(lot),false
    if act<=0 or act>maxP then bl[lot.id]=true return false end
    for att=1,40 do
        if not run or session~=sniperSession or (lim>0 and okC>=lim) then return true end
        wN()
        if not run or session~=sniperSession then return true end
        local ok,res=pcall(function() return MB:InvokeServer(lot.id,act) end)
        if session~=sniperSession then return true end
        if ok and type(res)=="table" then
            if res.ok then
                local rarity = tostring(lot.rarity)
                afkPurchases.count += 1
                afkPurchases.spent += act
                afkPurchases.byRarity[rarity] = (afkPurchases.byRarity[rarity] or 0) + 1
                afkPurchases.last = tostring(lot.text).." ("..fmtNum(act).." ₽)"
                okC=okC+1
                bl[lot.id]=true
                st.Text="Куплен ["..rarity.."]: "..tostring(lot.text).." ("..act.." ₽)\nУспешных: "..okC
                if lim>0 and okC>=lim then stop("Готово.") end
                return true
            end
            local err=tostring(res.err or "ожидание") local le=err:lower()
            if le:find("изменилась") then
                if fixed then bl[lot.id]=true return false end
                fixed=true
                local np=getP(res) if np<=0 then np=freshP(lot.id,session) end
                if not run or session~=sniperSession then return true end
                if np>0 and np<=maxP then act=np st.Text="Новая цена: "..act.." ₽" else bl[lot.id]=true st.Text="Пропуск: "..np.." ₽ > лимита" return false end
            elseif le:find("денег") or le:find("средств") or le:find("баланс") or le:find("мест") or le:find("слот") then stop("Ошибка: "..err) return true
            elseif le:find("закрыт") or le:find("продан") or le:find("купили") or le:find("нет такого") or le:find("найден") then bl[lot.id]=true st.Text="Пропуск: "..err return false
            else st.Text="Ожидание: "..tostring(lot.text).." ("..act.." ₽) ["..att.."]\n"..err if le:find("быстро") then task.wait(1) end end
        end
    end
    bl[lot.id]=true return false
end

local function step(session)
    local lim=tonumber((lBox.Text:gsub("%D",""))) or 0
    if lim>0 and okC>=lim then stop("Лимит достигнут.") return end
    local actR={} for _,r in ipairs(rars) do if r.on and getRarMax(r.id)>0 then table.insert(actR,r.id) end end
    if #actR==0 then st.Text="Ошибка: включи редкость и укажи цену > 0." task.wait(0.25) return end
    wN()
    if not run or session~=sniperSession then return end
    local ok,res=pcall(function() return GM:InvokeServer({q="",kind="fix",sort=curSort.id,rar=actR}) end)
    if not run or session~=sniperSession then return end
    if ok and type(res)=="table" and type(res.items)=="table" then
        local now=tonumber(res.now) or os.time()
        for _,lot in ipairs(res.items) do
            if not run or session~=sniperSession or (lim>0 and okC>=lim) then break end
            local p=getP(lot)
            local rMax=getRarMax(lot.rarity)
            if lot.fix and rMax>0 and (tonumber(lot.expiresAt) or now+100)>now and lot.seller~=plr.UserId and p>0 and p<=rMax and not bl[lot.id] then
                if hold(lot,rMax,lim,session) then return end
            end
        end
        if run then st.Text="Поиск ("..curSort.n..") по "..#actR.." редкостям...\nУспешных покупок: "..okC end
    end
end

tB.MouseButton1Click:Connect(function()
    run=not run
    sniperSession=sniperSession+1
    local session=sniperSession
    if run then tB.BackgroundColor3,tB.Text=danger,"СТОП" bl,okC={},0 task.spawn(function() while run and sniperSession==session do step(session) end end)
    else stop("Остановлено") end
end)
