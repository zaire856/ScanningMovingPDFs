# Load the iTextSharp assembly
Add-Type -Path "C:\Scripts\PDFReader\itextsharp.dll"

# Define the directory where the PDF files are located
$sourceDirectory = "F:\000000PDFs"

# Define the directory where the matching PDF files will be moved
$destinationDirectory = "F:\000000PDFs w_SN"

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
}

# Array of keywords to search for in the PDF files
$keywords = @("erial", "serial", "front", "rear", "rotos")

# Function to extract text from a PDF file using iTextSharp
function Get-PdfText($file) {
    $pdfReader = New-Object iTextSharp.text.pdf.PdfReader($file)
    $text = ""

    for ($page = 1; $page -le $pdfReader.NumberOfPages; $page++) {
        $text += [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($pdfReader, $page)
    }

    $pdfReader.Close()
    return $text
}

# Get all PDF files in the source directory
$pdfFiles = Get-ChildItem -Path $sourceDirectory -Filter *.pdf

# Loop through each PDF file
foreach ($file in $pdfFiles) {
    # Extract text from the PDF file
    $text = Get-PdfText $file.FullName

    # Check if any of the keywords are found in the PDF content
    $matchFound = $false
    foreach ($keyword in $keywords) {
        if ($text -match $keyword) {
            $matchFound = $true
            break
        }
    }

    # If a match is found, move the PDF file to the destination directory
    if ($matchFound) {
        Move-Item -Path $file.FullName -Destination $destinationDirectory -Force
        Write-Host "Moved $($file.Name) to $destinationDirectory"
    }
}

Write-Host "Scanning and moving PDF files completed."
