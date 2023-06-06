# What is this?

This is a script for mpv player, allowing you to watch videos from pvashow.org site right in `mpv`, instead of browser.

# How to install?

Clone this repo to `~/.config/mpv/scripts` (on Linux, or corresponding path to scripts directory for other OS'es, that uses another paths)

(currently, no distributions provide system-wide packages, and most probably never will)

# How to use?

```
$ mpv https://pvashow.org/<title_name>.html
```

If all the thing will work as expected, you will see that `mpv` will start to play 1st episode of the seleted title, and there will also be preloaded playlist with other episodes of the title.


By default, plugin chooses files for 720p resolution.

If you want to choose another resolution (most of the time there is only 1080p and 360p available in addition to 720p, so for now plugin only supports them), you can declare that by adding `###q=<res>` (where `<res` is the resolution you need) to the end of link

```
$ mpv 'https://pvashow.org/<title_name>.html###q=1080p'
$ mpv 'https://pvashow.org/<title_name>.html###q=720p'
$ mpv 'https://pvashow.org/<title_name>.html###q=360p'

```

If you want to start from episode, different that 1, you can add `###ep=<num>` (where `<num>` is the number of episode you need) to the en of link.

```
$ mpv 'https://pvashow.org/<title_name>.html###ep=123'

```

Also, you can combine that settings:

```
$ mpv 'https://pvashow.org/<title_name>.html###q=360p###ep=123'

```
