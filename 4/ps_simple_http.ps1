$Root = 'f:\4'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()
Write-Output "Serving $Root at http://localhost:8000/ (press Ctrl+C to stop)"
while ($true) {
  $context = $listener.GetContext()
  $request = $context.Request
  $path = $request.Url.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }
  $file = Join-Path $Root $path
  if (Test-Path $file) {
    try {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $context.Response.ContentLength64 = $bytes.Length
      $context.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } catch {
      $context.Response.StatusCode = 500
      $msg = "500 Internal Server Error"
      $b=[System.Text.Encoding]::UTF8.GetBytes($msg)
      $context.Response.ContentLength64 = $b.Length
      $context.Response.OutputStream.Write($b,0,$b.Length)
    }
  } else {
    $context.Response.StatusCode = 404
    $msg = "404 Not Found"
    $b=[System.Text.Encoding]::UTF8.GetBytes($msg)
    $context.Response.ContentLength64 = $b.Length
    $context.Response.OutputStream.Write($b,0,$b.Length)
  }
  $context.Response.OutputStream.Close()
}
