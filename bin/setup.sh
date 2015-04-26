#!/bin/sh
mkdir ./.tmCache
mkdir ./.tmCache/_TM_3_5_Content
if [[ $git_pwd = *[!\ ]* ]]; then
  git clone https://tm-build:$git_pwd@github.com/TMContent/Lib_UNO-json.git ./.tmCache/_TM_3_5_Content/Lib_UNO-json
else
  git clone git@github.com:TMContent/Lib_UNO-json.git ./.tmCache/_TM_3_5_Content/Lib_UNO-json
fi
