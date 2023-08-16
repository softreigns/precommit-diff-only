# precommit-diff-only
Perform pre-commit check only on the new changes

Solves : 
https://github.com/pre-commit/pre-commit/issues/1279
https://github.com/pre-commit/pre-commit/pull/1280


## bash script: 

```sh
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
if [ -f .tmpShCh/output.txt ]; then
  cat .tmpShCh/output.txt
  rm -rf .tmpShCh
  exit 1
else
  exit 0
fi
```

## pre-commit-config syntax:

```yaml

  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.5
    hooks:
      - id: shellcheck
        # get staged files, write new/changed lines/file to a temp file, write file/issue/stgfie, check if issue exist in newlines, add to output
        entry: bash -c 'mkdir -p .tmpShCh/dfiles && mkdir -p .tmpShCh/issues;
              files=$(git diff --cached --name-only | grep "\.sh");
              for file in $files; do
                filename="${file##*/}";
                git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" > .tmpShCh/dfiles/"${filename}";
                shellcheck "$file" | sed "/^$/d" | awk "/^In/{x=\".tmpShCh/issues/${filename%.*}\"++i;}{print > x;}";
                find  .tmpShCh/issues -type f -iname "${filename%.*}*" > .tmpShCh/tmp;
                while IFS= read -r ifile; do
                  mline="$(head -2 < "$ifile")";
                  [ -n "$mline" ] && mt=$(grep "$mline" < ".tmpShCh/dfiles/${filename}");
                  if [ -n "$mt" ]; then
                    echo -e "\n----------------------------------" >> .tmpShCh/output.txt;
                    cat "$ifile" >> .tmpShCh/output.txt;
                  fi;
                  unset mt; unset mline;
                done < .tmpShCh/tmp;
              done;
              if [ -f .tmpShCh/output.txt ]; then
                cat .tmpShCh/output.txt;
                rm -rf .tmpShch; exit 1;
              else
                rm -rf .tmpShCh;
                exit 0;
              fi;'
```
