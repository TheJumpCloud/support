$headers = @{}
$headers.Add("x-org-id", "")
$headers.Add("x-api-key", "6ef51a1f78e68ec71a06e00c6203e6b37795fe20")
$x = "635ad0b5295887438875cf4b"
$response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/directories?filter=type:g_suite' -Method GET -Headers $headers


$response