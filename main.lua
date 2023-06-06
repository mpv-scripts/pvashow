-- luacheck: globals mp
-- local i=require"inspect"
local msg = require "mp.msg"
local function fetch(url,opts)
  local luacurl_available, cURL = pcall(require,'cURL')
  if luacurl_available then
    local buf = {}
    local o = opts or {} -- luacheck: ignore
    -- local UA = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/111.0"
    local UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    local c = cURL.easy_init()
    local headers = {
      "Accept: */*",
      -- "Accept-Language: ru,en",
      -- "Accept-Charset: utf-8,cp1251,koi8-r,iso-8859-5,*",
      "Cache-Control: no-cache",
      -- "Origin: https://pvashow.org",
      -- ("Referer: %s"):format(o.ref or "https://pvashow.org/"),
    }
    c:setopt_httpheader(headers)
    c:setopt_followlocation(1)
    c:setopt_header(1)
    c:setopt_useragent(UA)
    -- c:setopt_cookiejar(o.cookie or "/tmp/mpv.pvashow.cookies")
    -- c:setopt_cookiefile(o.cookie or "/tmp/mpv.pvashow.cookies")
    c:setopt_url(url)
    c:setopt_writefunction(function(chunk) table.insert(buf,chunk); return true; end)
    c:perform()
    -- print(i(buf))
    return table.concat(buf)
  else
    msg.error"Sorry, I need Lua-cURL (https://github.com/Lua-cURL/Lua-cURLv3) for work."
    msg.error"Please, install it using system package manager or any other method"
    msg.error"The goal is that Lua interpreter that mpv was built with should be able to find it"
  end
end

local function pvaCheck()
  local path = mp.get_property("path", "")
  -- local path = mp.get_property("stream-open-filename", "")
  if path:match("^(%a+://pvashow.org/.*)") then
    msg.verbose[[Hello! pvashow.org link detected.]]
    local o -- luacheck: ignore

    local req_o = {}
    for k,v in path:gmatch[=[%#%#%#([^%=%#]+)%=([^%#]+)]=] do
      req_o[k] = v
    end
    path=path:gsub("###.+$","")

    local q = {
      ["1080p"] = "",
      ["720p"] = "_720p",
      ["360p"] = "_360p",
    }

    local page = fetch(path, o)
    -- local title = page:match[=[<meta property="og:title" content="([^"]+)">]=]
    local player_url = page:match[=[<iframe src="([^"]+)"]=]
    if player_url then
      if player_url:match"csst.online" then
        local player_src = fetch(player_url, o)
        local playlist = {"#EXTM3U"}
        local dups = {}

        local match_pattern = [=[%{"comment":[^"]+"([^"]+)","file":"[^"]+](https://[^,%[]*%d__PH__%.mp4)[",]]=]
        local ph = q[req_o.q] or "_720p"
        match_pattern = match_pattern:gsub("__PH__", ph)
        for title, url in player_src:gmatch(match_pattern) do
          if dups[url] then break end
          table.insert(playlist, ("#EXTINF:0,%s"):format(title))
          table.insert(playlist, url)
          dups[url] = true
        end
        if playlist and #playlist>0 then
          mp.set_property_number("playlist-start", req_o and req_o.ep and req_o.ep - 1 or 0)
          mp.set_property("stream-open-filename", ("memory://%s"):format(table.concat(playlist, "\n")))
        else
          msg.error[[Player was succesfully detected, but something gone wrong when we tried to get video URL. Please, report.]] -- luacheck: ignore
        end
      else
        msg.error[[Unknown player (don't know how to handle it). Please, report.]]
        msg.error(("Player URL is: %s"):format(player_url))
        os.exit(1)
      end
    end
  end
end

mp.add_hook("on_load", 10, pvaCheck)

