local imgui = require 'imgui'
local encoding = require 'encoding'
local font =  renderCreateFont('Palatino', 12)
local zxc = require 'lib.samp.events'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local window = imgui.ImBool(false)
local trashWH = imgui.ImBool(false)
local botLoader = imgui.ImBool(false)
local stiler = imgui.ImBool(false)
local flood = imgui.ImBool(false)

local objs = {
    [2670] = 'мусор1',
    [2673] = 'мусор2',
    [2674] = 'мусор3',
    [2677] = 'мусор4'
}
local step = -1

onReceiveRpc = function(id, bs)
    if id == 73 and botLoader.v then
        raknetBitStreamIgnoreBits(bs, 64)
        local length, text = raknetBitStreamReadInt32(bs)
        local text = raknetBitStreamReadString(bs, length)
        if text:find('Go to Stock') then
            step = 1
        elseif text:find('Successful') then
            step = 2
        end
    end
end

zxc.onShowDialog = function(id, style, title, button1, button2, text)
    if id == 7881 and stiler.v and isKeyDown(0x52) then
    	local number = 0
    	for s in string.gmatch(text, "[^[]+") do
    		if s:find('{FFDB56}') then
    			sampSendDialogResponse(id, 1, number - 1)
    			break
    		else
    			number = number + 1
    		end
		end
		return false
    end
end

run = function()
    lua_thread.create(function()
        while true do
            wait(0)
            if botLoader.v then
                if step == 0 then
                    BeginToPoint(258, 2013, 17, 0.7, -255, true)
                    setGameKeyState(21, 255)
                    wait(300)
                elseif step == 1 then
                    BeginToPoint(214, 2013, 17, 0.7, -255, true) 
                    BeginToPoint(213, 2019, 17, 0.7, -255, true)
                    BeginToPoint(230, 2020, 17, 0.7, -255, true)
                    BeginToPoint(239, 2027, 17, 0.7, -255, true)
                    for i = 0, 1 do
                        setGameKeyState(21, 255)
                        wait(150)
                    end
                elseif step == 2 then
                    BeginToPoint(232, 2021, 17, 0.7, -255, true)
                    BeginToPoint(212, 2020, 17, 0.7, -255, true)
                    BeginToPoint(212, 2013, 17, 0.7, -255, true)
                    BeginToPoint(258, 2013, 17, 0.7, -255, true)
                    step = 0
                end
            else
                break
            end
        end
    end)
end

function main()
    while not isSampAvailable() do wait(200) end
    imgui.Process = false
    sampRegisterChatCommand('jail', function()
        window.v = not window.v
    end)
    sampRegisterChatCommand('spos', function()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        setClipboardText(math.floor(x) ..', '..math.floor(y)..', '..math.floor(z))
    end)
    while true do
        wait(0)
        imgui.Process = window.v
        if trashWH.v then
            for _, objH in pairs(getAllObjects()) do
                local modelid = getObjectModel(objH)
                local object = objs[modelid]
                if object then
                    if isObjectOnScreen(objH) then
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local res, objectX, objectY, objectZ = getObjectCoordinates(objH)
                        if res then
                            local mX, mY = convert3DCoordsToScreen(x, y, z)
                            local obX, obY = convert3DCoordsToScreen(objectX, objectY, objectZ)
                            renderDrawLine(mX, mY, obX, obY, 1, -1)
                            renderFontDrawText(font, '[МУСОР]', obX, obY,-1)
                        end
                    end
                end
            end
        end
        if isKeyDown(0x52) and stiler.v or isKeyDown(0x52) and flood.v then
            if stiler.v then
                printStringNow('Steal', 100)
            elseif flood.v then
                printStringNow('Flood', 100)
            end
            setGameKeyState(21, 255)
            wait(0)
            setGameKeyState(21, 0)
        end
    end
end

function imgui.OnDrawFrame()
    if window.v then
        imgui.SetNextWindowPos(imgui.ImVec2(350.0, 250.0), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(225.0, 80.0), imgui.Cond.FirstUseEver)
        imgui.Begin('Jail bot by ik0nka', window, imgui.WindowFlags.NoResize)

        imgui.Checkbox(u8'Вх на мусор', trashWH)
        imgui.SameLine()
        if imgui.Checkbox(u8'Бот грузчик', botLoader) then
            step = 0
            run()
        end
        imgui.Checkbox(u8'Кража еды', stiler)
        imgui.SetCursorPos(imgui.ImVec2(116.5, 48));
            imgui.Checkbox(u8'Флуд ALT', flood)

        imgui.End()
    end
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(9, 5)
    style.WindowRounding = 10
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(9.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)


    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end
apply_custom_style()

function BeginToPoint(x, y, z, radius, move_code, isSprint)
    repeat
        local posX, posY, posZ = GetCoordinates()
        local dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        setAngle(x, y, dist, 0.08)
        MovePlayer(move_code, isSprint)
        wait(0)
    until not botLoader.v or dist < radius
end

function MovePlayer(move_code, isSprint)
    setGameKeyState(1, move_code)
    --[[255 - обычный бег назад
       -255 - обычный бег вперед
      65535 - идти шагом вперед
    -65535 - идти шагом назад]]
    if isSprint then setGameKeyState(16, 255) end
end

function setAngle(x, y, distance, speed)
    local source_x = fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))
    local source_z = fix(representIntAsFloat(readMemory(0xB6F258, 4, false))) + math.pi
    local angle = GetAngleBeetweenTwoPoints(x,y) - source_z - math.pi

    if distance > 1.8 then
        if angle > -0.1 and angle < 0.03 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -5.7 and angle > -5.93 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -6.0 and angle > -6.4 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle > 0.04 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        elseif angle < -3.5 and angle > -5.67 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        else setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))-speed)
        end
    else setCameraPositionUnfixed(source_x, GetAngleBeetweenTwoPoints(x,y)) end
end

function GetAngleBeetweenTwoPoints(x2,y2)
    local x1, y1, z1 = getCharCoordinates(playerPed)
    local plus = 0.0
    local mode = 1
    if x1 < x2 and y1 > y2 then plus = math.pi/2; mode = 2; end
    if x1 < x2 and y1 < y2 then plus = math.pi; end
    if x1 > x2 and y1 < y2 then plus = math.pi*1.5; mode = 2; end
    local lx = x2 - x1
    local ly = y2 - y1
    lx = math.abs(lx)
    ly = math.abs(ly)
    if mode == 1 then ly = ly/lx;
    else ly = lx/ly; end 
    ly = math.atan(ly)
    ly = ly + plus
    return ly
end

function fix(angle)
    while angle > math.pi do
        angle = angle - (math.pi*2)
    end
    while angle < -math.pi do
        angle = angle + (math.pi*2)
    end
    return angle
end

function GetCoordinates()
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(playerPed)
    end
end