#!/usr/bin/env bash

AUTO_COMMIT=${AUTO_COMMIT:-""}

next_change() {
  x=$(cat .change-count)
  echo $((x+1)) | tee .change-count
}

watch() {
  os="$(uname)"
  if [[ "$os" = "Linux" ]]; then
    inotifywait --quiet --recursive --monitor --event modify --format "%w%f" "$@"
  elif [[ "$os" = "Darwin" ]]; then
    fswatch -o "$@"
  else
    echo "Unknown OS $os"
    exit 1
  fi
}

watch src spec \
  | while read change; do
    crystal spec --no-color > .watch.out
    res=$?
    committed=

    if [[ $res -eq 0 ]]; then
      ! [[ -z "$AUTO_COMMIT" ]] && git add . && git commit -m "[GREEN] Change $(next_change)" && committed="(committed)"
      notify-send --expire-time=1000 "SUCCESS $committed"
    else
      failure=$(cat .watch.out | grep 'Failure\|expected:\|got:')
      cat .watch.out
      ! [[ -z "$AUTO_COMMIT" ]] && git add . && git commit -m "[RED] Change $(next_change)" && committed="(committed)"
      notify-send --expire-time=3000 "FAILURE:$failure $committed"
    fi
done
