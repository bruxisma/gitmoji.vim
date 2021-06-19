setlocal completefunc=gitmoji#complete
setlocal omnifunc=gitmoji#complete

if g:gitmoji_abbreviations && g:gitmoji_insert_emoji
  for [name, gitmoji] in gitmoji#builtins()->items()
    execute 'iabbrev' gitmoji.code gitmoji.emoji
  endfor
endif
