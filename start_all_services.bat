@echo off
chcp 65001 > nul
title 智能饮食推荐系统 - 完整服务启动

echo ========================================
echo    智能饮食推荐系统 - 服务启动器
echo ========================================
echo.
echo 本脚本将启动以下服务：
echo [1] 后端服务 (Spring Boot) - http://localhost:8080
echo [2] 管理员前端 (Vue2) - http://localhost:81
echo [3] 用户端前端 (React) - http://localhost:3000  
echo [4] 机器学习服务 (Python) - http://localhost:8001
echo.

set /p choice="是否启动所有服务？(Y/N): "
if /i "%choice%" NEQ "Y" goto :end

echo.
echo ========================================
echo    正在启动各项服务...
echo ========================================

rem 1. 启动后端服务
echo.
echo [1/4] 启动后端服务...
start "后端服务" cmd /k "chcp 65001 > nul && set JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8 && cd SDR_System-admin && echo 后端服务启动中(使用Maven)... && mvn spring-boot:run"
echo ✓ 后端服务启动命令已执行

rem 等待后端服务启动 (Maven初次启动较慢)
timeout /t 15 /nobreak > nul

rem 2. 启动机器学习服务
echo.
echo [2/4] 启动机器学习服务...
start "ML服务" cmd /k "chcp 65001 > nul && cd SDR_System-ml && echo ML服务启动中... && python start_ml_service.py"
echo ✓ ML服务启动命令已执行

rem 等待ML服务启动
timeout /t 5 /nobreak > nul

rem 3. 启动管理员前端
echo.
echo [3/4] 启动管理员前端...
start "管理员前端" cmd /k "chcp 65001 > nul && cd SDR_System-ui && echo 管理员前端启动中... && npm run dev"
echo ✓ 管理员前端启动命令已执行

rem 等待前端服务启动
timeout /t 5 /nobreak > nul

rem 4. 启动用户端前端
echo.
echo [4/4] 启动用户端前端...
start "用户端前端" cmd /k "chcp 65001 > nul && cd sdr-user-frontend && echo 用户端前端启动中... && npm start"
echo ✓ 用户端前端启动命令已执行

echo.
echo ========================================
echo    所有服务启动完成！
echo ========================================
echo.
echo 📌 服务访问地址：
echo    • 用户端：     http://localhost:3000
echo    • 管理员端：   http://localhost:81
echo    • 后端API：    http://localhost:8080
echo    • ML服务：     http://localhost:8001
echo.
echo 📌 API文档地址：
echo    • Swagger UI： http://localhost:8080/swagger-ui/
echo    • ML API文档： http://localhost:8001/docs
echo.
echo ⚠️  注意事项：
echo    1. 请确保各端口未被占用
echo    2. 首次启动可能需要较长时间
echo    3. 如遇到问题，请检查各服务窗口的错误信息
echo.
echo 按任意键关闭此窗口...

:end
pause > nul
