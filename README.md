# Mangal Scrapers

This is a collection of custom lua scrapers for [mangal](https://github.com/metafates/mangal).

To browse and install run:

```sh
mangal sources install
```

To change sources repository information:

```sh
mangal config set -k installer.<key> -v <value>
```

Where `<key>` can be `branch`, `repo` or `user`. To use this repo (luevano/mangal-scrapers) as source just change `user` config to `luevano`:

```sh
mangal config set -k installer.user -v "luevano"
```

# Contribute

You can use `mangal sources gen --name "..." --url "..."` to create a template for the new scraper.

Available modules are from [mangal-lua-libs](https://github.com/metafates/mangal-lua-libs).

## Scrapers

- [Asura Scans](scrapers/AsuraScans.lua)
- [ComicK](scrapers/ComicK.lua)
- [Luminous Scans](scrapers/LuminousScans.lua)
- [Mangasee](scrapers/Mangasee.lua)
- [Readmanga](scrapers/Readmanga.lua)
- [Flame Scans](scrapers/FlameScans.lua)
- [ScansManga](scrapers/ScansManga.lua)
