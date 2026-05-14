#!/usr/bin/env php
<?php

function replaceContentShortOpenTags($content) {
  $tokens = token_get_all($content);
  $output = '';

  foreach ($tokens as $token) {
    if (is_array($token)) {
      list($index, $code, $line) = $token;
      switch ($index) {
        case T_OPEN_TAG_WITH_ECHO:
          $output .= '<?php echo ';
          break;
        case T_OPEN_TAG:
          $output .= '<?php ';
          break;
        default:
          $output .= $code;
          break;
      }
    } else {
      $output .= $token;
    }
  }
  return $output;
}

function replaceFileShortOpenTags($file) {
  file_put_contents(
    $file,
    replaceContentShortOpenTags(file_get_contents($file))
  );
}

foreach ($argv as $index => $file) {
  if ($index > 0) {
    echo "$index => $file\n";
    replaceFileShortOpenTags($file);
  }
}
