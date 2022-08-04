assoc(Doom, {'editor', 'lisp_langs'}, {'fennel', 'scheme', 'lisp', 'elisp', 'clojure'})
vim.g.sexp_filetypes = table.concat(Doom.editor.lisp_langs, ',')
