@echo off

set zip="c:\Program Files\7-Zip\7z.exe"

%zip% a appleseed-deps-stage-win64-vs110-vN.zip stage\vc11
%zip% a appleseed-deps-stage-win64-vs120-vN.zip stage\vc12
%zip% a appleseed-deps-stage-win64-vs140-vN.zip stage\vc14
