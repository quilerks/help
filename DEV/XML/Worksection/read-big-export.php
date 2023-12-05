<?php
$startTime = microtime(true);
$currentFolder = getcwd();
$fileName = '/export.xml';
$xml = simplexml_load_file($currentFolder . $fileName);
$data = $xml->projects->project->tasks->task->expenses;
$time = 0;
echo "
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <title>XML R</title>
    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css' rel='stylesheet'>
</head>
<body>";
echo '<table class="table table-bordered">';
foreach ($data->children() as $d) {
    list($hours, $minutes) = explode(':', $d->time);
    $total = round(((60 * $hours + $minutes) / 60), 1);
    $googleTableFloat = str_replace('.', ',', $total);
    $time += $total;
    echo '<tr>';
    echo '<td>' . $d->added . '</td>';
    echo '<td></td>';
    echo '<td></td>';
    echo '<td>' . $googleTableFloat . '</td>';
    echo '</tr>';

}
echo '</table>';
echo 'Total time: <b>' . $time . ' hours</b><br>';





$endTime = microtime(true);
$timeData = sprintf("%2.2f", $endTime - $startTime);
echo 'Time load: <b>' . $timeData . ' seconds</b>';

echo "
</body>
</html>
";