------------------------------------
-- @name    MangaSee
-- @url     https://mangasee123.com/
-- @author  alperen and luevano (https://github.com/luevano)
-- @license MIT
------------------------------------


---VSCode specific for the lua extension
---@diagnostic disable: duplicate-doc-alias
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
HttpUtil = require("http_util")
Headless = require("headless")
Strings = require("strings")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Base = "https://mangasee123.com"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	Page:navigate(Base .. "/search/?name=" .. HttpUtil.query_escape(query))
	Page:waitLoad()
	local doc = Html.parse(Page:html())

	local mangas = {}
	doc:find(".top-15.ng-scope"):each(function(i, s)
		mangas[i + 1] = {name = s:find('.SeriesName[ng-bind-html="Series.s"]'):first():text(),
					   url = Base .. s:find('.SeriesName[ng-bind-html="Series.s"]'):first():attr("href")}
	end)

	return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	Page:navigate(mangaURL)
	Page:waitLoad()
	if Page:has('.ShowAllChapters') == true then
		Page:element('.ShowAllChapters'):click()
	end
	local doc = Html.parse(Page:html())

	local chapters = {}
	doc:find(".ChapterLink"):each(function(i, s)
		local name = s:find('span'):first():text()
		name = Strings.trim(name:gsub("[\r\t\n]+", " "), " ")
		chapters[i + 1]= {name = name, url = Base .. s:attr("href")}
	end)
	Reverse(chapters)

	return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	Page:navigate(chapterURL)
	Page:waitLoad()
	Page:element('.DesktopNav > div > div:nth-child(4) > button'):click()
	local doc = Html.parse(Page:html())

	local pages = {}
	local images = {}
	doc:find('.img-fluid'):each(function(i, s)
		images[i + 1] = tostring(s:attr('src'))
	end)

	local modal = doc:find("#PageModal"):first()
	modal:find('button[ng-click="vm.GoToPage(Page)"]'):each(function(_, s)
		local index = tonumber(Strings.trim(s:text():gsub("[\r\t\n]+", " "), " "))
		if index ~= nil then
			pages[index] = {index = index, url = images[index]}
		end
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
