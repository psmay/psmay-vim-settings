
" Also install syntax file bundle:
"
" cd ~/.vim/bundle && bzr branch \
" https://github.com/vim-scripts/Arduino-syntax-file.git Arduino-syntax-file
" 
au BufRead,BufNewFile *.pde,*.ino set filetype=arduino
au FileType arduino setlocal ts=2 sw=2 expandtab
