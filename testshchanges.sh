#!/bin/bash
mkdir -p .tmpShCh/dfiles && mkdir -p .tmpShCh/issues
for file in $(git diff --cached --name-only | grep '\.sh'); do
  filename="${file##*/}"
  #git diff --cached --color=always -- "${file}" | perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/' >.tmpShCh/dfiles/"${filename}"
  git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" >.tmpShCh/dfiles/"${filename}"
  shellcheck "$file" | sed "/^$/d" | awk "/^In/{x=\".tmpShCh/issues/${filename%.*}\"++i;}{print > x;}"
  find .tmpShCh/issues -type f -iname "${filename%.*}*" >.tmpShCh/tmp
  while IFS= read -r ifile; do
    mline=$(head -2 <"$ifile")
    [ -n "$mline" ] && mt=$(grep "$mline" <".tmpShCh/dfiles/${filename}")
    if [ -n "$mt" ]; then
      echo -e "\n==>\n" >>.tmpShCh/output.txt
      cat "$ifile" >>.tmpShCh/output.txt
    fi
    unset mt
    unset mline
  done <.tmpShCh/tmp
done
[ -f .tmpShCh/output.txt ] && (cat .tmpShCh/output.txt && rm -rf .tmpShCh exit 1)
