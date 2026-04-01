--[[
    Dispatcher Client Script - RELEASE v1.0
    Розміщення: StarterPlayerScripts
    
    Диспетчерська панель метро
    - Червона лінія (Put1) зверху ← напрямок
    - Синя лінія (Put2) знизу → напрямок
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DispatcherFolder = ReplicatedStorage:WaitForChild("DispatcherEvents")
local OpenGUI = DispatcherFolder:WaitForChild("OpenDispatcherGUI")
local CloseGUI = DispatcherFolder:WaitForChild("CloseDispatcherGUI")
local UpdateDetectors = DispatcherFolder:WaitForChild("UpdateDetectors")

-- ═══════════════════════════════════════════════════════════════
-- НАЛАШТУВАННЯ
-- ═══════════════════════════════════════════════════════════════

local COLORS = {
	Background = Color3.fromRGB(30, 35, 45),
	Line1 = Color3.fromRGB(220, 70, 70),
	Line2 = Color3.fromRGB(60, 150, 230),
	Station = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(255, 255, 255),
	Train = Color3.fromRGB(255, 210, 60),
	Panel = Color3.fromRGB(45, 50, 60),
}

local MAP_CONFIG = {
	minZ = -3600,
	maxZ = 20000,
	Put1_Y = 0.45,  -- Червона ЗВЕРХУ
	Put2_Y = 0.55,  -- Синя ЗНИЗУ
	scale = 2.5,
}

-- Станції (середні індекси)
local STATIONS = {
	Put1 = {
		{idx = 2, name = "Тупік Лісова"},
		{idx = 11, name = "Лісова"},
		{idx = 55, name = "Чернігівська"},
		{idx = 95, name = "Дарниця"},
		{idx = 158, name = "Лівобережна"},
		{idx = 216, name = "Гідропарк"},
		{idx = 259, name = "Дніпро"},
		{idx = 271, name = "Тупік Дніпро"},
	},
	Put2 = {
		{idx = 4, name = "Тупік"},
		{idx = 15, name = "Дніпро"},
		{idx = 56, name = "Гідропарк"},
		{idx = 114, name = "Лівобережна"},
		{idx = 177, name = "Дарниця"},
		{idx = 218, name = "Чернігівська"},
		{idx = 262, name = "Лісова"},
	},
}

-- Z координати детекторів
local DETECTOR_Z = {
	Put1 = {
		[0]=19770.6,[1]=19691.0,[2]=19212.9,[3]=19611.3,[4]=19292.6,
		[5]=19531.6,[6]=19372.3,[7]=19451.9,[8]=19132.9,[9]=19051.4,
		[10]=18968.2,[11]=18882.4,[12]=18797.7,[13]=18714.2,[14]=18631.0,
		[15]=18547.8,[16]=18463.6,[17]=18380.4,[18]=18297.2,[19]=18215.9,
		[20]=18134.2,[21]=18051.4,[22]=17968.4,[23]=17885.7,[24]=17802.5,
		[25]=17719.3,[26]=17636.2,[27]=17553.2,[28]=17470.0,[29]=17386.8,
		[30]=17303.6,[31]=17220.4,[32]=17137.2,[33]=17054.0,[34]=16970.9,
		[35]=16887.4,[36]=16803.1,[37]=16718.6,[38]=16634.0,[39]=16549.3,
		[40]=16464.7,[41]=16379.7,[42]=16293.8,[43]=16208.0,[44]=16122.9,
		[45]=16038.3,[46]=15953.7,[47]=15869.2,[48]=15784.7,[49]=15699.1,
		[50]=15613.6,[51]=15527.7,[52]=15441.7,[53]=15355.7,[54]=15269.7,
		[55]=15183.7,[56]=15097.8,[57]=15011.8,[58]=14925.8,[59]=14840.2,
		[60]=14754.8,[61]=14669.5,[62]=14584.4,[63]=14498.5,[64]=14412.6,
		[65]=14326.4,[66]=14240.3,[67]=14154.1,[68]=14067.9,[69]=13981.7,
		[70]=13895.6,[71]=13809.4,[72]=13724.0,[73]=13638.1,[74]=13552.4,
		[75]=13466.3,[76]=13380.5,[77]=13294.3,[78]=13208.1,[79]=13122.0,
		[80]=13035.8,[81]=12949.6,[82]=12863.5,[83]=12777.3,[84]=12691.1,
		[85]=12604.9,[86]=12518.7,[87]=12432.6,[88]=12346.4,[89]=12260.2,
		[90]=12174.0,[91]=12087.9,[92]=12001.7,[93]=11915.5,[94]=11829.3,
		[95]=11743.2,[96]=11657.0,[97]=11570.8,[98]=11484.6,[99]=11398.5,
		[100]=11312.3,[101]=11226.1,[102]=11139.9,[103]=11053.8,[104]=10967.6,
		[105]=10881.4,[106]=10795.2,[107]=10709.1,[108]=10622.9,[109]=10536.7,
		[110]=10450.9,[111]=10365.4,[112]=10280.0,[113]=10193.9,[114]=10107.7,
		[115]=10021.5,[116]=9935.3,[117]=9849.2,[118]=9763.0,[119]=9677.6,
		[120]=9592.3,[121]=9507.7,[122]=9423.7,[123]=9337.5,[124]=9251.3,
		[125]=9165.2,[126]=9079.0,[127]=8992.8,[128]=8906.6,[129]=8820.4,
		[130]=8734.3,[131]=8648.1,[132]=8561.9,[133]=8475.7,[134]=8389.6,
		[135]=8303.4,[136]=8217.2,[137]=8131.0,[138]=8044.9,[139]=7958.7,
		[140]=7872.5,[141]=7786.3,[142]=7700.2,[143]=7614.0,[144]=7527.8,
		[145]=7441.6,[146]=7355.5,[147]=7269.3,[148]=7183.1,[149]=7096.9,
		[150]=7010.8,[151]=6924.6,[152]=6838.4,[153]=6752.2,[154]=6666.1,
		[155]=6580.1,[156]=6494.0,[157]=6407.9,[158]=6321.8,[159]=6235.6,
		[160]=6149.5,[161]=6063.4,[162]=5977.2,[163]=5891.0,[164]=5804.9,
		[165]=5718.7,[166]=5632.5,[167]=5546.3,[168]=5460.2,[169]=5374.0,
		[170]=5288.1,[171]=5201.9,[172]=5115.8,[173]=5029.7,[174]=4943.5,
		[175]=4857.3,[176]=4771.5,[177]=4685.0,[178]=4598.8,[179]=4512.6,
		[180]=4444.4,[181]=4340.3,[182]=4254.1,[183]=4167.9,[184]=4081.8,
		[185]=3995.6,[186]=3909.4,[187]=3823.2,[188]=3737.1,[189]=3651.8,
		[190]=3566.7,[191]=3481.9,[192]=3397.0,[193]=3312.1,[194]=3227.3,
		[195]=3142.4,[196]=3057.5,[197]=2972.7,[198]=2887.3,[199]=2801.9,
		[200]=2717.0,[201]=2632.1,[202]=2547.3,[203]=2462.4,[204]=2377.5,
		[205]=2292.7,[206]=2207.8,[207]=2122.9,[208]=2038.1,[209]=1953.2,
		[210]=1868.3,[211]=1783.5,[212]=1698.6,[213]=1613.8,[214]=1528.3,
		[215]=1442.4,[216]=1356.2,[217]=1270.0,[218]=1183.9,[219]=1097.7,
		[220]=1011.5,[221]=925.3,[222]=839.2,[223]=753.0,[224]=666.8,
		[225]=580.6,[226]=494.5,[227]=408.3,[228]=322.1,[229]=235.9,
		[230]=149.8,[231]=63.6,[232]=-22.6,[233]=-108.4,[234]=-193.5,
		[235]=-277.5,[236]=-361.1,[237]=-444.7,[238]=-528.3,[239]=-612.0,
		[240]=-695.6,[241]=-779.2,[242]=-862.8,[243]=-946.4,[244]=-1030.0,
		[245]=-1113.7,[246]=-1197.3,[247]=-1280.9,[248]=-1364.5,[249]=-1448.3,
		[250]=-1532.9,[251]=-1618.1,[252]=-1703.8,[253]=-1789.7,[254]=-1875.9,
		[255]=-1961.5,[256]=-2046.5,[257]=-2131.1,[258]=-2215.2,[259]=-2301.4,
		[260]=-2387.6,[261]=-2473.8,[262]=-2559.9,[263]=-2646.1,[264]=-2732.3,
		[265]=-2818.5,[266]=-2904.6,[267]=-2990.8,[268]=-3077.0,[269]=-3163.2,
		[270]=-3249.3,[271]=-3335.5,[272]=-3421.7,[273]=-3507.9,
	},
	Put2 = {
		[0]=-3443.0,[1]=-3356.9,[2]=-3270.7,[3]=-3184.5,[4]=-3098.3,
		[5]=-3012.1,[6]=-2926.0,[7]=-2839.8,[8]=-2753.6,[9]=-2667.4,
		[10]=-2581.3,[11]=-2495.1,[12]=-2408.9,[13]=-2322.7,[14]=-2236.6,
		[15]=-2150.4,[16]=-2064.2,[17]=-1978.0,[18]=-1891.9,[19]=-1805.7,
		[20]=-1719.6,[21]=-1633.9,[22]=-1548.5,[23]=-1464.2,[24]=-1380.1,
		[25]=-1296.5,[26]=-1212.8,[27]=-1129.2,[28]=-1045.6,[29]=-962.0,
		[30]=-878.4,[31]=-794.8,[32]=-711.1,[33]=-627.5,[34]=-543.9,
		[35]=-460.3,[36]=-376.5,[37]=-291.7,[38]=-206.2,[39]=-120.2,
		[40]=-34.1,[41]=52.0,[42]=138.2,[43]=224.4,[44]=310.6,
		[45]=396.7,[46]=482.9,[47]=569.1,[48]=655.3,[49]=741.4,
		[50]=827.6,[51]=913.8,[52]=1000.0,[53]=1086.1,[54]=1172.3,
		[55]=1258.5,[56]=1344.7,[57]=1430.9,[58]=1517.0,[59]=1603.2,
		[60]=1689.4,[61]=1774.8,[62]=1859.6,[63]=1944.5,[64]=2029.3,
		[65]=2114.2,[66]=2199.1,[67]=2283.9,[68]=2368.8,[69]=2453.7,
		[70]=2538.5,[71]=2623.4,[72]=2708.3,[73]=2793.1,[74]=2878.0,
		[75]=2962.9,[76]=3047.7,[77]=3132.6,[78]=3217.5,[79]=3302.3,
		[80]=3387.2,[81]=3472.1,[82]=3556.9,[83]=3641.8,[84]=3726.2,
		[85]=3812.4,[86]=3898.5,[87]=3984.7,[88]=4070.9,[89]=4157.1,
		[90]=4243.2,[91]=4329.4,[92]=4415.6,[93]=4501.8,[94]=4590.2,
		[95]=4674.1,[97]=4802.6,[98]=4932.5,[99]=5018.7,[100]=5104.9,
		[101]=5191.0,[102]=5277.2,[103]=5363.4,[104]=5449.6,[105]=5535.7,
		[106]=5621.9,[107]=5708.1,[108]=5794.3,[109]=5880.5,[110]=5966.6,
		[111]=6052.8,[112]=6139.0,[113]=6225.2,[114]=6311.2,[115]=6397.2,
		[116]=6483.2,[117]=6569.1,[118]=6655.1,[119]=6741.3,[120]=6827.5,
		[121]=6913.6,[122]=6999.6,[123]=7085.8,[124]=7171.9,[125]=7258.0,
		[126]=7344.0,[127]=7430.0,[128]=7516.1,[129]=7602.1,[130]=7688.1,
		[131]=7774.3,[132]=7860.4,[133]=7946.5,[134]=8032.5,[135]=8118.6,
		[136]=8204.7,[137]=8290.8,[138]=8376.9,[139]=8463.0,[140]=8549.1,
		[141]=8635.1,[142]=8721.1,[143]=8807.2,[144]=8893.2,[145]=8979.2,
		[146]=9065.2,[147]=9151.2,[148]=9237.3,[149]=9323.3,[150]=9409.2,
		[151]=9495.4,[152]=9581.6,[153]=9667.8,[154]=9753.9,[155]=9840.1,
		[156]=9926.3,[157]=10012.5,[158]=10098.7,[159]=10184.8,[160]=10271.0,
		[161]=10357.2,[162]=10443.4,[163]=10529.5,[164]=10615.7,[165]=10701.9,
		[166]=10788.1,[167]=10874.2,[168]=10960.4,[169]=11046.6,[170]=11132.8,
		[171]=11218.9,[172]=11305.1,[173]=11391.3,[174]=11477.5,[175]=11563.6,
		[176]=11649.8,[177]=11736.0,[178]=11822.2,[179]=11908.3,[180]=11994.5,
		[181]=12080.7,[182]=12166.9,[183]=12253.0,[184]=12339.2,[185]=12425.4,
		[186]=12511.6,[187]=12597.8,[188]=12683.9,[189]=12770.1,[190]=12856.3,
		[191]=12942.5,[192]=13028.6,[193]=13114.8,[194]=13201.0,[195]=13287.0,
		[196]=13373.2,[197]=13459.4,[198]=13545.5,[199]=13631.7,[200]=13717.9,
		[201]=13804.0,[202]=13890.2,[203]=13976.2,[204]=14062.4,[205]=14148.6,
		[206]=14234.8,[207]=14320.9,[208]=14407.1,[209]=14493.3,[210]=14579.5,
		[211]=14664.9,[212]=14750.3,[213]=14835.8,[214]=14921.7,[215]=15007.7,
		[216]=15093.6,[217]=15179.6,[218]=15265.6,[219]=15351.6,[220]=15437.0,
		[221]=15521.9,[222]=15606.2,[223]=15690.7,[224]=15775.2,[225]=15859.7,
		[226]=15944.2,[227]=16028.7,[228]=16113.2,[229]=16198.4,[230]=16283.8,
		[231]=16369.7,[232]=16455.4,[233]=16540.7,[234]=16625.2,[235]=16709.6,
		[236]=16793.9,[237]=16878.3,[238]=16878.3,[239]=16960.7,[240]=17043.8,
		[241]=17127.0,[242]=17210.2,[243]=17293.4,[244]=17376.6,[245]=17459.8,
		[246]=17542.9,[247]=17626.1,[248]=17709.3,[249]=17792.5,[250]=17875.7,
		[251]=17958.9,[252]=18042.0,[253]=18124.6,[254]=18207.6,[255]=18290.6,
		[256]=18373.6,[257]=18453.6,[258]=18536.6,[259]=18620.1,[260]=18703.8,
		[261]=18789.3,[262]=18874.8,[263]=18959.9,[264]=19044.5,[265]=19126.4,
		[266]=19206.3,[267]=19285.8,[268]=19365.4,[269]=19445.1,[270]=19524.8,
		[271]=19604.5,[272]=19684.1,[273]=19763.8,
	},
}

-- ═══════════════════════════════════════════════════════════════
-- ЗМІННІ
-- ═══════════════════════════════════════════════════════════════

local dispatcherGui = nil
local mapCanvas = nil
local panOffset = Vector2.new(0, 0)
local isDragging = false
local lastMousePos = Vector2.new(0, 0)
local isDispatcher = false

local stationFrames = {}
local trainFrames = {}
local lineFrames = {}
local currentTrainInfo = nil

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦІЇ
-- ═══════════════════════════════════════════════════════════════

local function hideRobloxUI()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	end)
end

local function showRobloxUI()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	end)
end

local function zToScreenX(z, width)
	local range = MAP_CONFIG.maxZ - MAP_CONFIG.minZ
	local normalized = (z - MAP_CONFIG.minZ) / range
	return normalized * width * MAP_CONFIG.scale
end

local function getScreenY(putName, height)
	return (putName == "Put1" and MAP_CONFIG.Put1_Y or MAP_CONFIG.Put2_Y) * height
end

local function updateTrains(width, height, centerOffset)
	for _, frame in pairs(trainFrames) do
		frame.Visible = false
	end

	if not currentTrainInfo then return end

	for putName, trains in pairs(currentTrainInfo) do
		for trainId, info in pairs(trains) do
			if info.head then
				local z = DETECTOR_Z[putName] and DETECTOR_Z[putName][info.head]
				if z then
					local key = putName .. "_" .. trainId
					local frame = trainFrames[key]

					if not frame then
						frame = Instance.new("Frame")
						frame.Name = key
						frame.Size = UDim2.new(0, 20, 0, 20)
						frame.BackgroundColor3 = COLORS.Train
						frame.BorderSizePixel = 0
						frame.ZIndex = 20
						frame.Parent = mapCanvas

						local corner = Instance.new("UICorner")
						corner.CornerRadius = UDim.new(0, 5)
						corner.Parent = frame

						local stroke = Instance.new("UIStroke")
						stroke.Color = Color3.fromRGB(200, 150, 0)
						stroke.Thickness = 2
						stroke.Parent = frame

						local icon = Instance.new("TextLabel")
						icon.Name = "Icon"
						icon.Size = UDim2.new(1, 0, 1, 0)
						icon.BackgroundTransparency = 1
						icon.Text = "🚃"
						icon.TextSize = 12
						icon.ZIndex = 21
						icon.Parent = frame

						local label = Instance.new("TextLabel")
						label.Name = "Driver"
						label.Size = UDim2.new(0, 110, 0, 20)
						label.Position = UDim2.new(0.5, -55, 0, -26)
						label.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
						label.BackgroundTransparency = 0.1
						label.TextColor3 = COLORS.Text
						label.TextSize = 11
						label.Font = Enum.Font.SourceSansBold
						label.ZIndex = 21
						label.Parent = frame

						local labelCorner = Instance.new("UICorner")
						labelCorner.CornerRadius = UDim.new(0, 5)
						labelCorner.Parent = label

						local labelStroke = Instance.new("UIStroke")
						labelStroke.Color = Color3.fromRGB(70, 75, 85)
						labelStroke.Parent = label

						trainFrames[key] = frame
					end

					local screenX = zToScreenX(z, width) + panOffset.X - centerOffset
					local screenY = getScreenY(putName, height)
					frame.Position = UDim2.new(0, screenX - 10, 0, screenY - 10)
					frame.Visible = true

					local driverLabel = frame:FindFirstChild("Driver")
					if driverLabel then
						driverLabel.Text = info.driver and ("🚂 " .. info.driver) or "🚂 ---"
					end
				end
			end
		end
	end
end

local function updateMap()
	if not mapCanvas then return end

	local width = mapCanvas.AbsoluteSize.X
	local height = mapCanvas.AbsoluteSize.Y
	local centerOffset = (width * MAP_CONFIG.scale - width) / 2

	-- Оновити лінії
	for _, line in ipairs(lineFrames) do
		local putName = line:GetAttribute("PutName")
		local screenY = getScreenY(putName, height)
		line.Size = UDim2.new(0, width * MAP_CONFIG.scale, 0, 6)
		line.Position = UDim2.new(0, panOffset.X - centerOffset, 0, screenY - 3)
	end

	-- Оновити станції
	for _, frame in ipairs(stationFrames) do
		local putName = frame:GetAttribute("PutName")
		local idx = frame:GetAttribute("DetectorIdx")
		local z = DETECTOR_Z[putName] and DETECTOR_Z[putName][idx]

		if z then
			local screenX = zToScreenX(z, width) + panOffset.X - centerOffset
			local screenY = getScreenY(putName, height)
			frame.Position = UDim2.new(0, screenX - 10, 0, screenY - 10)
		end
	end

	-- Оновити поїзди
	updateTrains(width, height, centerOffset)
end

local function createMapGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DispatcherGUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.Parent = playerGui

	-- Контейнер
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundColor3 = COLORS.Background
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = gui

	-- Канвас
	mapCanvas = Instance.new("Frame")
	mapCanvas.Name = "Canvas"
	mapCanvas.Size = UDim2.new(1, 0, 1, 0)
	mapCanvas.BackgroundTransparency = 1
	mapCanvas.Parent = container

	-- Лінія Put1 (червона, зверху)
	local line1 = Instance.new("Frame")
	line1.Name = "Line1"
	line1.BackgroundColor3 = COLORS.Line1
	line1.BorderSizePixel = 0
	line1.ZIndex = 1
	line1:SetAttribute("PutName", "Put1")
	line1.Parent = mapCanvas
	table.insert(lineFrames, line1)

	-- Лінія Put2 (синя, знизу)
	local line2 = Instance.new("Frame")
	line2.Name = "Line2"
	line2.BackgroundColor3 = COLORS.Line2
	line2.BorderSizePixel = 0
	line2.ZIndex = 1
	line2:SetAttribute("PutName", "Put2")
	line2.Parent = mapCanvas
	table.insert(lineFrames, line2)

	-- Станції
	for putName, stations in pairs(STATIONS) do
		local color = putName == "Put1" and COLORS.Line1 or COLORS.Line2
		local labelPos = putName == "Put1" and "top" or "bottom"  -- Put1 зверху - підпис зверху

		for _, station in ipairs(stations) do
			local frame = Instance.new("Frame")
			frame.Name = station.name
			frame.Size = UDim2.new(0, 20, 0, 20)
			frame.BackgroundColor3 = COLORS.Station
			frame.BorderSizePixel = 0
			frame.ZIndex = 10
			frame:SetAttribute("PutName", putName)
			frame:SetAttribute("DetectorIdx", station.idx)
			frame.Parent = mapCanvas

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = color
			stroke.Thickness = 3
			stroke.Parent = frame

			local dot = Instance.new("Frame")
			dot.Name = "Dot"
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0.5, -4, 0.5, -4)
			dot.BackgroundColor3 = color
			dot.ZIndex = 11
			dot.Parent = frame

			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = dot

			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(0, 100, 0, 18)
			label.BackgroundTransparency = 1
			label.Text = station.name
			label.TextColor3 = COLORS.Text
			label.TextSize = 12
			label.Font = Enum.Font.SourceSansBold
			label.ZIndex = 12
			label.Parent = frame

			if labelPos == "top" then
				label.Position = UDim2.new(0.5, -50, 0, -24)
			else
				label.Position = UDim2.new(0.5, -50, 1, 6)
			end

			table.insert(stationFrames, frame)
		end
	end

	-- Панель керування
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 200, 0, 95)
	panel.Position = UDim2.new(1, -210, 0, 10)
	panel.BackgroundColor3 = COLORS.Panel
	panel.BorderSizePixel = 0
	panel.ZIndex = 50
	panel.Parent = gui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(60, 65, 75)
	panelStroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 28)
	title.BackgroundTransparency = 1
	title.Text = "🚇 Диспетчерська"
	title.TextColor3 = COLORS.Text
	title.TextSize = 14
	title.Font = Enum.Font.SourceSansBold
	title.ZIndex = 51
	title.Parent = panel

	local resetBtn = Instance.new("TextButton")
	resetBtn.Name = "ResetBtn"
	resetBtn.Size = UDim2.new(0, 180, 0, 28)
	resetBtn.Position = UDim2.new(0, 10, 0, 30)
	resetBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
	resetBtn.Text = "🔄 Центрувати"
	resetBtn.TextColor3 = COLORS.Text
	resetBtn.TextSize = 12
	resetBtn.Font = Enum.Font.SourceSansBold
	resetBtn.ZIndex = 51
	resetBtn.Parent = panel

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = resetBtn

	-- Легенда
	local leg1 = Instance.new("Frame")
	leg1.Size = UDim2.new(0, 18, 0, 5)
	leg1.Position = UDim2.new(0, 10, 0, 70)
	leg1.BackgroundColor3 = COLORS.Line1
	leg1.ZIndex = 51
	leg1.Parent = panel

	local leg1Corner = Instance.new("UICorner")
	leg1Corner.CornerRadius = UDim.new(0, 2)
	leg1Corner.Parent = leg1

	local leg1Text = Instance.new("TextLabel")
	leg1Text.Size = UDim2.new(0, 55, 0, 14)
	leg1Text.Position = UDim2.new(0, 30, 0, 65)
	leg1Text.BackgroundTransparency = 1
	leg1Text.Text = "← Путь 1"
	leg1Text.TextColor3 = COLORS.Text
	leg1Text.TextSize = 10
	leg1Text.Font = Enum.Font.SourceSans
	leg1Text.TextXAlignment = Enum.TextXAlignment.Left
	leg1Text.ZIndex = 51
	leg1Text.Parent = panel

	local leg2 = Instance.new("Frame")
	leg2.Size = UDim2.new(0, 18, 0, 5)
	leg2.Position = UDim2.new(0, 100, 0, 70)
	leg2.BackgroundColor3 = COLORS.Line2
	leg2.ZIndex = 51
	leg2.Parent = panel

	local leg2Corner = Instance.new("UICorner")
	leg2Corner.CornerRadius = UDim.new(0, 2)
	leg2Corner.Parent = leg2

	local leg2Text = Instance.new("TextLabel")
	leg2Text.Size = UDim2.new(0, 55, 0, 14)
	leg2Text.Position = UDim2.new(0, 120, 0, 65)
	leg2Text.BackgroundTransparency = 1
	leg2Text.Text = "Путь 2 →"
	leg2Text.TextColor3 = COLORS.Text
	leg2Text.TextSize = 10
	leg2Text.Font = Enum.Font.SourceSans
	leg2Text.TextXAlignment = Enum.TextXAlignment.Left
	leg2Text.ZIndex = 51
	leg2Text.Parent = panel

	-- Події
	resetBtn.MouseButton1Click:Connect(function()
		panOffset = Vector2.new(0, 0)
		updateMap()
	end)

	container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	container.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	container.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
			local currentPos = Vector2.new(input.Position.X, input.Position.Y)
			local delta = currentPos - lastMousePos
			panOffset = panOffset + Vector2.new(delta.X, 0)
			lastMousePos = currentPos
			updateMap()
		end
	end)

	return gui
end

-- ═══════════════════════════════════════════════════════════════
-- ПОДІЇ
-- ═══════════════════════════════════════════════════════════════

OpenGUI.OnClientEvent:Connect(function(states, trainInfo)
	isDispatcher = true
	hideRobloxUI()
	currentTrainInfo = trainInfo

	if not dispatcherGui then
		dispatcherGui = createMapGUI()
	end

	dispatcherGui.Enabled = true
	task.delay(0.1, updateMap)
end)

CloseGUI.OnClientEvent:Connect(function()
	isDispatcher = false
	showRobloxUI()

	if dispatcherGui then
		dispatcherGui.Enabled = false
	end
end)

UpdateDetectors.OnClientEvent:Connect(function(states, trainInfo)
	if isDispatcher then
		currentTrainInfo = trainInfo
		updateMap()
	end
end)

print("[Dispatcher] Client RELEASE v1.0 Loaded")