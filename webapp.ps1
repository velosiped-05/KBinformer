# Путь к папке с текстовыми файлами
$folderPath = "C:\KBinformer\bot\ID\247005670"
# Путь для выходного HTML файла
$outputFolder = "C:\KBinformer\webapp"
$outputHtml = Join-Path $outputFolder "247005670.html"

# Проверка существования папки webapp
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder -Force
}

# Создаем начало HTML файла
$htmlContent = @"
<!DOCTYPE html>
<html lang='ru'>
<head>
    <meta charset='UTF-8'>
    <title>Содержимое текстовых файлов - 247005670</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .file-container { margin-bottom: 20px; }
        .file-title { color: #333; }
        .file-content { background-color: #f5f5f5; padding: 10px; border: 1px solid #ddd; line-height: 1.5; }
    </style>
</head>
<body>
<h1>П</h1>
"@

# Функция для обработки текста в содержимом: убирает * без добавления <b>
function Format-ContentText {
    param ([string]$text)
    # Убираем *текст* -> текст
    $formattedText = $text -replace '\*([^\*]+)\*', '$1'
    return $formattedText
}

# Получаем все текстовые файлы в папке, исключая zzz.txt
$txtFiles = Get-ChildItem -Path $folderPath -Filter *.txt | Where-Object { $_.Name -ne "zzz.txt" }

if ($txtFiles) {
    foreach ($file in $txtFiles) {
        # Читаем все строки файла
        $lines = Get-Content -Path $file.FullName
        # Проверяем количество строк
        $lineCount = $lines.Count
        
        if ($lineCount -gt 1) {
            # Получаем первую строку (заголовок) и убираем *
            $firstLine = $lines[0]
            $formattedFirstLine = $firstLine -replace '\*([^\*]+)\*', '$1'
            # Экранируем заголовок
            $escapedFirstLine = [System.Web.HttpUtility]::HtmlEncode($formattedFirstLine)
            # Получаем содержимое без первой строки
            $contentLines = $lines[1..($lineCount-1)]
            # Форматируем и экранируем каждую строку содержимого
            $escapedContentLines = $contentLines | ForEach-Object {
                $formattedLine = Format-ContentText -text $_
                [System.Web.HttpUtility]::HtmlEncode($formattedLine)
            }
            # Объединяем строки с <br>
            $escapedContent = $escapedContentLines -join "<br>"
            # Добавляем содержимое в HTML, заголовок оборачиваем в <b>
            $htmlContent += @"
            <div class='file-container'>
                <div class='file-title'><b>$escapedFirstLine</b></div>
                <div class='file-content'>$escapedContent</div>
            </div>
"@
        }
    }
}
else {
    $htmlContent += "<p>Текстовые файлы в папке не найдены.</p>"
}

# Завершаем HTML
$htmlContent += @"
</body>
</html>
"@

# Сохраняем HTML файл
$htmlContent | Out-File -FilePath $outputHtml -Encoding UTF8

Write-Host "HTML файл создан: $outputHtml"