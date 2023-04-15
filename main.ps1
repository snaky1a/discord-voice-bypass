# Arguments
$file = $args[0]
$channel_id = $args[1]
$auth = $args[2]

# Get file size
$fs = (Get-Item $file).length

# Request headers
$headers = @{
    "accept"        = "*/*"
    "authorization" = $auth
    "content-type"  = "application/json"
}

# Body content
$body = @{
    files = @(
        @{
            filename  = "voice-message.ogg"
            file_size = $fs
        }
    )
} | ConvertTo-Json # generate body and convert it to JSON format

# Send Request for upload_url
$resp = Invoke-RestMethod -Method POST -Uri "https://canary.discord.com/api/v9/channels/$channel_id/attachments" -Headers $headers -Body $body
$file_url = $resp.attachments[0].upload_url
$filename = $resp.attachments[0].upload_filename

# Put request for upload voice
Invoke-RestMethod -Method PUT -Uri $file_url -InFile $file

# Headers to upload voice on /channels/CHANNEL_ID/messages URI
$headers = @{
    "Host"               = "discord.com"
    "Content-Type"       = "application/json"
    "X-Debug-Options"    = "bugReporterEnabled"
    "Accept"             = "*/*"
    "Authorization"      = $auth
    "Accept-Encoding"    = "gzip, deflate"
    "X-Super-Properties" = "eyJvcyI6ImlPUyIsImJyb3dzZXIiOiJEaXNjb3JkIGlPUyIsImRldmljZSI6ImlQaG9uZTksMyIsInN5c3RlbV9sb2NhbGUiOiJlbi1DQSIsImNsaWVudF92ZXJzaW9uIjoiMTcyLjAiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJicm93c2VyX3VzZXJfYWdlbnQiOiIiLCJicm93c2VyX3ZlcnNpb24iOiIiLCJvc192ZXJzaW9uIjoiMTUuNSIsImNsaWVudF9idWlsZF9udW1iZXIiOjQyNjU2LCJjbGllbnRfZXZlbnRfc291cmNlIjpudWxsLCJkZXNpZ25faWQiOjB9"
}

# Body content to upload voice on /channels/CHANNEL_ID/messages URI and convert to json
$body = @{
    content     = ""
    channel_id  = $channel_id
    type        = 0
    flags       = 8192
    attachments = @(
        @{
            id                = "0"
            filename          = "voice-message.ogg"
            uploaded_filename = $filename
            duration_secs     = 2.32
            waveform          = "ACETCwAFEwAAAwAyAIh9kolTjYeFUw=="
        }
    )
} | ConvertTo-Json

# post method
$resp = Invoke-RestMethod -Method POST -Uri "https://discord.com/api/v9/channels/$channel_id/messages" -Headers $headers -Body $body

Write-Output("Done!")
