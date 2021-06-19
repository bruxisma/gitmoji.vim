if exists('g:gitmoji') | finish | endif
let g:gitmoji = v:true

if !exists('g:gitmoji_insert_emoji')
  let g:gitmoji_insert_emoji = v:true
endif

if !exists('g:gitmoji_complete_anywhere')
  let g:gitmoji_complete_anywhere = v:false
endif
