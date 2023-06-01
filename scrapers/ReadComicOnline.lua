--------------------------------------
-- @name    ReadComicOnline 
-- @url     https://readcomiconline.li
-- @author  luevano (https://github.com/luevano)
-- @license MIT
--------------------------------------


---VSCode specific for the lua extension
---@diagnostic disable: duplicate-doc-alias
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Http = require("http")
Html = require("html")
HttpUtil = require("http_util")
Headless = require("headless")
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Client = Http:client()
UrlBase = "https://readcomiconline.li"
SearchWaitTime = 5
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	Page:navigate(UrlBase)
	Page:waitLoad()
	Page:element("input[name='keyword']"):input(query)
	Page:element("input[id='imgSearch']"):click()
	Page:waitLoad()
	Time.sleep(SearchWaitTime)
	local mangas = {}

	local doc = Html.parse(Page:html())
	doc:find(".list-comic > .item"):each(function (i, s)
		local manga = {name = Html.parse(s:attr("title")):find(".title"):text(),
					   url = UrlBase .. s:find("a"):first():attr("href")}
		mangas[i + 1] = manga
	end)

	return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	local request = Http.request("GET", mangaURL)
	local response = Client:do_request(request)
	local chapters = {}

	local doc = Html.parse(response.body)
		doc:find(".listing a"):each(function(i, s)
			local chapter = {name = s:text():gsub("^%s*(.-)%s*$", "%1"),
							 url = UrlBase .. s:attr("href")}
			chapters[i + 1] = chapter
	end)

	Reverse(chapters)
	return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	Page:navigate(chapterURL .. "&quality=hq&readType=1")
	Page:waitLoad()
	local pages = {}

	local doc = Html.parse(Page:html())
	doc:find("div[id='divImage'] p"):each(function(i, s)
		local page = {index = i,
					  url = s:find("img"):first():attr("src")}

		pages[i + 1] = page
	end)

	return pages
end

--- END MAIN ---




----- HELPERS -----
function Reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
end
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
