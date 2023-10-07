call shader_minifier ./raw/_gdi2_.frag --preserve-externals --move-declarations --aggressive-inlining --format text -o ./min/_gdi2_.frag
call shader_minifier ./raw/_gdi2_.vert --preserve-externals --move-declarations --aggressive-inlining --format text -o ./min/_gdi2_.vert
pause
