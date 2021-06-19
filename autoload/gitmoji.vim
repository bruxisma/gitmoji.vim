if exists('g:gitmoji_autoload_script') | finish | endif
let g:gitmoji = 1

let s:directory = expand('<sfile>:p')->resolve()->fnamemodify(':h')

function s:compare(lhs, rhs)
  if a:lhs.name == a:rhs.name
    return 0
  elseif a:lhs.name < a:rhs.name
    return -1
  endif
  return 1
endfunction

function s:readjson(filename)
  return a:filename->readfile()->join()->json_decode()
endfunction

function s:findlocal(filename)
  return findfile(a:filename, s:directory)
endfunction

" There needs to be a better way to handle this
" TODO: We need to provide a separate way for users to define their aliases
" where kind: is set to *not* gitmoji, but 'user', or 'plugin'
" TODO: Look into applying iabbrev(s) during the CompleteDonePre or
" CompleteDone event.
function s:create(idx, name)
  let gitmoji = s:gitmoji[a:name]
  echomsg "Gitmoji.code: " gitmoji.code
  let word = g:gitmoji_insert_emoji ? gitmoji.emoji : gitmoji.code
  let result =<< trim EOT
    #{
      word: g:gitmoji_insert_emoji ? gitmoji.emoji : gitmoji.code,
      abbr: gitmoji.emoji .. ' ' .. gitmoji.name,
      menu: gitmoji.description,
      kind: 'gitmoji',
    }
  EOT
  return result->join()->eval()
endfunction

function s:warn(...)
  echohl WarningMsg
  echomsg "gitmoji.vim: " a:000->join()
  echohl None
endfunction

" This will be configurable at some point for additional things, like custom
" files
function s:load()
  let data = s:findlocal('gitmojis.json')->s:readjson()
  let result = {}
  if !has_key(data, 'gitmojis')
    s:warn('gitmojis.json', "is missing the 'gitmojis' key")
    return {}
  endif
  let data.gitmojis = data.gitmojis->sort(function('s:compare'))
  for item in data.gitmojis
    let result[item.name] = item
  endfor
  return result
endfunction

function gitmoji#complete(findstart, base)
  if !exists('s:gitmoji')
    let s:gitmoji = s:load()
  endif
  " TODO: Permit configuration setting to allow 'matching' if the line is
  " empty
  if a:base->empty() && a:findstart == 1
    let line = getline('.')[0:col('.') - 1]
    return line->match(':[^: \t]*$')
  endif
  let keys = s:gitmoji->keys()->sort()
  if !a:base->empty() && a:findstart == 0
    let keys = keys->matchfuzzy(a:base[1:])
  endif
  return keys->map(function('s:create'))
endfunction
