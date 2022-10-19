<?php
$table_prefix = $modx->getOption('table_prefix');
$q = $modx->prepare("SELECT `pattern`, COUNT(`pattern`) AS `count` FROM `" . $table_prefix . "redirects` GROUP BY `pattern` HAVING `count` > 1");
$q->execute();
$redirects = $q->fetchAll(PDO::FETCH_ASSOC);

foreach ($redirects as $redirect) {
    $pattern = $redirect['pattern'];
    $count = $redirect['count'] - 1;
    echo $pattern . ' - ' . $count . '<br>';
    $query = $modx->prepare("DELETE FROM `" . $table_prefix . "redirects` WHERE `pattern` = '$pattern' ORDER BY id DESC LIMIT $count");
    $query->execute();
}