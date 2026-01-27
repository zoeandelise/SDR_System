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
        context: ['/api', '/login', '/logout', '/getInfo', '/register', '/captchaImage', '/common', '/actuator'],
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        onProxyReq: function (proxyReq) {
          proxyReq.setHeader('Origin', 'http://localhost:8080');
          proxyReq.setHeader('Referer', 'http://localhost:8080/');
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
