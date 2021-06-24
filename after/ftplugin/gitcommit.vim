setlocal completefunc=gitmoji#complete
setlocal omnifunc=gitmoji#complete

function s:warn(...)
  echohl WarningMsg
  echomsg "gitmoji.vim: " a:000->join()
  echohl None
endfunction

let s:builtins = gitmoji#builtins()
let s:aliases = gitmoji#aliases()

if g:gitmoji_abbreviations && g:gitmoji_insert_emoji
  for [name, gitmoji] in s:builtins->items()
    execute 'iabbrev' gitmoji.code gitmoji.emoji
  endfor
  for [name, gitmoji] in s:aliases->items()
    let code = printf(":%s:", name)
    execute 'iabbrev' code gitmoji.emoji
  endfor
endif
