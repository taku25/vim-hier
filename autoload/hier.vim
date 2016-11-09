let s:save_cpo = &cpo
set cpo&vim



let g:hier#default_highlights = {
            \"make" : {
            \   'qf' : {
            \       "error" : "SpellBad",
            \       "warning" : "SpellLocal",
            \       "info" : "SpellRare",
            \   },
            \   'loc' : {
            \       "error" : "SpellBad",
            \       "warning" : "SpellLocal",
            \       "info" : "SpellRare",
            \   },
            \},
            \"grep" : {
            \   'qf' : {
            \       "error" : "Search",
            \       "warning" : "Search",
            \       "info" : "Search",
            \   },
            \},
            \}



let &cpo = s:save_cpo
unlet s:save_cpo
