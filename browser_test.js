// 浏览器控制台测试脚本
// 复制粘贴到浏览器控制台中运行

console.log('🚀 开始测试登录功能...');

// 1. 测试API可达性
async function testLoginAPI() {
    console.log('📡 测试登录API...');
    
    try {
        const response = await fetch('/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: 'admin',
                password: 'admin123'
            })
        });
        
        console.log('📊 Response status:', response.status);
        console.log('📊 Response headers:', [...response.headers.entries()]);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        console.log('✅ 登录API响应:', data);
        
        if (data.token) {
            console.log('🔑 Token获取成功:', data.token.substring(0, 50) + '...');
            
            // 保存到localStorage
            localStorage.setItem('token', data.token);
            if (data.user) {
                localStorage.setItem('userInfo', JSON.stringify(data.user));
            }
            
            console.log('💾 Token已保存到localStorage');
            return data;
        } else {
            console.error('❌ 响应中没有token');
            return null;
        }
        
    } catch (error) {
        console.error('❌ 登录API调用失败:', error);
        console.error('❌ 错误详情:', error.message);
        return null;
    }
}

// 2. 测试获取用户信息API
async function testGetUserInfo() {
    console.log('👤 测试获取用户信息API...');
    
    const token = localStorage.getItem('token');
    if (!token) {
        console.error('❌ 没有token，请先登录');
        return null;
    }
    
    try {
        const response = await fetch('/getInfo', {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('📊 GetInfo Response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        console.log('✅ 用户信息API响应:', data);
        return data;
        
    } catch (error) {
        console.error('❌ 获取用户信息失败:', error);
        return null;
    }
}

// 3. 测试React组件中的authApi
function testAuthApi() {
    console.log('⚛️ 测试React authApi...');
    
    // 检查是否能访问authApi
    if (typeof window !== 'undefined' && window.authApi) {
        console.log('✅ authApi可用');
        return window.authApi;
    } else {
        console.log('❌ authApi不可用，可能是模块加载问题');
        return null;
    }
}

// 4. 检查网络连接
async function checkNetworkConnectivity() {
    console.log('🌐 检查网络连接...');
    
    const endpoints = [
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:8080/actuator/health'
    ];
    
    for (const endpoint of endpoints) {
        try {
            const response = await fetch(endpoint, { method: 'GET' });
            console.log(`✅ ${endpoint} - Status: ${response.status}`);
        } catch (error) {
            console.log(`❌ ${endpoint} - Error: ${error.message}`);
        }
    }
}

// 5. 检查localStorage状态
function checkLocalStorage() {
    console.log('💾 检查localStorage状态...');
    
    const token = localStorage.getItem('token');
    const userInfo = localStorage.getItem('userInfo');
    
    console.log('🔑 Token:', token ? token.substring(0, 50) + '...' : 'null');
    console.log('👤 UserInfo:', userInfo || 'null');
}

// 运行所有测试
async function runAllTests() {
    console.log('🧪 运行完整测试套件...');
    console.log('=' .repeat(50));
    
    // 清理localStorage
    localStorage.removeItem('token');
    localStorage.removeItem('userInfo');
    
    await checkNetworkConnectivity();
    console.log('-'.repeat(30));
    
    const loginResult = await testLoginAPI();
    console.log('-'.repeat(30));
    
    if (loginResult) {
        await testGetUserInfo();
        console.log('-'.repeat(30));
    }
    
    checkLocalStorage();
    console.log('-'.repeat(30));
    
    testAuthApi();
    
    console.log('=' .repeat(50));
    console.log('🏁 测试完成');
}

// 自动运行测试
runAllTests();
