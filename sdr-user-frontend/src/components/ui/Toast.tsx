// 现代化 Toast 通知组件
import React, { useState, useEffect, createContext, useContext, useCallback } from 'react';

// Toast 类型
type ToastType = 'success' | 'error' | 'warning' | 'info';

interface Toast {
    id: string;
    type: ToastType;
    message: string;
    duration?: number;
}

interface ToastContextType {
    showToast: (type: ToastType, message: string, duration?: number) => void;
    showConfirm: (message: string, onConfirm: () => void, onCancel?: () => void) => void;
}

const ToastContext = createContext<ToastContextType | null>(null);

// Toast 提供者组件
export const ToastProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [toasts, setToasts] = useState<Toast[]>([]);
    const [confirmDialog, setConfirmDialog] = useState<{
        message: string;
        onConfirm: () => void;
        onCancel?: () => void;
    } | null>(null);

    const showToast = useCallback((type: ToastType, message: string, duration = 3000) => {
        const id = Math.random().toString(36).substr(2, 9);
        setToasts(prev => [...prev, { id, type, message, duration }]);
    }, []);

    const removeToast = useCallback((id: string) => {
        setToasts(prev => prev.filter(t => t.id !== id));
    }, []);

    const showConfirm = useCallback((message: string, onConfirm: () => void, onCancel?: () => void) => {
        setConfirmDialog({ message, onConfirm, onCancel });
    }, []);

    const handleConfirm = () => {
        confirmDialog?.onConfirm();
        setConfirmDialog(null);
    };

    const handleCancel = () => {
        confirmDialog?.onCancel?.();
        setConfirmDialog(null);
    };

    const getToastConfig = (type: ToastType) => {
        switch (type) {
            case 'success':
                return { bg: '#10b981', icon: '✓', label: '成功' };
            case 'error':
                return { bg: '#ef4444', icon: '✕', label: '错误' };
            case 'warning':
                return { bg: '#f59e0b', icon: '⚠', label: '警告' };
            case 'info':
                return { bg: '#3b82f6', icon: 'ℹ', label: '提示' };
        }
    };

    return (
        <ToastContext.Provider value={{ showToast, showConfirm }}>
            {children}

            {/* Toast 容器 - 使用 portal 级别的 z-index */}
            <div style={{
                position: 'fixed',
                top: '20px',
                right: '20px',
                zIndex: 99999,
                display: 'flex',
                flexDirection: 'column',
                gap: '12px'
            }}>
                {toasts.map(toast => {
                    const config = getToastConfig(toast.type);
                    return (
                        <ToastItem
                            key={toast.id}
                            toast={toast}
                            onClose={() => removeToast(toast.id)}
                            config={config}
                        />
                    );
                })}
            </div>

            {/* 确认对话框 - 使用 portal 级别的 z-index */}
            {confirmDialog && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    backgroundColor: 'rgba(0,0,0,0.5)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 99999,
                    padding: '20px'
                }}>
                    <div style={{
                        backgroundColor: 'white',
                        borderRadius: '16px',
                        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
                        maxWidth: '400px',
                        width: '100%',
                        padding: '24px'
                    }}>
                        <div style={{ textAlign: 'center', marginBottom: '24px' }}>
                            <div style={{
                                width: '64px',
                                height: '64px',
                                backgroundColor: '#fef3c7',
                                borderRadius: '50%',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                margin: '0 auto 16px',
                                fontSize: '28px'
                            }}>
                                🤔
                            </div>
                            <h3 style={{
                                fontSize: '20px',
                                fontWeight: 'bold',
                                color: '#111827',
                                marginBottom: '8px'
                            }}>
                                确认操作
                            </h3>
                            <p style={{ color: '#6b7280', fontSize: '16px' }}>
                                {confirmDialog.message}
                            </p>
                        </div>
                        <div style={{ display: 'flex', gap: '12px' }}>
                            <button
                                onClick={handleCancel}
                                style={{
                                    flex: 1,
                                    padding: '12px 24px',
                                    backgroundColor: '#f3f4f6',
                                    color: '#374151',
                                    border: 'none',
                                    borderRadius: '12px',
                                    fontSize: '16px',
                                    fontWeight: 500,
                                    cursor: 'pointer'
                                }}
                            >
                                取消
                            </button>
                            <button
                                onClick={handleConfirm}
                                style={{
                                    flex: 1,
                                    padding: '12px 24px',
                                    backgroundColor: '#ef4444',
                                    color: 'white',
                                    border: 'none',
                                    borderRadius: '12px',
                                    fontSize: '16px',
                                    fontWeight: 'bold',
                                    cursor: 'pointer'
                                }}
                            >
                                确认
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </ToastContext.Provider>
    );
};

// 单个 Toast 项
const ToastItem: React.FC<{
    toast: Toast;
    onClose: () => void;
    config: { bg: string; icon: string; label: string };
}> = ({ toast, onClose, config }) => {
    useEffect(() => {
        const timer = setTimeout(onClose, toast.duration || 3000);
        return () => clearTimeout(timer);
    }, [toast.duration, onClose]);

    return (
        <div style={{
            backgroundColor: config.bg,
            color: 'white',
            padding: '16px 20px',
            borderRadius: '12px',
            boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            minWidth: '280px',
            maxWidth: '400px',
            animation: 'slideInRight 0.3s ease-out'
        }}>
            <div style={{
                width: '32px',
                height: '32px',
                backgroundColor: 'rgba(255,255,255,0.2)',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 'bold',
                fontSize: '16px',
                flexShrink: 0
            }}>
                {config.icon}
            </div>
            <span style={{ flex: 1, fontWeight: 500, fontSize: '15px' }}>
                {toast.message}
            </span>
            <button
                onClick={onClose}
                style={{
                    background: 'none',
                    border: 'none',
                    color: 'rgba(255,255,255,0.7)',
                    cursor: 'pointer',
                    fontSize: '18px',
                    padding: '0',
                    lineHeight: 1
                }}
            >
                ✕
            </button>
        </div>
    );
};

// Hook 使用 Toast
export const useToast = (): ToastContextType => {
    const context = useContext(ToastContext);
    if (!context) {
        throw new Error('useToast must be used within ToastProvider');
    }
    return context;
};

// 便捷导出
export default ToastProvider;

