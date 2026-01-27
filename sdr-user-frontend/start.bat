@echo off
echo ========================================
echo    健康饮食助手 - 用户端前端启动脚本
echo ========================================
echo.

echo 正在检查Node.js环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ? 错误：未找到Node.js，请先安装Node.js
    echo 下载地址：https://nodejs.org/
    pause
    exit /b 1
)
echo ? Node.js环境正常

echo.
echo 正在检查项目依赖...
if not exist "node_modules" (
    echo ?? 首次运行，正在安装依赖...
    npm install
    if %errorlevel% neq 0 (
        echo ? 依赖安装失败
        pause
        exit /b 1
    )
    echo ? 依赖安装完成
) else (
    echo ? 依赖已存在
)

echo.
echo ?? 正在启动开发服务器...
echo 应用将在 http://localhost:3000 打开
echo 按 Ctrl+C 可停止服务器
echo.

npm start
