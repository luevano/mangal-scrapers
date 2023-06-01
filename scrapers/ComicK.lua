------------------------------
-- @name    ComicK 
-- @url     https://comick.fun
-- @author  Sravan Balaji and luevano (https://github.com/luevano)
-- @license MIT
------------------------------


---VSCode specific for the lua extension
---@diagnostic disable: duplicate-doc-alias
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
HttpUtil = require("http_util")
Headless = require("headless")
Json = require("json")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
ApiBase = "https://api.comick.fun"
ImageBase = "https://meo.comick.pictures"
AddGroupName = false
Limit = 50
Lang = "en" -- en, fr, etc
Order = 1 -- 0 = desc, 1 = asc
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	Page:navigate(ApiBase .. "/v1.0/search/?q=" .. HttpUtil.query_escape(query))
	Page:waitLoad()
	local mangas = {}

	local response_json = Json.decode(Page:element("pre"):text())
	for i, json in pairs(response_json) do
		local title = json["title"]

		if title ~= nil then
			local hid = json["hid"]
			local manga = {name = title,
					       url = ApiBase .. "/comic/" .. tostring(hid)}

			mangas[i + 1] = manga
		end
	end

	return mangas
end

--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	local reqURL = mangaURL .. "/chapters" .. "?lang=" .. Lang .. "&limit=" .. Limit .. "&chap-order=" .. Order
	Page:navigate(reqURL)
	Page:waitLoad()
	local chapters = {}
	local i = 1

	-- Need to scrape by chunks
	local numChapters = Json.decode(Page:element("pre"):text())["total"]
	local numPages = math.ceil(numChapters / Limit)
	for j = 1, numPages do
		Page:navigate(reqURL .. "&page=" .. j)
		Page:waitLoad()
		local responseJson = Json.decode(Page:element("pre"):text())

		for _, json in pairs(responseJson["chapters"]) do
			local hid = json["hid"]
			local num = json["chap"]

			if num == nil then
				num = 0
			end

			local volume = tostring(json["vol"])
			if volume ~= "nil" then
				volume = "Vol." .. volume
			else
				volume = ""
			end
			local title = json["title"]
			local chap = "Chapter " .. tostring(num)
			local groupName = json["group_name"]

			if title then
				chap = chap .. ": " .. tostring(title)
			end

			if (AddGroupName and groupName) then
				chap = chap .. " ["
				for key, group in pairs(groupName) do
					if key ~= 1 then
						chap = chap .. ", "
					end
					chap = chap .. tostring(group)
				end
				chap = chap .. "]"
			end

			local chapter = {name = chap,
							 volume = volume,
							 url = ApiBase .. "/chapter/" .. tostring(hid)}

			chapters[i] = chapter
			i = i + 1
		end
	end

	return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	Page:navigate(chapterURL)
	Page:waitLoad()
	local pages = {}

	local response_json = Json.decode(Page:element("pre"):text())

	for i, json in pairs(response_json["chapter"]["md_images"]) do
		local page = {index = i,
					  url = ImageBase .. "/" .. json["b2key"]}

		pages[i + 1] = page
	end

	return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
