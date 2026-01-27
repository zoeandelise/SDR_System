import React, { useState, useEffect } from 'react';
import { monitoringApi, connectionManager } from '../services/api';
import type { SystemStatusResponse, HealthStatus } from '../types/api';

interface SystemStatusProps {
  className?: string;
  showDetails?: boolean;
}

type ServiceStatus = HealthStatus;

type SystemStatusData = SystemStatusResponse;

const SystemStatus: React.FC<SystemStatusProps> = ({ 
  className = '', 
  showDetails = false 
}) => {
  const [systemStatus, setSystemStatus] = useState<SystemStatusData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    // 监听网络状态变化
    const handleConnectionChange = (status: string) => {
      setIsOnline(status === 'online');
      if (status === 'online') {
        checkSystemStatus();
      }
    };

    connectionManager.addListener(handleConnectionChange);
    
    // 初始检查
    checkSystemStatus();
    
    // 定期检查系统状态
    const interval = setInterval(checkSystemStatus, 30000); // 每30秒检查一次

    return () => {
      clearInterval(interval);
      connectionManager.removeListener(handleConnectionChange);
    };
  }, []);

  const checkSystemStatus = async () => {
    if (!isOnline) {
      setIsLoading(false);
      return;
    }

    try {
      setIsLoading(true);
      const status = await monitoringApi.getSystemStatus();
      setSystemStatus(status);
    } catch (error) {
      console.error('系统状态检查失败:', error);
      setSystemStatus({
        backend: { status: 'error', error: '检查失败' },
        mlService: { status: 'error', error: '检查失败' },
        timestamp: new Date().toISOString()
      });
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'healthy':
        return 'text-green-500';
      case 'unhealthy':
        return 'text-yellow-500';
      case 'error':
        return 'text-red-500';
      default:
        return 'text-gray-500';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'healthy':
        return '✅';
      case 'unhealthy':
        return '⚠️';
      case 'error':
        return '❌';
      default:
        return '❓';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'healthy':
        return '正常';
      case 'unhealthy':
        return '异常';
      case 'error':
        return '错误';
      default:
        return '未知';
    }
  };

  if (!isOnline) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <span className="text-red-500">🔴</span>
        <span className="text-sm text-red-600">网络连接断开</span>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
        <span className="text-sm text-gray-600">检查系统状态...</span>
      </div>
    );
  }

  if (!systemStatus) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <span className="text-gray-500">❓</span>
        <span className="text-sm text-gray-600">无法获取系统状态</span>
      </div>
    );
  }

  const allServicesHealthy = systemStatus.backend.status === 'healthy' && 
                            systemStatus.mlService.status === 'healthy';

  return (
    <div className={`${className}`}>
      {!showDetails ? (
        // 简化视图
        <div className="flex items-center space-x-2">
          <span>{allServicesHealthy ? '🟢' : '🟡'}</span>
          <span className="text-sm">
            系统{allServicesHealthy ? '正常' : '部分异常'}
          </span>
        </div>
      ) : (
        // 详细视图
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-lg font-semibold">系统状态</h3>
            <button
              onClick={checkSystemStatus}
              className="text-blue-500 hover:text-blue-600 text-sm"
              disabled={isLoading}
            >
              {isLoading ? '检查中...' : '刷新'}
            </button>
          </div>
          
          <div className="space-y-3">
            {/* 后端服务状态 */}
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <span>{getStatusIcon(systemStatus.backend.status)}</span>
                <span className="text-sm font-medium">后端服务</span>
              </div>
              <span className={`text-sm ${getStatusColor(systemStatus.backend.status)}`}>
                {getStatusText(systemStatus.backend.status)}
              </span>
            </div>
            
            {systemStatus.backend.error && (
              <div className="ml-6 text-xs text-red-500 bg-red-50 p-2 rounded">
                {systemStatus.backend.error}
              </div>
            )}

            {/* ML服务状态 */}
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <span>{getStatusIcon(systemStatus.mlService.status)}</span>
                <span className="text-sm font-medium">AI推荐服务</span>
              </div>
              <span className={`text-sm ${getStatusColor(systemStatus.mlService.status)}`}>
                {getStatusText(systemStatus.mlService.status)}
              </span>
            </div>
            
            {systemStatus.mlService.error && (
              <div className="ml-6 text-xs text-red-500 bg-red-50 p-2 rounded">
                {systemStatus.mlService.error}
              </div>
            )}
          </div>
          
          <div className="mt-4 pt-3 border-t text-xs text-gray-500">
            最后检查: {new Date(systemStatus.timestamp).toLocaleString()}
          </div>
        </div>
      )}
    </div>
  );
};

export default SystemStatus;
