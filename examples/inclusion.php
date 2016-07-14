<?php

$file = isset($_GET['file']) ? $_GET['file'] : './text.txt';

echo "Fetching ... $file\n<br />";

?>
<textarea style="width:100%;min-height:400px;">
<?php echo file_get_contents($file); ?>
</textarea>
