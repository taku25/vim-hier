" hier.vim:		Highlight quickfix errors
" Last Modified: Tue 03. May 2011 10:55:27 +0900 JST
" Author:		Jan Christoph Ebersbach <jceb@e-jc.de>
" Version:		1.3

if exists('g:loaded_hier')
  finish
endif
let g:loaded_hier = 1

let s:save_cpo = &cpo
set cpo&vim

let g:hier_enabled = ! exists('g:hier_enabled') ? 1 : g:hier_enabled

let s:hier_hightlight_link_target = {
                                    \   'qf' : {
                                    \       "error" : "QFError",
                                    \       "warning" : "QFWarning",
                                    \       "info" : "QFInfo",
                                    \   },
                                    \   'loc' : {
                                    \       "error" : "LocError",
                                    \       "warning" : "LocWarning",
                                    \       "info" : "LocInfo",
                                    \   },
                                    \ }


function! s:GetMargeHierHighlights(type)
    let highlights = g:hier#default_highlights


	if !exists("g:hier_highlights")
		let g:hier_highlights = {}
	endif

    if has_key(g:hier_highlights, a:type) == 0
        return highlights
    endif

    for l:qickType in ['qf', 'loc']
        if has_key(g:hier_highlights[a:type], l:qickType) == 0
            continue
        endif
        call extend(highlights[a:type][l:qickType], g:hier_highlights[a:type][l:qickType])
    endfor

    return highlights

endfunction

function! s:PreHier(type) "{{{
    call s:Clear()

    let l:config = s:GetMargeHierHighlights(a:type)

    let l:highlight_group = l:config[a:type]

    for l:loc in keys(l:highlight_group)
        if has_key(s:hier_hightlight_link_target, l:loc) == 0
            continue
        endif

        let l:link_target = s:hier_hightlight_link_target[l:loc]
        let l:link_hightlight = l:highlight_group[l:loc]
    
        for l:key in keys(l:link_hightlight)
            if has_key(l:link_target, l:key) == 0
                continue
            endif
    
            let l:temp = l:link_target[l:key]." ".l:link_hightlight[l:key]
            exec "hi! link ".l:temp
        endfor
    endfor
endfunction "}}}



function! s:Getlist(type)
    if a:type == 'loc'
        return getloclist(0)
    else
        return getqflist()
    endif
endfunction

function! s:Clear()
    for m in getmatches()
        for h in ['QFError', 'QFWarning', 'QFInfo', 'LocError', 'LocWarning', 'LocInfo']
            if m.group == h
                call matchdelete(m.id)
            endif
        endfor
    endfor
endfunction

function! s:Hier()

    if g:hier_enabled == 0
        return
    endif

    let bufnr = bufnr('%')
    for type in ['qf', 'loc']
        for i in s:Getlist(type)
            if i.bufnr == bufnr
                let l:key = "error"
                if i.type == 'I' || i.type == 'info'
                    let l:key = 'info'
                elseif i.type == 'W' || i.type == 'warning'
                    let l:key = 'warning'
                endif

                let hi_group = s:hier_hightlight_link_target[type][l:key]

                if i.lnum > 0
                    call matchadd(hi_group, '\%'.i.lnum.'l')
                elseif i.pattern != ''
                    call matchadd(hi_group, i.pattern)
                endif
            endif
        endfor
    endfor
endfunction

command! -nargs=0 HierUpdate call s:Hier()
command! -nargs=0 HierClear call s:Clear()

command! -nargs=0 HierStart let g:hier_enabled = 1 | call s:Hier()
command! -nargs=0 HierStop let g:hier_enabled = 0 | call s:Clear()

"*grep*
"とそれ以外をしていしたいのだけどやりかたがわからず
"現状はgrep時に二度よばれてます...
augroup HierGroup
    au!
    au QuickFixCmdPre, * :call s:PreHier("make")
    au QuickFixCmdPre, *grep* :call s:PreHier("grep")
	au QuickFixCmdPost,BufEnter,WinEnter * :HierUpdate
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
