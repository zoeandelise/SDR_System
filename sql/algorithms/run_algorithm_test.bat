@echo off
echo ========================================
echo Recommendation Algorithm Test Suite
echo ========================================
echo.

echo [Step 1] Creating algorithm functions...
mysql -u root -p1234 --ssl-mode=DISABLED smart_diet_dev < sql\algorithms\recommendation_algorithm_v1.sql
if %errorlevel% neq 0 (
    echo [ERROR] Algorithm creation failed
    pause
    exit
)
echo [OK] Algorithm functions created
echo.

echo [Step 2] Running validation tests...
mysql -u root -p1234 --ssl-mode=DISABLED -t smart_diet_dev < sql\algorithms\algorithm_validation.sql > algorithm_test_results.txt
if %errorlevel% neq 0 (
    echo [ERROR] Validation failed
    pause
    exit
)
echo [OK] Validation completed
echo.

echo ========================================
echo Test completed! Results saved to:
echo algorithm_test_results.txt
echo ========================================
echo.
echo Next steps:
echo 1. Review the test results
echo 2. Try the algorithm with different users
echo 3. Optimize based on validation insights
echo.
pause

