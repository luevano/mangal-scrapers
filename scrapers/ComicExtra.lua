-----------------------------------
-- @name    ComicExtra 
-- @url     https://comicextra.net/
-- @author  luevano (https://github.com/luevano)
-- @license MIT
-----------------------------------


---VSCode specific for the lua extension
---@diagnostic disable: duplicate-doc-alias
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Http = require("http")
Html = require("html")
HttpUtil = require("http_util")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
UrlBase = "https://comicextra.net"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	local request = Http.request("GET", UrlBase .. "/comic-search?key=" .. HttpUtil.query_escape(query))
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)

	local mangas = {}
	doc:find(".movie-list-index .cartoon-box"):each(function(i, s)
		local entry = s:find(".mb-right h3 a"):first()
		mangas[i + 1] = {name = entry:text(),
						 url = entry:attr("href")}
	end)

	return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	local request = Http.request("GET", mangaURL)
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)
	print(result.body)

	local chapters = {}
	doc:find(".episode-list #list tr"):each(function(i, s)
		local entry = s:find("td a"):first()
		print(entry:text())
		chapters[i + 1] = {name = entry:text(),
						   url = entry:attr("href")}
	end)
	Reverse(chapters)

	return chapters
end



--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	local request = Http.request("GET", chapterURL .. "/full")
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)
	local pages = {}
	doc:find(".chapter-container .chapter_img"):each(function(i, s)
		pages[i + 1] = {index = i,
						url = s:attr("src")}
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
