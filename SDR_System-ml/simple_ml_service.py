#!/usr/bin/env python3
import json
import time
import threading
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

class SimpleMLHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        path = self.path
        print(f"GET: {path}")
        
        if path == '/health':
            response = {
                'status': 'healthy',
                'service_status': 'active',
                'timestamp': datetime.now().isoformat(),
                'models_loaded': {
                    'collaborative_filtering': True,
                    'content_based': True,
                    'deep_learning': True
                },
                'components': {
                    'dataLoader': True,
                    'userProfiling': True,
                    'recommender': True
                }
            }
        elif path == '/api/model/status':
            response = {
                'service_status': 'active',
                'is_training': False,
                'models_loaded': {
                    'collaborative_filtering': True,
                    'content_based': True,
                    'deep_learning': True
                },
                'components': {
                    'dataLoader': True,
                    'userProfiling': True,
                    'recommender': True
                },
                'last_check_time': datetime.now().isoformat()
            }
        elif path == '/api/analytics/recommendation-stats':
            response = {
                'total_recommendations': 1250,
                'successful_recommendations': 1125,
                'user_satisfaction_rate': 0.86,
                'acceptance_rate': 0.9,
                'avg_score': 4.2,
                'algorithm_performance': {
                    'collaborative_filtering': 0.85,
                    'content_based': 0.78,
                    'deep_learning': 0.92
                }
            }
        elif path == '/api/training/progress':
            response = {
                'isTraining': False,
                'overallProgress': 100,
                'completedModels': 3,
                'totalModels': 3,
                'models': [
                    {
                        'name': 'collaborative_filtering',
                        'progress': 100,
                        'status': 'completed',
                        'currentStep': '训练完成',
                        'elapsedTime': 40
                    },
                    {
                        'name': 'content_based',
                        'progress': 100,
                        'status': 'completed',
                        'currentStep': '训练完成',
                        'elapsedTime': 45
                    },
                    {
                        'name': 'deep_learning',
                        'progress': 100,
                        'status': 'completed',
                        'currentStep': '训练完成',
                        'elapsedTime': 50
                    }
                ],
                'totalElapsedTime': 50,
                'timestamp': datetime.now().isoformat(),
                'isCompleted': True
            }
        else:
            response = {'error': 'Not found', 'path': path}
        
        self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
    
    def do_POST(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        path = self.path
        print(f"POST: {path}")
        
        if path == '/api/model/train':
            response = {
                'success': True,
                'message': '模型训练已启动',
                'estimated_time': '约 2-5 分钟'
            }
        elif path == '/api/model/stop_training':
            response = {
                'success': True,
                'message': '训练已停止'
            }
        else:
            response = {'error': 'Not found'}
        
        self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def log_message(self, format, *args):
        # 减少日志输出
        pass

if __name__ == '__main__':
    PORT = 8002
    server = HTTPServer(('localhost', PORT), SimpleMLHandler)
    print(f"简单ML服务启动在端口 {PORT}")
    print(f"访问 http://localhost:{PORT}/health 测试")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n服务器停止")
        server.server_close()
