local U,R,C,P,VU,L,RS=game:GetService("UserInputService"),game:GetService("ReplicatedStorage"),game:GetService("CoreGui"),game:GetService("Players"),game:GetService("VirtualUser"),game:GetService("Lighting"),game:GetService("RunService")
local plr=P.LocalPlayer
local Rem=R:WaitForChild("Remotes")
local GM,ML,MB,TR,PS,ST=Rem.GetMarket,Rem.MarketLot,Rem.MarketBuy,Rem.Trader,Rem.Post,Rem.Stall
if C:FindFirstChild("ZS") then C.ZS:Destroy() end

local g=Instance.new("ScreenGui",C) g.Name,g.ResetOnSpawn,g.IgnoreGuiInset="ZS",false,true
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
local dc=ui("Frame",{Size=u(0,210,0,95),Position=u(0.5,-105,0.5,-47),BackgroundColor3=sd,ZIndex=11},dlg,8,1)
ui("TextLabel",{Size=u(1,-10,0,38),Position=u(0,5,0,6),BackgroundTransparency=1,Text="Закрыть меню?",TextColor3=tx,Font=18,TextSize=12,ZIndex=12},dc)
local yB=bt(dc,"Да",u(0.45,0,0,28),u(0,10,1,-36),c(200,55,65)) yB.ZIndex=12
local nB=bt(dc,"Нет",u(0.45,0,0,28),u(0.55,-10,1,-36),cd) nB.ZIndex=12

local sdF=ui("Frame",{Size=u(0,98,1,-34),Position=u(0,0,0,34),BackgroundColor3=sd,BorderSizePixel=0},m)
local p1=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1},m)
local p4=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p5=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p6=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local p7=ui("Frame",{Size=u(1,-112,1,-44),Position=u(0,105,0,39),BackgroundTransparency=1,Visible=false},m)
local pgs,tbs={p1,p4,p6,p5,p7},{}
for i,nm in ipairs({"Снайпер","Торгаш","Ларёк","Почта","Настройки"}) do
    local tb=bt(sdF,nm,u(1,-12,0,28),u(0,6,0,8+(i-1)*34),i==1 and ac or cd,7)
    tbs[i]=tb tb.MouseButton1Click:Connect(function() for j=1,5 do pgs[j].Visible=j==i tbs[j].BackgroundColor3=j==i and ac or cd end end)
end

local prof=ui("Frame",{Size=u(1,-12,0,40),Position=u(0,6,1,-46),BackgroundColor3=cd},sdF,7,1)
local av=ui("ImageLabel",{Size=u(0,26,0,26),Position=u(0,5,0,7),BackgroundColor3=bg,Image="rbxthumb://type=AvatarHeadShot&id="..tostring(plr.UserId).."&w=100&h=100"},prof,13)
local avS=Instance.new("UIStroke",av) avS.Color,avS.Thickness=ac,1
local dLbl=lb(prof,plr.DisplayName,u(1,-37,0,15),u(0,34,0,5),tx,18) dLbl.TextSize,dLbl.TextTruncate=10,Enum.TextTruncate.AtEnd
local uLbl=lb(prof,"@"..plr.Name,u(1,-37,0,13),u(0,34,0,20),sb,17) uLbl.TextSize,uLbl.TextTruncate=9,Enum.TextTruncate.AtEnd
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
    sw.MouseButton1Click:Connect(function() r.on=not r.on sw.BackgroundColor3=r.on and ac or bg sw.Text=r.on and "ON" or "OFF" end)
end

local stC=ui("Frame",{Size=u(1,0,0,44),Position=u(0,0,0,192),BackgroundColor3=cd},p1,8,1)
local st=lb(stC,"Ожидание | Успешных покупок: 0",u(1,-14,1,-8),u(0,8,0,4),tx,17) st.TextWrapped,st.TextYAlignment=true,0
local tB=bt(p1,"СНАЙПЕР: ВЫКЛ",u(1,0,0,36),u(0,0,1,-36),ac,8)
local trCard=ui("Frame",{Size=u(1,0,0,228),BackgroundColor3=cd},p4,8,1)
lb(trCard,"Покупать слоты торгаша:",u(1,-16,0,22),u(0,8,0,4),sb,17)
local traderEnabled={true,true,true,true}
for i=1,4 do
    local button=bt(trCard,tostring(i)..": ON",u(0.25,-6,0,28),u((i-1)*0.25,4,0,28),ac,6)
    button.MouseButton1Click:Connect(function()
        traderEnabled[i]=not traderEnabled[i]
        button.Text=tostring(i)..(traderEnabled[i] and ": ON" or ": OFF")
        button.BackgroundColor3=traderEnabled[i] and ac or bg
    end)
end
local trSt=lb(trCard,"Статус: ВЫКЛ",u(1,-16,0,38),u(0,8,0,184),tx,17) trSt.TextWrapped,trSt.TextYAlignment=true,0
local trB=bt(p4,"АВТО-ТОРГАШ: ВЫКЛ",u(1,0,0,40),u(0,0,1,-40),ac,8)

do
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
    }

    lb(trCard,"Фильтр ассортимента",u(1,-16,0,19),u(0,8,0,63),tx,18)
    for index,filter in ipairs(filters) do
        filter.enabled = true
        local y = 84+(index-1)*27
        lb(trCard,filter.name,u(1,-104,0,23),u(0,8,0,y),sb)
        filter.status = lb(trCard,"—",u(0,48,0,23),u(1,-101,0,y),sb,17,Enum.TextXAlignment.Right)
        local toggle = bt(trCard,"ON",u(0,40,0,23),u(1,-48,0,y),ac,6,1)
        toggle.Activated:Connect(function()
            filter.enabled = not filter.enabled
            toggle.Text = filter.enabled and "ON" or "OFF"
            toggle.BackgroundColor3 = filter.enabled and ac or bg
        end)
    end
    local hint = lb(trCard,"Открой окно торговца, чтобы увидеть совпадения.",u(1,-16,0,32),u(0,8,0,145),sb,17)
    hint.TextWrapped = true

    local function readAssortment()
        local pg = plr:FindFirstChild("PlayerGui")
        local plates = pg and pg:FindFirstChild("PlatesUI")
        local panel = plates and plates:FindFirstChild("TraderPanel")
        if not panel or not panel.Visible then return end

        local matches = {}
        for _,label in ipairs(panel:GetDescendants()) do
            if not label:IsA("TextLabel") or not label.Visible then continue end
            local parent = label.Parent
            while parent ~= panel and (not parent:IsA("GuiObject") or parent.Visible) do
                parent = parent.Parent
            end
            if parent ~= panel then continue end
            local name = normalizeItemName(label.Text)
            for index,filter in ipairs(filters) do
                if filter.enabled and filter.matches(name) then matches[index] = true end
            end
        end
        return matches
    end

    task.spawn(function()
        while g.Parent do
            if m.Visible and p4.Visible then
                local matches = readAssortment()
                hint.Text = matches and "Совпадения в открытом ассортименте."
                    or "Открой окно торговца, чтобы увидеть совпадения."
                for index,filter in ipairs(filters) do
                    local found = matches and matches[index]
                    filter.status.Text = filter.enabled and matches and (found and "Найден" or "Нет") or "—"
                    filter.status.TextColor3 = found and c(74,222,128) or sb
                end
            end
            task.wait(0.35)
        end
    end)
end

local mC1=ui("Frame",{Size=u(1,0,0,50),BackgroundColor3=cd},p5,8,1)
lb(mC1,"Юзернейм в Roblox:",u(1,-14,0,15),u(0,8,0,3),sb,17)
local idBox=bx(mC1,"",u(1,-16,0,24),u(0,8,0,20)) idBox.PlaceholderText="Введи юзернейм..."

local mC2=ui("Frame",{Size=u(1,0,0,50),Position=u(0,0,0,56),BackgroundColor3=cd},p5,8,1)
lb(mC2,"Сумма (₽) и номера:",u(1,-14,0,15),u(0,8,0,3),sb,17)
local sumBox=bx(mC2,"0",u(0.48,0,0,24),u(0,8,0,20))
local pickB=bt(mC2,"Номера: 0",u(0.46,0,0,24),u(0.52,-4,0,20),bg,6,1)

local mStC=ui("Frame",{Size=u(1,0,0,115),Position=u(0,0,0,112),BackgroundColor3=cd},p5,8,1)
local mSt=lb(mStC,"Впиши сумму или выбери номера, затем нажми Отправить.",u(1,-16,0,22),u(0,8,0,4),sb,17) mSt.TextWrapped=true
local mLogScroll=ui("ScrollingFrame",{Size=u(1,-12,1,-30),Position=u(0,6,0,26),BackgroundTransparency=1,ScrollBarThickness=3,CanvasSize=u(0,0,0,0)},mStC)
local mSendB=bt(p5,"ОТПРАВИТЬ",u(0.48,0,0,38),u(0,0,1,-38),ac,8)
local mTakeB=bt(p5,"АВТО-ПРИЁМ: ВЫКЛ",u(0.49,0,0,38),u(0.51,0,1,-38),cd,8,1)

local stCard=ui("Frame",{Size=u(1,0,0,185),BackgroundColor3=cd},p6,8,1)
lb(stCard,"Уровни зелий для покупки:",u(1,-16,0,22),u(0,8,0,4),sb,17)
local stallLevels={true,true,true,true}
for i=1,4 do
    local button=bt(stCard,tostring(i)..": ON",u(0.25,-6,0,28),u((i-1)*0.25,4,0,28),ac,6)
    button.MouseButton1Click:Connect(function()
        stallLevels[i]=not stallLevels[i]
        button.Text=tostring(i)..(stallLevels[i] and ": ON" or ": OFF")
        button.BackgroundColor3=stallLevels[i] and ac or bg
    end)
end
local stInfo=lb(stCard,"Статус: ВЫКЛ",u(1,-16,1,-70),u(0,8,0,64),tx,17) stInfo.TextWrapped,stInfo.TextYAlignment=true,0
local stAutoB=bt(p6,"АВТО-ЛАРЁК: ВЫКЛ",u(1,0,0,40),u(0,0,1,-40),ac,8)
local setR1=ui("Frame",{Size=u(1,0,0,36),BackgroundColor3=cd},p7,8,1)
lb(setR1,"Клавиша меню:",u(0.55,0,1,0),u(0,10,0,0),sb)
local bindB=bt(setR1,"RightControl",u(0.42,-8,0,24),u(0.58,0,0,7),bg,6,1)

local setR2=ui("Frame",{Size=u(1,0,0,36),Position=u(0,0,0,40),BackgroundColor3=cd},p7,8,1)
lb(setR2,"Анти-АФК (защита от кика):",u(0.7,0,1,0),u(0,10,0,0),sb)
local afkOn=true
local afkB=bt(setR2,"ON",u(0,46,0,24),u(1,-54,0,7),ac,6,1)

local setR3=ui("Frame",{Size=u(1,0,0,36),Position=u(0,0,0,80),BackgroundColor3=cd},p7,8,1)
lb(setR3,"Пауза проверки почты (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
local mailDelayBox=bx(setR3,"4",u(0,46,0,24),u(1,-54,0,7))

local setR4=ui("Frame",{Size=u(1,0,0,36),Position=u(0,0,0,120),BackgroundColor3=cd},p7,8,1)
lb(setR4,"Пауза проверки ларька (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
local stallDelayBox=bx(setR4,"2",u(0,46,0,24),u(1,-54,0,7))

do
    local upkeepInterval = 60 * 60
    local upkeepEnabled = false
    local nextUpkeep = 0
    local row = ui("Frame", {Size=u(1,0,0,36), Position=u(0,0,0,160), BackgroundColor3=cd}, p7, 8, 1)
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

local optCfg={shadows=true,materials=true,textures=true,particles=true,cleanup=false,no3d=false,hideui=false,fps=30}
local optOpenB=bt(p7,"ОПТИМИЗАЦИЯ",u(0.58,-4,0,38),u(0,0,1,-38),ac,8)
local customB=bt(p7,"КАСТОМ",u(0.42,-4,0,38),u(0.58,4,1,-38),cd,8,1)

local optModal=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p7,8,1)
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
local fpsBox=bx(fpsRow,"30",u(0,68,0,22),u(1,-74,0,4)) fpsBox.ZIndex=10

local optApplyB=bt(optModal,"ПРИМЕНИТЬ",u(0.48,0,0,30),u(0,8,1,-36),ac,6) optApplyB.ZIndex=9
local optCloseB=bt(optModal,"Закрыть",u(0.46,0,0,30),u(0.52,0,1,-36),cd,6,1) optCloseB.ZIndex=9
local pModal=ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p5,8,1)
local pScroll=ui("ScrollingFrame",{Size=u(1,-10,1,-42),Position=u(0,5,0,5),BackgroundTransparency=1,ScrollBarThickness=4,CanvasSize=u(0,0,0,0),ZIndex=9},pModal)
local pDoneB=bt(pModal,"Готово",u(1,-10,0,28),u(0,5,1,-33),ac,6) pDoneB.ZIndex=9

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
local tipStroke=Instance.new("UIStroke",tipBox) tipStroke.Color,tipStroke.Thickness=ac,1
local tipPad=Instance.new("UIPadding",tipBox) tipPad.PaddingTop,tipPad.PaddingBottom,tipPad.PaddingLeft,tipPad.PaddingRight=UDim.new(0,8),UDim.new(0,8),UDim.new(0,10),UDim.new(0,10)
local tipLbl=lb(tipBox,"",u(1,0,0,0),u(0,0,0,0),tx,17)
tipLbl.RichText,tipLbl.TextWrapped,tipLbl.AutomaticSize,tipLbl.ZIndex=true,true,Enum.AutomaticSize.Y,26

local function bindTip(obj,textStr,yOffset)
    obj.MouseEnter:Connect(function()
        tipLbl.Text=textStr
        tipBox.Position=u(0,112,0,yOffset or 44)
        tipBox.Visible=true
    end)
    obj.MouseLeave:Connect(function() tipBox.Visible=false end)
end

local mailLogCount=0
local function addMailLog(txt,tipText)
    mailLogCount=mailLogCount+1
    local entry=ui("Frame",{Size=u(1,-6,0,22),Position=u(0,2,0,(mailLogCount-1)*25),BackgroundColor3=bg},mLogScroll,5,1)
    local l=lb(entry,txt,u(1,-10,1,0),u(0,5,0,0),tx,17) l.TextTruncate=Enum.TextTruncate.AtEnd
    if tipText and tipText~="" then bindTip(entry,tipText,44) end
    mLogScroll.CanvasSize=u(0,0,0,mailLogCount*25)
    mLogScroll.CanvasPosition=Vector2.new(0,math.max(0,mailLogCount*25-85))
end

local selPlates,sentPlates={},{}
local function countSel() local n=0 for _ in pairs(selPlates) do n=n+1 end return n end
local function updPickTxt() pickB.Text="Номера: "..countSel() end

local function scanMyPlates()
    local pref,bestMap,bestCnt=tostring(plr.UserId).."_",{},0
    if type(getgc)=="function" then
        for _,obj in ipairs(getgc(true)) do
            if type(obj)=="table" and #obj>0 then
                local valid,tmp=0,{}
                for _,item in ipairs(obj) do
                    if type(item)=="table" then
                        local idV=rawget(item,"uid") or rawget(item,"sn") or rawget(item,"id")
                        local txtV=rawget(item,"text")
                        if type(idV)=="string" and idV:find(pref,1,true) and type(txtV)=="string" then
                            valid=valid+1
                            if not sentPlates[idV] and not rawget(item,"sold") and not rawget(item,"deleted") and not rawget(item,"inPost") then
                                tmp[idV]=txtV.." ["..tostring(rawget(item,"rarity") or "").."]"
                            end
                        end
                    end
                end
                if valid>=bestCnt and valid>0 then bestCnt,bestMap=valid,tmp end
            end
        end
    end
    local list={} for idV,lblTxt in pairs(bestMap) do table.insert(list,{id=idV,label=lblTxt}) end
    table.sort(list,function(a,b) return a.label<b.label end)
    return list
end
local function refreshModal()
    for _,ch in ipairs(pScroll:GetChildren()) do ch:Destroy() end
    local items=scanMyPlates()
    local validSet={} for _,it in ipairs(items) do validSet[it.id]=true end
    for k in pairs(selPlates) do if not validSet[k] then selPlates[k]=nil end end
    updPickTxt()
    for idx,it in ipairs(items) do
        local isOn=selPlates[it.id]==true
        local row=bt(pScroll,it.label,u(1,-8,0,26),u(0,2,0,(idx-1)*30),isOn and ac or cd,6,1) row.ZIndex=10
        row.MouseButton1Click:Connect(function()
            if selPlates[it.id] then selPlates[it.id]=nil row.BackgroundColor3=cd
            else selPlates[it.id]=true row.BackgroundColor3=ac end
            updPickTxt()
        end)
    end
    pScroll.CanvasSize=u(0,0,0,#items*30)
    return #items
end

pickB.MouseButton1Click:Connect(function() if refreshModal()==0 then mSt.Text="Номера не найдены. Открой инвентарь." return end pModal.Visible=true end)
pDoneB.MouseButton1Click:Connect(function() pModal.Visible=false updPickTxt() end)

local run,trRun,takeRun,stRun,okC,lN=false,false,false,false,0,0
local sniperSession=0
local lastTrader,takenPosts=nil,{}
local menuKey,waitingBind=Enum.KeyCode.RightControl,false

local originalProperties,optConn={},nil
local appliedOpt
local darkBg=ui("Frame",{Size=u(1,0,1,60),Position=u(0,0,0,-60),BackgroundColor3=c(12,12,17),Visible=false,ZIndex=-1},g)

local function setOptimizedProperty(object, property, value)
    if object[property] == value then return end
    local original = originalProperties[object]
    if not original then
        original = {}
        originalProperties[object] = original
    end
    if original[property] == nil then original[property] = object[property] end
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

local function applyCustomOpt(config)
    if optConn then optConn:Disconnect() optConn=nil end
    for object,properties in pairs(originalProperties) do
        for property,value in pairs(properties) do
            pcall(function() object[property] = value end)
        end
    end
    table.clear(originalProperties)
    appliedOpt = config

    darkBg.Visible = config ~= nil and config.no3d
    pcall(function() RS:Set3dRenderingEnabled(not darkBg.Visible) end)
    if type(setfpscap)=="function" then pcall(setfpscap, config and config.fps or 0) end
    if not config then return end

    if config.shadows or config.materials then
        pcall(function() setOptimizedProperty(settings().Rendering, "QualityLevel", Enum.QualityLevel.Level01) end)
    end
    if config.shadows then
        setOptimizedProperty(L, "GlobalShadows", false)
        setOptimizedProperty(L, "FogEnd", 9e9)
        for _,effect in ipairs(L:GetChildren()) do
            if effect:IsA("PostEffect") then setOptimizedProperty(effect, "Enabled", false) end
        end
    end
    for _,root in ipairs({workspace,P,L}) do
        for _,v in ipairs(root:GetDescendants()) do cleanObj(v, config) end
    end

    local pg=plr:FindFirstChild("PlayerGui")
    if config.hideui and pg then
        for _,gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then setOptimizedProperty(gui, "Enabled", false) end
        end
    end
    if config.shadows or config.materials or config.textures or config.particles or config.cleanup or config.hideui then
        optConn=game.DescendantAdded:Connect(function(v)
            if config.hideui and v:IsA("ScreenGui") and v.Parent==pg then
                setOptimizedProperty(v, "Enabled", false)
            elseif config.shadows and v:IsA("PostEffect") and v.Parent==L then
                setOptimizedProperty(v, "Enabled", false)
            elseif v:IsDescendantOf(workspace) or v:IsDescendantOf(P) or v:IsDescendantOf(L) then
                cleanObj(v, config)
            end
        end)
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
do
    local classicColors = {bg,sd,cd,ac,tx,sb,strokeColor,danger}
    local modernColors = {c(13,18,31),c(19,27,44),c(29,40,62),c(75,104,213),c(244,247,255),c(157,175,205),c(54,69,101),c(173,58,79)}
    local modal = ui("Frame",{Size=u(1,0,1,0),BackgroundColor3=bg,Visible=false,ZIndex=8},p7,10,1)
    local title = lb(modal,"Оформление меню",u(1,-24,0,34),u(0,12,0,8),tx,18)
    title.TextSize,title.ZIndex = 15,9
    local classic = bt(modal,"Старый дизайн",u(1,-24,0,44),u(0,12,0,54),cd,8,1)
    local modern = bt(modal,"Новый дизайн",u(1,-24,0,44),u(0,12,0,106),ac,8,1)
    local back = bt(modal,"Готово",u(1,-24,0,36),u(0,12,1,-48),cd,8,1)
    classic.ZIndex,modern.ZIndex,back.ZIndex = 9,9,9
    local headerTint = Instance.new("UIGradient",tp)
    headerTint.Color = ColorSequence.new(c(255,255,255),c(144,169,231))

    local function setTheme(useModern)
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
        sdF.Size = u(0,navWidth,1,-34)
        for _,page in ipairs(pgs) do
            page.Position = u(0,navWidth+7,0,39)
            page.Size = u(1,-navWidth-14,1,-44)
        end
        local navHeight = useModern and 34 or 28
        for index,button in ipairs(tbs) do
            button.Size = u(1,-12,0,navHeight)
            button.Position = u(0,6,0,8+(index-1)*(navHeight+6))
            button.TextSize = useModern and 12 or 11
        end
        mB.Size,cB.Size = u(0,useModern and 28 or 24,0,useModern and 26 or 22),u(0,useModern and 28 or 24,0,useModern and 26 or 22)
        mB.Position,cB.Position = u(1,useModern and -68 or -54,0,useModern and 4 or 6),u(1,useModern and -34 or -27,0,useModern and 4 or 6)
        for _,button in ipairs({optOpenB,customB,tB,trB,stAutoB,mSendB,mTakeB}) do
            button.TextSize = useModern and 13 or 11
            button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0,useModern and 10 or 8)
        end
        m:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0,useModern and 14 or 10)
        headerTint.Enabled = useModern
        menuTitle.TextSize = useModern and 16 or 11
        menuTitle.TextColor3 = useModern and tx or ac
        oB.Size = useModern and u(0,104,0,34) or u(0,86,0,28)
        oB.TextSize = useModern and 13 or 11
        classic.BackgroundColor3 = useModern and cd or ac
        modern.BackgroundColor3 = useModern and ac or cd
    end

    customB.Activated:Connect(function() modal.Visible = true end)
    classic.Activated:Connect(function() setTheme(false) end)
    modern.Activated:Connect(function() setTheme(true) end)
    back.Activated:Connect(function() modal.Visible = false end)
    setTheme(false)
end

local tog
do
    local TweenService = game:GetService("TweenService")
    local menuOpen = true
    local restingPosition,restingSize
    local tween,animationId = nil,0

    tog = function(open,immediate)
        if open == nil then open = not menuOpen end
        if open == menuOpen and not immediate then return end
        menuOpen = open
        animationId += 1
        local id = animationId
        if tween then tween:Cancel() tween = nil end

        if restingPosition then
            m.Position,m.Size = restingPosition,restingSize
        end
        restingPosition,restingSize = m.Position,m.Size
        menuAnimating = false
        m.ClipsDescendants = false
        if not modernTheme or immediate then
            m.Visible,oB.Visible = open,not open
            restingPosition,restingSize = nil,nil
            return
        end

        menuAnimating = true
        m.ClipsDescendants = true
        local buttonPosition,buttonSize = oB.AbsolutePosition,oB.AbsoluteSize
        local center = buttonPosition+buttonSize/2
        local collapsedSize = u(0,math.max(24,buttonSize.X),0,math.max(16,buttonSize.Y))
        local collapsedPosition = u(0,buttonPosition.X,0,buttonPosition.Y)
        local fullPosition,fullSize = restingPosition,restingSize
        if open then m.Position,m.Size = collapsedPosition,collapsedSize end
        m.Visible,oB.Visible = true,false
        local fullTopLeft = open and Vector2.new(
            g.AbsoluteSize.X*fullPosition.X.Scale+fullPosition.X.Offset,
            g.AbsoluteSize.Y*fullPosition.Y.Scale+fullPosition.Y.Offset
        ) or m.AbsolutePosition
        local fullCenter = fullTopLeft+Vector2.new(fullSize.X.Offset/2,fullSize.Y.Offset/2)
        local neckSize = Vector2.new(math.max(64,fullSize.X.Offset*0.32),math.max(32,fullSize.Y.Offset*0.65))
        local neckCenter = center:Lerp(fullCenter,0.58)+Vector2.new(0,-14)

        task.spawn(function()
            local function step(duration,position,size,style,direction)
                tween = TweenService:Create(m,TweenInfo.new(duration,style,direction),{Position=position,Size=size})
                tween:Play()
                return tween.Completed:Wait() == Enum.PlaybackState.Completed and animationId == id
            end
            local neck = u(0,neckCenter.X-neckSize.X/2,0,neckCenter.Y-neckSize.Y/2)
            if not step(0.14,neck,u(0,neckSize.X,0,neckSize.Y),Enum.EasingStyle.Quad,Enum.EasingDirection.Out) then return end
            if not step(0.2,open and fullPosition or collapsedPosition,open and fullSize or collapsedSize,
                Enum.EasingStyle.Cubic,open and Enum.EasingDirection.Out or Enum.EasingDirection.In) then return end
            tween = nil
            m.Visible,oB.Visible = open,not open
            m.Position,m.Size = fullPosition,fullSize
            m.ClipsDescendants,menuAnimating = false,false
            restingPosition,restingSize = nil,nil
        end)
    end
    g.Destroying:Connect(function() if tween then tween:Cancel() end end)
end
mB.MouseButton1Click:Connect(function() tog(false) end)

local afkPurchases = {count=0, spent=0, byRarity={}, last="—"}
local afkRolls = {available=false, count=0, caught=0, byRarity={}, last="—", lastPrice="—", batchPrice=nil}
do
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
        if not priceBox then return end
        local children = priceBox:GetChildren()
        local price = parsePrice(children[3],false)
        if price then return fmtNum(price).." ₽" end
        for _,label in ipairs(children) do
            price = parsePrice(label,true)
            if price then return fmtNum(price).." ₽" end
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

    local function observeMiniRoll(pg)
        local plates = pg and pg:FindFirstChild("PlatesUI")
        local mini = plates and plates:FindFirstChild("RollMini")
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

    task.spawn(function()
        while g.Parent do
            local pg = plr:FindFirstChild("PlayerGui")
            local attached = results and results:IsDescendantOf(plr)
            if not attached then
                local window = pg and pg:FindFirstChild("RollWindow",true)
                results = window and window:FindFirstChild("Results")
            end
            if results then
                for _,card in ipairs(results:GetChildren()) do observeCard(card,not afkRolls.available) end
                afkRolls.available = true
            end
            for card in pairs(seen) do
                if card.Parent ~= results then seen[card] = nil end
            end
            observeMiniRoll(pg)
            task.wait(0.2)
        end
    end)
end

local exitAfkMode
do
    local openAfk = bt(p7,"AFK-РЕЖИМ",u(1,0,0,32),u(0,0,0,200),cd,8,1)
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
        Image=av.Image, ZIndex=33,
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

    exitAfkMode = function()
        if not overlay.Visible then return false end
        overlay.Visible = false
        g.DisplayOrder = previousOrder
        applyCustomOpt(previousOpt)
        tog(true)
        return true
    end
    closeAfk.Activated:Connect(exitAfkMode)
    openAfk.Activated:Connect(function()
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
    end)
    task.spawn(function()
        while g.Parent do
            if overlay.Visible then refreshAfk() end
            task.wait(1)
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

U.InputChanged:Connect(function(i)
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

U.InputEnded:Connect(function(i)
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
    run,trRun,takeRun,stRun=false,false,false,false
    if appliedOpt then applyCustomOpt(nil) end
    g:Destroy()
end)
bindB.MouseButton1Click:Connect(function() waitingBind=true bindB.Text="Нажми клавишу..." end)
afkB.MouseButton1Click:Connect(function() afkOn=not afkOn afkB.BackgroundColor3=afkOn and ac or bg afkB.Text=afkOn and "ON" or "OFF" end)
plr.Idled:Connect(function() if afkOn and g.Parent then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end end)
U.InputBegan:Connect(function(i,gp)
    if not g.Parent then return end
    if waitingBind and i.UserInputType==Enum.UserInputType.Keyboard then waitingBind=false menuKey=i.KeyCode bindB.Text=i.KeyCode.Name return end
    if not gp and i.KeyCode==menuKey then
        if exitAfkMode() then return end
        dlg.Visible=false
        tog()
    end
end)
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

mSendB.MouseButton1Click:Connect(function()
    local clean=idBox.Text:gsub("%s+","")
    local amt=parseM(sumBox.Text)
    if amt>0 then sumBox.Text=tostring(amt) end
    local platesArr,plateNames={},{}
    local allItems=scanMyPlates()
    local nameMap={} for _,it in ipairs(allItems) do nameMap[it.id]=it.label end
    for k in pairs(selPlates) do table.insert(platesArr,k) table.insert(plateNames,nameMap[k] or k) end
    if clean=="" then mSt.Text="Ошибка: впиши юзернейм." return end
    if amt<=0 and #platesArr==0 then mSt.Text="Ошибка: выбери номера или впиши сумму > 0." return end
    mSt.Text="Ищу игрока..."

    local okLook,lookRes=pcall(function() return PS:InvokeServer("look",clean) end)
    if not okLook then mSt.Text="Ошибка вызова look" return end
    if type(lookRes)=="table" and lookRes.ok==false then mSt.Text="Ошибка: "..tostring(lookRes.err or "игрок не найден") return end

    local uid=0
    if type(lookRes)=="table" then
        local uData=lookRes.user or lookRes.player or lookRes.data or lookRes
        uid=tonumber(uData.userId) or tonumber(uData.id) or tonumber(uData.uid) or 0
    end
    if uid<=0 then local okId,apiId=pcall(function() return P:GetUserIdFromNameAsync(clean) end) if okId and apiId then uid=apiId end end
    if uid<=0 then mSt.Text="Ошибка: не удалось получить ID игрока." return end

    task.wait(0.2)
    local ok,res=pcall(function() return PS:InvokeServer("send",uid,platesArr,{},amt) end)
    if ok then
        if type(res)=="table" and res.ok==false then
            local errTxt=tostring(res.err or "ошибка")
            mSt.Text="Отказ: "..errTxt
            if errTxt:lower():find("нет") or errTxt:lower():find("найден") or errTxt:lower():find("принадлежит") then
                for _,idV in ipairs(platesArr) do sentPlates[idV]=true end
                selPlates={} updPickTxt()
            end
        else
            for _,idV in ipairs(platesArr) do sentPlates[idV]=true end
            mSt.Text="Отправлено -> "..clean
            local pStr=#plateNames>0 and table.concat(plateNames,", ") or "без номеров"
            local shortLine=string.format("Отправлено (%s): %s / %s ₽",clean,pStr,fmtNum(amt))
            local tLines={
                string.format("<font color=\"#9191A5\">Получатель:</font> <b>%s</b>",clean),
                string.format("<font color=\"#9191A5\">Сумма:</font> <font color=\"#4ADE80\"><b>%s ₽</b></font>",fmtNum(amt))
            }
            if #plateNames>0 then
                table.insert(tLines,"<font color=\"#9191A5\">Номера:</font>")
                for _,pn in ipairs(plateNames) do table.insert(tLines,fmtPlateRich(pn)) end
            end
            addMailLog(shortLine,table.concat(tLines,"\n"))
            selPlates={} updPickTxt()
        end
    else mSt.Text="Ошибка отправки" end
end)

mTakeB.MouseButton1Click:Connect(function()
    takeRun=not takeRun
    mTakeB.BackgroundColor3=takeRun and danger or cd
    mTakeB.Text=takeRun and "АВТО-ПРИЁМ: ВКЛ" or "АВТО-ПРИЁМ: ВЫКЛ"
    if not takeRun then mSt.Text="Авто-приём остановлен." return end
    mSt.Text="Авто-приём включен."
    task.spawn(function()
        local function scanBoxTable(tbl,visited)
            if type(tbl)~="table" or visited[tbl] then return end
            visited[tbl]=true
            local pid=rawget(tbl,"id")
            if type(pid)=="string" and pid:sub(1,5)=="post_" then
                if not rawget(tbl,"claimed") and not rawget(tbl,"taken") and not rawget(tbl,"claimedAt") and not takenPosts[pid] then
                    local okTake,takeRes=pcall(function() return PS:InvokeServer("take",{pid}) end)
                    if okTake and type(takeRes)=="table" and takeRes.ok then
                        takenPosts[pid]=true
                        local infoLine,fullTip=formatBoxPost(tbl)
                        mSt.Text="Принята новая посылка"
                        addMailLog(infoLine,fullTip)
                    end
                    task.wait(0.4)
                end
            end
            for _,v in pairs(tbl) do if type(v)=="table" then scanBoxTable(v,visited) end end
        end

        while takeRun do
            local okBox,boxRes=pcall(function() return PS:InvokeServer("box") end)
            if okBox and type(boxRes)=="table" then scanBoxTable(boxRes,{}) end
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

local function buyAllStall()
    local bought=0
    for _,pid in ipairs(allPotions) do
        local level=tonumber(pid:match("_(%d+)$"))
        if not stRun then break end
        if level and stallLevels[level] then
            for _=1,10 do
                if not stRun or not stallLevels[level] then break end
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
        local hasStock=getStallState()
        if not stRun then
            stInfo.Text="Статус: ВЫКЛ"
        else
            if hasStock then
                stInfo.Text="Вижу товар в ларьке. Скупаю..."
                local cnt=buyAllStall()
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
    stAutoB.BackgroundColor3=stRun and danger or ac
    stAutoB.Text=stRun and "АВТО-ЛАРЁК: ВКЛ" or "АВТО-ЛАРЁК: ВЫКЛ"
end)

trB.MouseButton1Click:Connect(function()
    trRun=not trRun
    trB.BackgroundColor3=trRun and danger or ac
    trB.Text=trRun and "АВТО-ТОРГАШ: ВКЛ" or "АВТО-ТОРГАШ: ВЫКЛ"
    if not trRun then trSt.Text="Статус: ВЫКЛ" return end
    lastTrader=nil
    task.spawn(function()
        while trRun do
            local npc=workspace:FindFirstChild("TraderWalker")
            if npc and npc~=lastTrader then
                local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                local nHrp=npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
                if nHrp and hrp then
                    local old=hrp.CFrame
                    trSt.Text="Пришёл новый Торгаш. Лечу скупать..."
                    hrp.CFrame=nHrp.CFrame*CFrame.new(0,0,-4)
                    local pr=npc:FindFirstChildWhichIsA("ProximityPrompt",true)
                    if pr and fireproximityprompt then task.wait(0.2) fireproximityprompt(pr) end
                    task.wait(0.35)
                    for i=1,4 do
                        if not trRun then break end
                        if traderEnabled[i] then pcall(function() TR:InvokeServer("buy",i) end) task.wait(0.25) end
                    end
                    if hrp then hrp.CFrame=old end
                    lastTrader=npc
                    trSt.Text="Выбранные слоты обработаны. Жду следующего Торгаша..."
                end
            elseif not npc then
                lastTrader=nil
                trSt.Text="Торгаша нет на карте. Жду прихода..."
            end
            task.wait(2)
        end
    end)
end)
local function stop(msg) run=false tB.BackgroundColor3,tB.Text=ac,"СНАЙПЕР: ВЫКЛ" st.Text=msg.."\nУспешных покупок: "..okC end
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
