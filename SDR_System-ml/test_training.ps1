# 测试ML训练API
Write-Host "Testing ML Training API..."

# 启动训练
$trainBody = @{model_types=@('collaborative_filtering','content_based')} | ConvertTo-Json
try {
    Write-Host "Starting training..."
    $trainResult = Invoke-RestMethod -Uri 'http://localhost:8002/api/model/train' -Method Post -Body $trainBody -ContentType 'application/json'
    Write-Host "Training started:" $trainResult.message
    
    # 检查进度几次
    for ($i = 1; $i -le 15; $i++) {
        Start-Sleep 2
        $progressResult = Invoke-RestMethod -Uri 'http://localhost:8002/api/training/progress' -Method Get
        Write-Host "Progress check $i - isTraining:" $progressResult.isTraining "Progress:" $progressResult.overallProgress"%"
        
        if (-not $progressResult.isTraining) {
            Write-Host "Training completed!"
            break
        }
    }
    
} catch {
    Write-Host "Error:" $_.Exception.Message
}
