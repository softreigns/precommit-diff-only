#!/bin/bash
mkdir -p .tmpShCh/dfiles && mkdir -p .tmpShCh/issues;
for file in $(git diff --cached --name-only | grep .sh); do
  filename="${file##*/}";
  #git diff --cached --color=always -- "${file}" | perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/' >.tmpShCh/dfiles/"${filename}"
  git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" > .tmpShCh/dfiles/"${filename}";
  shellcheck "$file" | sed "/^$/d" | awk "/^In/{x=\".tmpShCh/issues/${filename%.*}\"++i;}{print > x;}";
  for ifile in .tmpShCh/issues/${filename%.*}*; do
    mline="$(cat "$ifile" | head -2)";
    [ -n "$mline" ] && mt=$(cat ".tmpShCh/dfiles/${filename}" | grep "$mline");
    if [ -n "$mt" ]; then
      echo -e "\n==>\n" >> .tmpShCh/output.txt;
      cat "$ifile" >> .tmpShCh/output.txt;
    fi;
    unset mt; unset mline;
  done;
done
[ -f .tmpShCh/output.txt ] && (cat .tmpShCh/output.txt && exit 1)
