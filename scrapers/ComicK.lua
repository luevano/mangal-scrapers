------------------------------
-- @name    ComicK 
-- @url     https://comick.fun
-- @author  david 
-- @license MIT
------------------------------


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
ApiBase = "https://api.comick.fun"
ImageBase = "https://meo.comick.pictures"
Limit = 50
Lang = "en" -- en, fr, etc
Order = 1 -- 0 = desc, 1 = asc
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	local page = Browser:page()
	page:navigate(ApiBase .. "/v1.0/search/?q=" .. HttpUtil.query_escape(query))
	page:waitLoad()
	local mangas = {}
	local i = 1

	local response_json = Json.decode(page:element("pre"):text())
	for _, json in pairs(response_json) do
		local title = json["title"]

		if title ~= nil then
			local hid = json["hid"]
			manga = {name = title,
					 url = ApiBase .. "/comic/" .. tostring(hid)}

			mangas[i] = manga
			i = i + 1
		end
	end

	return mangas
end

--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	local page = Browser:page()
	local reqURL = mangaURL .. "/chapters" .. "?lang=" .. Lang .. "&limit=" .. Limit .. "&chap-order=" .. Order
	page:navigate(reqURL)
	page:waitLoad()
	local chapters = {}
	local i = 1

	-- Need to scrape by chunks
	local num_chapters = Json.decode(page:element("pre"):text())["total"]
	local num_pages = math.ceil(num_chapters / Limit)
	for j = 1, num_pages do
		page:navigate(reqURL .. "&page=" .. j)
		page:waitLoad()
		local response_json = Json.decode(page:element("pre"):text())

		for _, json in pairs(response_json["chapters"]) do
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
			local group_name = json["group_name"]

			if title then
				chap = chap .. ": " .. tostring(title)
			end

			if group_name then
				chap = chap .. " ["
				for key, group in pairs(group_name) do
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
	local page = Browser:page()
	page:navigate(chapterURL)
	page:waitLoad()
	local pages = {}
	local i = 1

	local response_json = Json.decode(page:element("pre"):text())

	for i, json in pairs(response_json["chapter"]["md_images"]) do
		local page = {index = i,
					  url = ImageBase .. "/" .. json["b2key"]}

		pages[i] = page
		i = i + 1
	end

	return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
