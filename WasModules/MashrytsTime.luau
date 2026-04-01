local MashrytLine = {
	["One_line"] = {
		["NachalStation"] = {},
		["KonechStation"] = {},
		["Stations"] = {}
	},
	["Two_line"] = {
		["NachalStation"] = {"Дустлик", "Серверний вокзал Ташкента", "Айбек", "Алишера Навої", "Бернули"},
		["KonechStation"] = {"Дустлик", "Серверний вокзал Ташкента", "Айбек", "Алишера Навої", "Бернули"},
		["Stations"] = {"Дустлик", "Машиностроительная", "Серверний вокзал Ташкента", "Айбек", "Площадь космонавтов", "Узбекистанская", "Алишера Навої", "Гафура Гуляма", "Чор-Су", "Тинчлик", "Бернули"}
	},
	["Three_line"] = {
		-- === СТАРА СИСТЕМА (з таймкодами) - для зворотної сумісності ===
		["SoundInformatorNachToKonech"] = "rbxassetid://124956916778903", -- Звук: Лісова -> Дніпро
		["SoundInformatorKonechToNach"] = "rbxassetid://115060019427765", -- Звук: Дніпро -> Лісова

		["NachalStation"] = {"Лісова", "Дніпро"},
		["KonechStation"] = {"Лісова", "Дніпро", "Дарниця"},
		["StationsByN"] = {"Лісова", "Чернігівська", "Дарниця", "Лівобережна", "Гідропарк", "Дніпро"},
		["MonitorKonechStation"] = {"Lisova", "Dnipro", "Darnytsia"},
		["MonitorStations"] = {"Лісова", "Чернігівська", "Дарниця", "Лівобережна", "Гідропарк", "Дніпро"},

		-- Таймкоди для руху Лісова -> Дніпро (SoundInformatorNachToKonech)
		["Stations"] = {
			["Чернігівська"] = { ["Next"] = 0,   ["Now"] = 20 },
			["Дарниця"]     = { ["Next"] = 40,  ["Now"] = 60 },
			["Лівобережна"] = { ["Next"] = 80,  ["Now"] = 100 },
			["Гідропарк"]   = { ["Next"] = 120, ["Now"] = 140 },
			["Дніпро"]      = { ["Next"] = 160 , ["Now"] = 180 },
		},

		-- Таймкоди для руху Дніпро -> Лісова (SoundInformatorKonechToNach)
		["StationsB"] = {
			["Гідропарк"]   = { ["Next"] = 0,   ["Now"] = 20 },
			["Лівобережна"] = { ["Next"] = 40,  ["Now"] = 60 },
			["Дарниця"]     = { ["Next"] = 80,  ["Now"] = 100 },
			["Чернігівська"] = { ["Next"] = 120, ["Now"] = 140 },
			["Лісова"]      = { ["Next"] = 160, ["Now"] = 180 }
		},

		-- === НОВА СИСТЕМА (окремі звуки) ===
		-- Звук закриття дверей (програється перед "Наступна станція...")
		["DoorsClosingSound"] = "rbxassetid://136244838052781",

		-- Звуки прибуття на станцію (Now)
		["StationSounds"] = {
			["Дніпро"] = "rbxassetid://133778007995750",
			["Гідропарк"] = "rbxassetid://114937293144132",
			["Лівобережна"] = "rbxassetid://76439070504719",
			["Дарниця"] = "rbxassetid://134969805534002",
			["Чернігівська"] = "rbxassetid://131483172567216",
			["Лісова"] = "rbxassetid://94585622232591"
		},

		-- Звуки "Наступна станція..." (Next)
		["NextStationSounds"] = {
			["Дніпро"] = "rbxassetid://98391552166495",
			["Гідропарк"] = "rbxassetid://106167753441896",
			["Лівобережна"] = "rbxassetid://127443630708231",
			["Дарниця"] = "rbxassetid://135520329501536",
			["Чернігівська"] = "rbxassetid://78227048279400",
			["Лісова"] = "rbxassetid://117836704040817"
		}
	},
	["Four_line"] = {
		["NachalStation"] = {},
		["KonechStation"] = {},
		["Stations"] = {}
	},
	["SSV_Mashryt_One_line"] = {
		["NachalStation"] = {},
		["KonechStation"] = {},
		["Stations"] = {}
	},
	["SSV_Mashryt_Two_line"] = {
		["NachalStation"] = {},
		["KonechStation"] = {},
		["Stations"] = {}
	},
	["SSV_Mashryt_Three_line"] = {
		["NachalStation"] = {},
		["KonechStation"] = {},
		["Stations"] = {}
	}
}

return MashrytLine