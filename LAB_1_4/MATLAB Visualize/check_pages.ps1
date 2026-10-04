$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open('C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\MATLAB Visualize\Lab1_4_Full_Report_Document.docx')
    $pages = $doc.ComputeStatistics(2)
    Write-Output "TOTAL_PAGES:$pages"
    $doc.Close()
} finally {
    $word.Quit()
}
