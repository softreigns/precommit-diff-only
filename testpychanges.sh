#!/bin/bash
mkdir -p .tmpPyCh/dfiles && mkdir -p .tmpPyCh/issues;
for file in $(git diff --cached --name-only | grep .py); do
  filename="${file##*/}";
  git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" > .tmpPyCh/dfiles/"${filename}";
  for issue in "$(flake8 "$file")"; do
    p1="${issue#*:}" && p2=${p1%%:*};
    mline=$(sed -n "$p2"p "$file");
    echo "---$mline---";
    [ -n "$mline" ] && mt=$(cat ".tmpPyCh/dfiles/${filename}" | grep "$mline");
    if [ -n "$mt" ]; then
      echo -e "==>" >> .tmpPyCh/output.txt;
      echo "$issue" >> .tmpPyCh/output.txt;
    fi;
    unset mt; unset mline;
  done;
done
[ -f .tmpPyCh/output.txt ] && (cat .tmpPyCh/output.txt && rm -rf .tmpPyCh && exit 1)
