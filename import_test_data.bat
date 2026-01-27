@echo off
chcp 65001
echo ======================================
echo   智能饮食推荐系统 - 测试数据导入
echo ======================================
echo.

echo 正在连接数据库...
echo 数据库: smart_diet_dev
echo 主机: localhost:3306
echo 用户: root
echo.

echo 开始导入测试数据，这可能需要几分钟时间...
echo.

echo [1/3] 导入食物库和用户数据...
mysql --ssl-mode=DISABLED -h localhost -P 3306 -u root -p1234 smart_diet_dev < sql/comprehensive_diet_data.sql

if %ERRORLEVEL% neq 0 (
    echo ❌ 食物库数据导入失败！
    pause
    exit /b 1
)

echo ✅ 食物库数据导入成功！
echo.

echo [2/3] 导入饮食记录数据...
mysql --ssl-mode=DISABLED -h localhost -P 3306 -u root -p1234 smart_diet_dev < sql/diet_records_data.sql

if %ERRORLEVEL% neq 0 (
    echo ❌ 饮食记录数据导入失败！
    pause
    exit /b 1
)

echo ✅ 饮食记录数据导入成功！
echo.

echo [3/3] 执行数据验证和统计...
mysql --ssl-mode=DISABLED -h localhost -P 3306 -u root -p1234 smart_diet_dev -e "
SELECT '=== 数据导入完成统计 ===' as '状态报告';

SELECT 
    '食物分类' as '数据类型',
    COUNT(*) as '记录数',
    '已导入完成' as '状态'
FROM diet_food_category
UNION ALL
SELECT 
    '食物信息',
    COUNT(*),
    '已导入完成'
FROM diet_food_info
UNION ALL
SELECT 
    '营养信息',
    COUNT(*),
    '已导入完成'
FROM diet_food_nutrition
UNION ALL
SELECT 
    '测试用户',
    COUNT(*),
    '已导入完成'
FROM sys_user 
WHERE user_id >= 101
UNION ALL
SELECT 
    '健康信息',
    COUNT(*),
    '已导入完成'
FROM sys_user_health 
WHERE user_id >= 101
UNION ALL
SELECT 
    '饮食记录',
    COUNT(*),
    '已导入完成'
FROM diet_record 
WHERE user_id >= 101;
"

if %ERRORLEVEL% neq 0 (
    echo ❌ 数据验证失败！
    pause
    exit /b 1
)

echo.
echo 🎉 =======================================
echo    测试数据导入完成！
echo 🎉 =======================================
echo.
echo 📊 数据概览:
echo    • 50个测试用户 (ID: 101-150)
echo    • 55种食物 (10大分类)
echo    • 300+条饮食记录
echo    • 完整的营养信息数据
echo.
echo 🚀 现在可以：
echo    • 测试饮食记录功能
echo    • 训练机器学习模型
echo    • 验证推荐算法效果
echo    • 进行数据分析
echo.
echo 详细说明请查看: 数据库测试数据说明.md
echo.
pause
