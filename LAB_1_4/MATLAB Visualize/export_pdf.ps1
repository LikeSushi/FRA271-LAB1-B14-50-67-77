$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $docxPath = 'C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\MATLAB Visualize\Lab1_4_Full_Report_Document.docx'
    $pdfPath  = 'C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\MATLAB Visualize\Lab1_4_Full_Report_Document.pdf'
    $doc = $word.Documents.Open($docxPath)
    $doc.SaveAs([ref]$pdfPath, [ref]17)
    $doc.Close([ref]0)
    Write-Output "PDF_EXPORTED_SUCCESSFULLY"
} finally {
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
