--------------------------
-- @name    ReadManga 
-- @url     https://readmanga.live/
-- @author  ts-vadim (https://github.com/ts-vadim)
-- @license MIT
--------------------------


---VSCode specific for the lua extension
---@diagnostic disable: duplicate-doc-alias
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
Http = require("http")
Time = require("time")
HttpUtil = require("http_util")
Inspect = require("inspect")
Strings = require("strings")
Json = require("json")
--- END IMPORTS ---


----- VARIABLES -----
Client = Http.client()
URL_BASE = "https://readmanga.live/"
--- END VARIABLES ---


----- MAIN -----
--- Searches for manga with given query. 
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
    local request = Http.request("POST", URL_BASE .. "search/?q=" .. HttpUtil.query_escape(query))
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)

    local mangas = {}
    local i = 1

    doc:find(".leftContent .tiles .tile .desc"):each(function(_, s)
        local url = s:find("h3 a"):attr("href")
        -- 1. There will be mangas from unrelated sources like mintmanga.live
        -- 2. Sometimes it will recieve broken entries with a link to an author (cause idk what im doing)
        if Strings.contains(url, "https://") or Strings.contains(url, "/list/person") then
            return
        end
        mangas[i] = {name = Strings.trim_space(s:find("h3"):text()),
                       url = URL_BASE .. Strings.trim(url, "/")}
        i = i + 1
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

    local chapters = {}
    doc:find(".chapters-link a.chapter-link"):each(function(i,s)
        chapters[i+1] = {
            name = Strings.trim_space(s:text()),
            url = URL_BASE .. Strings.trim(s:attr("href"), "/"),
        }
    end)

    Reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
    local request = Http.request("GET", chapterURL)
    local responseBody = Client:do_request(request).body
    -- For some reason image URLs are passed to readerInit() function in bare HTML
    -- with some other arguments. So I'm trying to get just the urls here.
    local jsonStart = responseBody:find("rm_h.readerInit%(")
    jsonStart = responseBody:find("%[", jsonStart)

    local s = responseBody:sub(jsonStart)
    s = s:sub(1, s:find("%)"))
    s = s:sub(1, #s - s:reverse():find("%]") + 1)
    s = "[" .. s:gsub("'", "\"") .. "]"
    local json, err = Json.decode(s)
    if err then
        error(err)
    end

    local pages = {}
    for i, v in ipairs(json[1]) do
        local url = v[1] .. v[3]
        url = url:sub(1, url:find("?") - 1)
        pages[i] = {
            url = url,
            index = i,
        }
    end

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
