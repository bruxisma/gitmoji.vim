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
    for alias in s:aliases->get(name, [])
      " NOTE: For some reason not assigning this to a variable before use
      " results in an invalid argument error, with no additional information :/
      let code = printf(":%s:", alias)
      execute 'iabbrev' code gitmoji.emoji
    endfor
  endfor
endif
