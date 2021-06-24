if exists('g:gitmoji_autoload_script') | finish | endif
let g:gitmoji = 1

let s:directory = expand('<sfile>:p')->resolve()->fnamemodify(':h')

function s:warn(...)
  echohl WarningMsg
  echomsg "gitmoji.vim: " a:000->join()
  echohl None
endfunction

function s:compare(lhs, rhs)
  if a:lhs.kind < a:rhs.kind
    return -1
  elseif a:lhs.kind > a:rhs.kind
    return 1
  endif
  return 0
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
  return s:completion(s:builtins[a:name], 'builtin')
endfunction

function s:alias(idx, name)
  let gitmoji = s:aliases[a:name]
  return s:completion(s:aliases[a:name], 'alias')
endfunction

function s:completion(gitmoji, type)
  let word = g:gitmoji_insert_emoji ? a:gitmoji.emoji : a:gitmoji.code
  let abbr = printf('%s %s', a:gitmoji.emoji, a:gitmoji.name)
  let menu = a:gitmoji.description
  return #{ word: word, abbr: abbr, menu: menu, kind: a:type }
endfunction

function s:getbuiltins()
  let data = s:findlocal('gitmojis.json')->s:readjson()
  let result = {}
  if !has_key(data, 'gitmojis')
    s:warn('gitmojis.json', "is missing the 'gitmojis' key.")
    return {}
  endif
  for item in data.gitmojis
    let result[item.name] = item
  endfor
  return result
endfunction

function s:getaliases()
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
      s:warn('gitmoji.vim', 'g:gitmoji_aliases function did not return a dictionary.')
      let data = {}
    endif
  endif
  let builtins = gitmoji#builtins()
  let results = {}
  for [name, aliases] in data->items()
    let gitmoji = builtins[name]->deepcopy()
    for alias in aliases
      let results[alias] = gitmoji->extend(#{ name: alias }, 'force')
    endfor
  endfor
  return results
endfunction

function gitmoji#builtins()
  if !exists('s:builtins')
    let s:builtins = s:getbuiltins()
  endif
  return s:builtins
endfunction

function gitmoji#aliases()
  if !exists('s:aliases')
    let s:aliases = s:getaliases()
  endif
  return s:aliases
endfunction

function gitmoji#complete(findstart, base)
  " Ensure that the dictionaries have been loaded.
  call gitmoji#builtins()
  call gitmoji#aliases()
  if a:base->empty() && a:findstart == 1
    let line = getline('.')[0:col('.') - 1]
    let column = line->match(':[^: \t]*$')
    if column < 0 && g:gitmoji_complete_anywhere
      return col('.')
    endif
    return column
  endif
  let builtins = s:builtins->keys()
  let aliases = s:aliases->keys()
  " In this case, there is 'a match' of sorts, and so we need to weed out the
  " names. The issue is, we need to *then* also return both the builtins and
  " the aliases defined. Thus our 'simple' code path will no longer work, and
  " we must branch for when the a:base is... empty.
  if !a:base->empty() && a:findstart == 0
    let builtins = builtins->matchfuzzy(a:base[1:])
    let aliases = aliases->matchfuzzy(a:base[1:])
  endif
  let completions = builtins->map(function('s:builtin'))
  let completions += aliases->map(function('s:alias'))
  return completions->sort(function('s:compare'))
endfunction
