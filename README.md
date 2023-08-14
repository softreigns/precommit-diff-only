# precommit-diff-only
Perform pre-commit check only on the new changes

## bash script: 

```sh
mkdir -p .tmpShCh/difffiles && mkdir -p .tmpShCh/issues;
files=$(git diff --cached --name-only | grep .sh);
for file in $files; do
  filename="${file##*/}";
  git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" > .tmpShCh/difffiles/"${filename}";
  #---------------change these lines based on what kind of check is this, shellcheck-py, flake8 or anything else.
  #---------------you just want to get individual issue, and check if that exist in the diff files
  shellcheck "$file" | sed "/^$/d" | awk "/^In/{x=\".tmpShCh/issues/${filename%.*}\"++i;}{print > x;}";
  for ifile in .tmpShCh/issues/${filename%.*}*; do
    mline="$(cat "$ifile" | head -2)";
  #---------------
    [ -n "$mline" ] && mt=$(cat ".tmpShCh/difffiles/${filename}" | grep "$mline");
    if [ -n "$mt" ]; then
      echo -e "\n----------------------------------" >> .tmpShCh/output.txt;
      cat "$ifile" >> .tmpShCh/output.txt;
    fi;
    unset mt; unset mline;
  done;
done;
[ -f .tmpShCh/output.txt ] && (cat .tmpShCh/output.txt && rm -rf .tmpShch && exit 1)
```

## pre-commit-config syntax:

```yaml

  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.5
    hooks:
      - id: shellcheck
        # get staged files, write new/changed lines/file to a temp file, write file/issue/stgfie, check if issue exist in newlines, add to output
        entry: bash -c 'mkdir -p .tmpShCh/difffiles && mkdir -p .tmpShCh/issues;
              files=$(git diff --cached --name-only | grep .sh);
              for file in $files; do
                filename="${file##*/}";
                git diff --cached "${file}" | grep "^[+][^+-]" | sed "s|^+||g" > .tmpShCh/difffiles/"${filename}";
                #---------------change these lines based on what kind of check is this, shellcheck-py, flake8 or anything else.
                #---------------you just want to get individual issue, and check if that exist in the diff files
                shellcheck "$file" | sed "/^$/d" | awk "/^In/{x=\".tmpShCh/issues/${filename%.*}\"++i;}{print > x;}";
                for ifile in .tmpShCh/issues/${filename%.*}*; do
                  mline="$(cat "$ifile" | head -2)";
                #---------------
                  [ -n "$mline" ] && mt=$(cat ".tmpShCh/difffiles/${filename}" | grep "$mline");
                  if [ -n "$mt" ]; then
                    echo -e "\n----------------------------------" >> .tmpShCh/output.txt;
                    cat "$ifile" >> .tmpShCh/output.txt;
                  fi;
                  unset mt; unset mline;
                done;
              done;
              [ -f .tmpShCh/output.txt ] && (cat .tmpShCh/output.txt && rm -rf .tmpShch && exit 1)'
```
