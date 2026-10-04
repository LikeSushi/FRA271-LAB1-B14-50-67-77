$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open('C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\MATLAB Visualize\Lab1_4_Full_Report_Document.docx')
    $pages = $doc.ComputeStatistics(2)
    Write-Output "Pages: $pages"
    # Find what is on the last page
    $range = $doc.Content
    $range.Collapse(0) # start
    # Let's see last paragraph
    $lastP = $doc.Paragraphs.Last.Range.Text
    Write-Output "Last Paragraph: $lastP"
    $doc.Close()
} finally {
    $word.Quit()
}
