module.exports = {
  style: {
    postcss: {
      plugins: [
        require('tailwindcss'),
        require('autoprefixer'),
      ],
    },
  },
  devServer: {
    historyApiFallback: true, // 支持前端路由
    proxy: [
      {
        context: function(pathname, req) {
          const apiPaths = ['/api', '/diet', '/getInfo', '/captchaImage', '/common', '/actuator', '/profile'];
          if (apiPaths.some(p => pathname.startsWith(p))) return true;
          
          // Only proxy POST requests for auth endpoints to avoid conflict with React Router
          if (['/login', '/logout', '/register'].includes(pathname) && req.method === 'POST') {
            return true;
          }
          return false;
        },
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        cookieDomainRewrite: {
          '*': ''  // 重写 Cookie 域名为当前域名
        },
        onProxyReq: function (proxyReq, req, res) {
          proxyReq.setHeader('Origin', 'http://localhost:8080');
          proxyReq.setHeader('Referer', 'http://localhost:8080/');
          // 转发原始请求中的 Cookie
          if (req.headers.cookie) {
            proxyReq.setHeader('Cookie', req.headers.cookie);
          }
        },
        onProxyRes: function (proxyRes, req, res) {
          // 转发响应中的 Set-Cookie 头
          const cookies = proxyRes.headers['set-cookie'];
          if (cookies) {
            // 修改 Cookie 的域名和路径，使其在开发环境可用
            const modifiedCookies = cookies.map(cookie => {
              return cookie
                .replace(/Domain=[^;]+;?/gi, '')  // 移除 Domain 属性
                .replace(/Path=[^;]+;?/gi, 'Path=/;');  // 设置 Path 为根路径
            });
            proxyRes.headers['set-cookie'] = modifiedCookies;
          }
        }
      }
    ]
  },
  webpack: {
    configure: (webpackConfig) => {
      // 解决Webpack 5 Node.js polyfills问题
      webpackConfig.resolve.fallback = {
        ...webpackConfig.resolve.fallback,
        "http": false,
        "https": false,
        "util": false,
        "zlib": false,
        "stream": false,
        "url": false,
        "crypto": false,
        "assert": false,
      };
      return webpackConfig;
    },
  },
};
