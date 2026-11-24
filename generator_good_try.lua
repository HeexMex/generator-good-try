local U,R,C,P,VU,L,RS=game:GetService("UserInputService"),game:GetService("ReplicatedStorage"),game:GetService("CoreGui"),game:GetService("Players"),game:GetService("VirtualUser"),game:GetService("Lighting"),game:GetService("RunService")
local plr=P.LocalPlayer
local Rem=R:WaitForChild("Remotes")
local GM,ML,MB,TR,PS,ST=Rem.GetMarket,Rem.MarketLot,Rem.MarketBuy,Rem.Trader,Rem.Post,Rem.Stall
if C:FindFirstChild("ZS") then C.ZS:Destroy() end

local g=Instance.new("ScreenGui",C) g.Name,g.ResetOnSpawn,g.IgnoreGuiInset="ZS",false,true
local u,c=UDim2.new,Color3.fromRGB
local bg,sd,cd,ac,tx,sb=c(15,15,21),c(21,21,29),c(27,27,37),c(130,85,255),c(242,242,247),c(145,145,165)

local function ui(t,p,par,r,s)
    local o=Instance.new(t,par) for k,v in pairs(p) do o[k]=v end
    if r then Instance.new("UICorner",o).CornerRadius=UDim.new(0,r) end
    if s then local k=Instance.new("UIStroke",o) k.Color,k.Thickness,k.ApplyStrokeMode=c(44,44,58),1,Enum.ApplyStrokeMode.Border end
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
lb(tp,"Меню",u(0,140,1,0),u(0,12,0,0),ac,18)
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
local trCard=ui("Frame",{Size=u(1,0,0,185),BackgroundColor3=cd},p4,8,1)
local trSt=lb(trCard,"Статус: ВЫКЛ",u(1,-16,1,-12),u(0,8,0,6),tx,17) trSt.TextWrapped,trSt.TextYAlignment=true,0
local trB=bt(p4,"АВТО-ТОРГАШ: ВЫКЛ",u(1,0,0,40),u(0,0,1,-40),ac,8)

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
local stInfo=lb(stCard,"Статус: ВЫКЛ",u(1,-16,1,-12),u(0,8,0,6),tx,17) stInfo.TextWrapped,stInfo.TextYAlignment=true,0
local stAutoB=bt(p6,"АВТО-ЛАРЁК: ВЫКЛ",u(1,0,0,40),u(0,0,1,-40),ac,8)
local setR1=ui("Frame",{Size=u(1,0,0,38),BackgroundColor3=cd},p7,8,1)
lb(setR1,"Клавиша меню:",u(0.55,0,1,0),u(0,10,0,0),sb)
local bindB=bt(setR1,"RightControl",u(0.42,-8,0,24),u(0.58,0,0,7),bg,6,1)

local setR2=ui("Frame",{Size=u(1,0,0,38),Position=u(0,0,0,44),BackgroundColor3=cd},p7,8,1)
lb(setR2,"Анти-АФК (защита от кика):",u(0.7,0,1,0),u(0,10,0,0),sb)
local afkOn=true
local afkB=bt(setR2,"ON",u(0,46,0,24),u(1,-54,0,7),ac,6,1)

local setR3=ui("Frame",{Size=u(1,0,0,38),Position=u(0,0,0,88),BackgroundColor3=cd},p7,8,1)
lb(setR3,"Пауза проверки почты (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
local mailDelayBox=bx(setR3,"4",u(0,46,0,24),u(1,-54,0,7))

local setR4=ui("Frame",{Size=u(1,0,0,38),Position=u(0,0,0,132),BackgroundColor3=cd},p7,8,1)
lb(setR4,"Пауза проверки ларька (сек):",u(0.7,0,1,0),u(0,10,0,0),sb)
local stallDelayBox=bx(setR4,"2",u(0,46,0,24),u(1,-54,0,7))

local optCfg={shadows=true,materials=true,textures=true,particles=true,cleanup=false,no3d=false,hideui=false,fps=30}
local optOpenB=bt(p7,"НАСТРОЙКА ОПТИМИЗАЦИИ",u(1,0,0,38),u(0,0,1,-38),ac,8)

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
local lastTrader,takenPosts=nil,{}
local menuKey,waitingBind=Enum.KeyCode.RightControl,false

local origMats,origGuis,optConn={},{},nil
local darkBg=ui("Frame",{Size=u(1,0,1,60),Position=u(0,0,0,-60),BackgroundColor3=c(12,12,17),Visible=false,ZIndex=-1},g)

local function cleanObj(v)
    if optCfg.cleanup then
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end) return
        elseif v:IsA("BasePart") and not v.CanCollide and not v:FindFirstAncestor("TraderWalker") and not v:FindFirstAncestorOfClass("Player") then
            if v.Size.Magnitude<12 and not v:FindFirstChildWhichIsA("ProximityPrompt",true) then pcall(function() v:Destroy() end) return end
        end
    end
    if v:IsA("BasePart") then
        if optCfg.materials then
            if not origMats[v] then origMats[v]=v.Material end
            v.Material,v.Reflectance,v.CastShadow=Enum.Material.SmoothPlastic,0,false
        else
            if origMats[v] then v.Material=origMats[v] end
            v.CastShadow=not optCfg.shadows
        end
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if not v:FindFirstAncestor("PlatesUI") then v.Transparency=optCfg.textures and 1 or 0 end
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
        v.Enabled=not optCfg.particles
        if optCfg.particles and v:IsA("ParticleEmitter") then pcall(function() v:Clear() end) end
    end
end

local function applyCustomOpt()
    pcall(function() settings().Rendering.QualityLevel=(optCfg.shadows or optCfg.materials) and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
    L.GlobalShadows=not optCfg.shadows
    L.FogEnd=optCfg.shadows and 9e9 or 100000
    for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") then v.Enabled=not optCfg.shadows end end
    for _,root in ipairs({workspace,workspace.CurrentCamera,P,L}) do
        if root then for _,v in ipairs(root:GetDescendants()) do cleanObj(v) end end
    end
    local pg=plr:FindFirstChild("PlayerGui")
    if pg then
        for _,gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                if optCfg.hideui then
                    if origGuis[gui]==nil then origGuis[gui]=gui.Enabled end
                    gui.Enabled=false
                elseif origGuis[gui]~=nil then
                    gui.Enabled=origGuis[gui]
                    origGuis[gui]=nil
                end
            end
        end
    end
    if optConn then optConn:Disconnect() optConn=nil end
    if optCfg.materials or optCfg.textures or optCfg.particles or optCfg.cleanup or optCfg.hideui then
        optConn=game.DescendantAdded:Connect(function(v)
            if optCfg.hideui and v:IsA("ScreenGui") and pg and v.Parent==pg then
                if origGuis[v]==nil then origGuis[v]=v.Enabled end
                v.Enabled=false
            elseif v:IsDescendantOf(workspace) or (workspace.CurrentCamera and v:IsDescendantOf(workspace.CurrentCamera)) then
                cleanObj(v)
            end
        end)
    end
    darkBg.Visible=optCfg.no3d
    pcall(function() RS:Set3dRenderingEnabled(not optCfg.no3d) end)
    if type(setfpscap)=="function" then pcall(function() setfpscap(optCfg.fps) end) end
end

for _,it in ipairs(optItems) do
    local sw,rw=optBtns[it.k],optRows[it.k]
    bindTip(rw,string.format("<b>%s</b>\n<font color=\"#B0B0C8\">%s</font>",it.n,it.tip),8)
    sw.MouseButton1Click:Connect(function() optCfg[it.k]=not optCfg[it.k] sw.BackgroundColor3=optCfg[it.k] and ac or bg sw.Text=optCfg[it.k] and "ON" or "OFF" end)
end
bindTip(fpsRow,"<b>Лимит FPS</b>\n<font color=\"#B0B0C8\">Ограничивает частоту кадров в секунду (например, 15 или 30 для твинков). Впиши 0, чтобы снять лимит.</font>",8)

fpsBox.FocusLost:Connect(function() local val=tonumber((fpsBox.Text:gsub("%D",""))) or 30 optCfg.fps=val fpsBox.Text=tostring(val) end)
optOpenB.MouseButton1Click:Connect(function() optModal.Visible=true end)
optCloseB.MouseButton1Click:Connect(function() tipBox.Visible=false optModal.Visible=false end)
optApplyB.MouseButton1Click:Connect(function() local val=tonumber((fpsBox.Text:gsub("%D",""))) optCfg.fps=val or 30 fpsBox.Text=tostring(optCfg.fps) applyCustomOpt() tipBox.Visible=false optModal.Visible=false end)

local function tog(s) if s==nil then s=not m.Visible end m.Visible,oB.Visible=s,not s end
mB.MouseButton1Click:Connect(function() tog(false) end)

local dragWin,winStart,winPos=false,nil,nil
tp.InputBegan:Connect(function(i)
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
        if dragWin then
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
    if optConn then optConn:Disconnect() end
    for gui,st in pairs(origGuis) do if gui and gui.Parent then gui.Enabled=st end end
    pcall(function() RS:Set3dRenderingEnabled(true) end)
    g:Destroy()
end)
bindB.MouseButton1Click:Connect(function() waitingBind=true bindB.Text="Нажми клавишу..." end)
afkB.MouseButton1Click:Connect(function() afkOn=not afkOn afkB.BackgroundColor3=afkOn and ac or bg afkB.Text=afkOn and "ON" or "OFF" end)
plr.Idled:Connect(function() if afkOn and g.Parent then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end end)
U.InputBegan:Connect(function(i,gp)
    if not g.Parent then return end
    if waitingBind and i.UserInputType==Enum.UserInputType.Keyboard then waitingBind=false menuKey=i.KeyCode bindB.Text=i.KeyCode.Name return end
    if not gp and i.KeyCode==menuKey then dlg.Visible=false tog() end
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
    mTakeB.BackgroundColor3=takeRun and c(200,55,65) or cd
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
        for _=1,10 do
            local ok,res=pcall(function() return ST:InvokeServer("buy",pid) end)
            if ok and type(res)=="table" and res.ok then
                bought=bought+1
                stInfo.Text="Покупка ассортимента...\nКуплено за заход: "..bought.." шт."
                task.wait(0.18)
            else break end
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
    stAutoB.BackgroundColor3=stRun and c(200,55,65) or ac
    stAutoB.Text=stRun and "АВТО-ЛАРЁК: ВКЛ" or "АВТО-ЛАРЁК: ВЫКЛ"
end)

trB.MouseButton1Click:Connect(function()
    trRun=not trRun
    trB.BackgroundColor3=trRun and c(200,55,65) or ac
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
                    for i=1,4 do if not trRun then break end pcall(function() TR:InvokeServer("buy",i) end) task.wait(0.25) end
                    if hrp then hrp.CFrame=old end
                    lastTrader=npc
                    trSt.Text="Всё скуплено. Жду следующего Торгаша..."
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
local function freshP(id) wN() local ok,inf=pcall(function() return ML:InvokeServer(id) end) return ok and getP(inf) or 0 end

local function getRarMax(rarId)
    local r=rarMap[rarId]
    if not (r and r.on) then return 0 end
    return parseM(r.box.Text)
end

local function hold(lot,maxP,lim)
    local act,fixed=getP(lot),false
    if act<=0 or act>maxP then bl[lot.id]=true return false end
    for att=1,40 do
        if not run or (lim>0 and okC>=lim) then return true end
        wN()
        local ok,res=pcall(function() return MB:InvokeServer(lot.id,act) end)
        if ok and type(res)=="table" then
            if res.ok then okC=okC+1 bl[lot.id]=true st.Text="Куплен ["..tostring(lot.rarity).."]: "..tostring(lot.text).." ("..act.." ₽)\nУспешных: "..okC if lim>0 and okC>=lim then stop("Готово.") end return true end
            local err=tostring(res.err or "ожидание") local le=err:lower()
            if le:find("изменилась") then
                if fixed then bl[lot.id]=true return false end
                fixed=true
                local np=getP(res) if np<=0 then np=freshP(lot.id) end
                if np>0 and np<=maxP then act=np st.Text="Новая цена: "..act.." ₽" else bl[lot.id]=true st.Text="Пропуск: "..np.." ₽ > лимита" return false end
            elseif le:find("денег") or le:find("средств") or le:find("баланс") or le:find("мест") or le:find("слот") then stop("Ошибка: "..err) return true
            elseif le:find("закрыт") or le:find("продан") or le:find("купили") or le:find("нет такого") or le:find("найден") then bl[lot.id]=true st.Text="Пропуск: "..err return false
            else st.Text="Ожидание: "..tostring(lot.text).." ("..act.." ₽) ["..att.."]\n"..err if le:find("быстро") then task.wait(1) end end
        end
    end
    bl[lot.id]=true return false
end

local function step()
    local lim=tonumber((lBox.Text:gsub("%D",""))) or 0
    if lim>0 and okC>=lim then stop("Лимит достигнут.") return end
    local actR={} for _,r in ipairs(rars) do if r.on and getRarMax(r.id)>0 then table.insert(actR,r.id) end end
    if #actR==0 then st.Text="Ошибка: включи редкость и укажи цену > 0." return end
    wN()
    local ok,res=pcall(function() return GM:InvokeServer({q="",kind="fix",sort=curSort.id,rar=actR}) end)
    if ok and type(res)=="table" and type(res.items)=="table" then
        local now=tonumber(res.now) or os.time()
        for _,lot in ipairs(res.items) do
            if not run or (lim>0 and okC>=lim) then break end
            local p=getP(lot)
            local rMax=getRarMax(lot.rarity)
            if lot.fix and rMax>0 and (tonumber(lot.expiresAt) or now+100)>now and lot.seller~=plr.UserId and p>0 and p<=rMax and not bl[lot.id] then
                if hold(lot,rMax,lim) then return end
            end
        end
        if run then st.Text="Поиск ("..curSort.n..") по "..#actR.." редкостям...\nУспешных покупок: "..okC end
    end
end

tB.MouseButton1Click:Connect(function()
    run=not run
    if run then tB.BackgroundColor3,tB.Text=c(200,55,65),"СТОП" bl,okC={},0 task.spawn(function() while run do step() end end)
    else stop("Остановлено") end
end)
