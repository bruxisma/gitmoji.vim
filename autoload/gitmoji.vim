if exists('g:gitmoji_autoload_script') | finish | endif
let g:gitmoji = 1

let s:directory = expand('<sfile>:p')->resolve()->fnamemodify(':h')

function s:warn(...)
  echohl WarningMsg
  echomsg "gitmoji.vim: " a:000->join()
  echohl None
endfunction

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

" TODO: Look into applying iabbrev(s) during the CompleteDonePre or
" CompleteDone event.
function s:builtin(idx, name)
  let gitmoji = s:gitmoji[a:name]
  let word = g:gitmoji_insert_emoji ? gitmoji.emoji : gitmoji.code
  let abbr = printf('%s %s', gitmoji.emoji, gitmoji.name)
  let menu = gitmoji.description
  let kind = 'builtin'
  return #{ word: word, abbr: abbr, menu: menu, kind: kind }
endfunction

function s:builtins()
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

function s:aliases()
  if !exists('g:gitmoji_aliases')
    return {}
  endif
  let type = type(g:gitmoji_aliases)
  let data = {}
  if type == v:t_string
    let data = s:readjson(g:gitmoji_aliases)
  elseif type == v:t_dict
    let data = g:gitmoji_aliases
  elseif type == v:t_func
    let data = call g:gitmoji_aliases
    if type(data) != v:t_dict
      s:warn('gitmoji.vim', 'g:gitmoji_aliases function did not return a dictionary')
      return {}
    endif
  endif
  return data
endfunction

function gitmoji#builtins()
  if !exists('s:gitmoji')
    let s:gitmoji = s:builtins()
  endif
  return s:gitmoji
endfunction

function gitmoji#aliases()
  if !exists('s:aliases')
    let s:aliases = s:aliases()
  endif
  return s:aliases
endfunction

function gitmoji#complete(findstart, base)
  call gitmoji#builtins()
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
  return keys->map(function('s:builtin'))
endfunction
