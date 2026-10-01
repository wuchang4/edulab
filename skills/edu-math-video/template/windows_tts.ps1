param([Parameter(Mandatory=$true)][string]$JobFile)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
Add-Type -AssemblyName System.Speech
$job = Get-Content -LiteralPath $JobFile -Raw -Encoding UTF8 | ConvertFrom-Json
$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
try {
    if ($job.mode -eq 'voices') {
        $voices = @($speaker.GetInstalledVoices() | Where-Object { $_.Enabled } | ForEach-Object {
            @{ name = $_.VoiceInfo.Name; culture = $_.VoiceInfo.Culture.Name }
        })
        ConvertTo-Json -InputObject $voices -Compress
    } elseif ($job.mode -eq 'speak') {
        $speaker.SelectVoice([string]$job.voice)
        $speaker.Rate = [int]$job.rate
        $speaker.Volume = 100
        $format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(
            48000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,
            [System.Speech.AudioFormat.AudioChannel]::Mono)
        $speaker.SetOutputToWaveFile([string]$job.output, $format)
        $speaker.Speak([string]$job.text)
    } else {
        throw 'Unknown Windows TTS job mode'
    }
} finally {
    $speaker.Dispose()
}
