// 数据同步管理器
// 处理在线/离线数据同步，确保用户体验的连续性

interface SyncQueueItem {
  id: string;
  type: 'CREATE' | 'UPDATE' | 'DELETE';
  endpoint: string;
  data?: any;
  recordId?: number;
  timestamp: number;
  retryCount: number;
}

class DataSyncManager {
  private syncQueue: SyncQueueItem[] = [];
  private isOnline: boolean = navigator.onLine;
  private isSyncing: boolean = false;
  private maxRetries: number = 3;
  private syncInterval: number = 30000; // 30秒

  constructor() {
    this.loadSyncQueue();
    this.setupEventListeners();
    this.startSyncTimer();
  }

  private setupEventListeners() {
    window.addEventListener('online', () => {
      this.isOnline = true;
      this.processSyncQueue();
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
    });
  }

  private startSyncTimer() {
    setInterval(() => {
      if (this.isOnline && this.syncQueue.length > 0) {
        this.processSyncQueue();
      }
    }, this.syncInterval);
  }

  private loadSyncQueue() {
    try {
      const stored = localStorage.getItem('syncQueue');
      if (stored) {
        this.syncQueue = JSON.parse(stored);
      }
    } catch (error) {
      console.error('加载同步队列失败:', error);
      this.syncQueue = [];
    }
  }

  private saveSyncQueue() {
    try {
      localStorage.setItem('syncQueue', JSON.stringify(this.syncQueue));
    } catch (error) {
      console.error('保存同步队列失败:', error);
    }
  }

  // 添加操作到同步队列
  addToSyncQueue(
    type: 'CREATE' | 'UPDATE' | 'DELETE',
    endpoint: string,
    data?: any,
    recordId?: number
  ): string {
    const id = `sync_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const item: SyncQueueItem = {
      id,
      type,
      endpoint,
      data,
      recordId,
      timestamp: Date.now(),
      retryCount: 0
    };

    this.syncQueue.push(item);
    this.saveSyncQueue();

    // 如果在线，立即尝试同步
    if (this.isOnline) {
      this.processSyncQueue();
    }

    return id;
  }

  // 处理同步队列
  private async processSyncQueue() {
    if (this.isSyncing || !this.isOnline || this.syncQueue.length === 0) {
      return;
    }

    this.isSyncing = true;
    console.log(`开始处理同步队列，共 ${this.syncQueue.length} 项`);

    const failedItems: SyncQueueItem[] = [];
    
    for (const item of this.syncQueue) {
      try {
        await this.syncItem(item);
        console.log(`同步成功: ${item.type} ${item.endpoint}`);
      } catch (error) {
        console.error(`同步失败: ${item.type} ${item.endpoint}`, error);
        
        item.retryCount++;
        if (item.retryCount < this.maxRetries) {
          failedItems.push(item);
        } else {
          console.error(`同步项目达到最大重试次数，丢弃: ${item.id}`);
        }
      }
    }

    this.syncQueue = failedItems;
    this.saveSyncQueue();
    this.isSyncing = false;

    console.log(`同步完成，剩余 ${this.syncQueue.length} 项待同步`);
  }

  private async syncItem(item: SyncQueueItem): Promise<void> {
    const { default: api } = await import('./api');
    
    switch (item.type) {
      case 'CREATE':
        await api.post(item.endpoint, item.data);
        break;
      case 'UPDATE':
        await api.put(`${item.endpoint}/${item.recordId}`, item.data);
        break;
      case 'DELETE':
        await api.delete(`${item.endpoint}/${item.recordId}`);
        break;
    }
  }

  // 获取同步状态
  getSyncStatus() {
    return {
      isOnline: this.isOnline,
      isSyncing: this.isSyncing,
      queueLength: this.syncQueue.length,
      lastSyncTime: this.syncQueue.length > 0 ? 
        Math.max(...this.syncQueue.map(item => item.timestamp)) : null
    };
  }

  // 手动触发同步
  async forcSync(): Promise<boolean> {
    if (!this.isOnline) {
      throw new Error('当前处于离线状态，无法同步');
    }

    await this.processSyncQueue();
    return this.syncQueue.length === 0;
  }

  // 清空同步队列（用于测试或重置）
  clearSyncQueue() {
    this.syncQueue = [];
    this.saveSyncQueue();
  }
}

// 创建全局实例
export const dataSyncManager = new DataSyncManager();

// 离线数据存储管理
export class OfflineDataManager {
  private storageKey = 'offlineData';

  // 保存离线数据
  saveOfflineData(key: string, data: any) {
    try {
      const offlineData = this.getOfflineDataStore();
      offlineData[key] = {
        data,
        timestamp: Date.now(),
        synced: false
      };
      localStorage.setItem(this.storageKey, JSON.stringify(offlineData));
    } catch (error) {
      console.error('保存离线数据失败:', error);
    }
  }

  // 获取离线数据
  getOfflineData(key: string): any {
    try {
      const offlineData = this.getOfflineDataStore();
      return offlineData[key]?.data || null;
    } catch (error) {
      console.error('获取离线数据失败:', error);
      return null;
    }
  }

  // 获取所有离线数据
  getAllOfflineData(): { [key: string]: any } {
    try {
      const offlineData = this.getOfflineDataStore();
      const result: { [key: string]: any } = {};
      
      Object.keys(offlineData).forEach(key => {
        result[key] = offlineData[key].data;
      });
      
      return result;
    } catch (error) {
      console.error('获取所有离线数据失败:', error);
      return {};
    }
  }

  // 标记数据已同步
  markAsSynced(key: string) {
    try {
      const offlineData = this.getOfflineDataStore();
      if (offlineData[key]) {
        offlineData[key].synced = true;
        localStorage.setItem(this.storageKey, JSON.stringify(offlineData));
      }
    } catch (error) {
      console.error('标记同步状态失败:', error);
    }
  }

  // 删除离线数据
  removeOfflineData(key: string) {
    try {
      const offlineData = this.getOfflineDataStore();
      delete offlineData[key];
      localStorage.setItem(this.storageKey, JSON.stringify(offlineData));
    } catch (error) {
      console.error('删除离线数据失败:', error);
    }
  }

  // 清空所有离线数据
  clearOfflineData() {
    try {
      localStorage.removeItem(this.storageKey);
    } catch (error) {
      console.error('清空离线数据失败:', error);
    }
  }

  private getOfflineDataStore(): any {
    try {
      const stored = localStorage.getItem(this.storageKey);
      return stored ? JSON.parse(stored) : {};
    } catch (error) {
      console.error('读取离线数据存储失败:', error);
      return {};
    }
  }
}

// 创建离线数据管理器实例
export const offlineDataManager = new OfflineDataManager();

// 智能API调用器 - 自动处理在线/离线状态
export class SmartApiCaller {
  constructor(
    private syncManager: DataSyncManager,
    private offlineManager: OfflineDataManager
  ) {}

  // 智能创建操作
  async smartCreate(endpoint: string, data: any, offlineKey?: string): Promise<any> {
    try {
      // 尝试在线操作
      const { default: api } = await import('./api');
      const response = await api.post(endpoint, data);
      
      // 成功后清除离线数据
      if (offlineKey) {
        this.offlineManager.removeOfflineData(offlineKey);
      }
      
      return response;
    } catch (error) {
      console.warn('在线创建失败，转为离线模式:', error);
      
      // 添加到同步队列
      const syncId = this.syncManager.addToSyncQueue('CREATE', endpoint, data);
      
      // 保存到离线存储
      if (offlineKey) {
        this.offlineManager.saveOfflineData(offlineKey, { ...data, _syncId: syncId });
      }
      
      // 返回模拟响应
      return {
        code: 200,
        msg: '已保存到本地，将在网络恢复后同步',
        data: { ...data, id: Date.now(), _offline: true, _syncId: syncId }
      };
    }
  }

  // 智能更新操作
  async smartUpdate(endpoint: string, id: number, data: any, offlineKey?: string): Promise<any> {
    try {
      // 尝试在线操作
      const { default: api } = await import('./api');
      const response = await api.put(`${endpoint}/${id}`, data);
      
      // 成功后清除离线数据
      if (offlineKey) {
        this.offlineManager.removeOfflineData(offlineKey);
      }
      
      return response;
    } catch (error) {
      console.warn('在线更新失败，转为离线模式:', error);
      
      // 添加到同步队列
      const syncId = this.syncManager.addToSyncQueue('UPDATE', endpoint, data, id);
      
      // 保存到离线存储
      if (offlineKey) {
        this.offlineManager.saveOfflineData(offlineKey, { ...data, _syncId: syncId });
      }
      
      // 返回模拟响应
      return {
        code: 200,
        msg: '已保存到本地，将在网络恢复后同步',
        data: { ...data, id, _offline: true, _syncId: syncId }
      };
    }
  }

  // 智能删除操作
  async smartDelete(endpoint: string, id: number, offlineKey?: string): Promise<any> {
    try {
      // 尝试在线操作
      const { default: api } = await import('./api');
      const response = await api.delete(`${endpoint}/${id}`);
      
      // 成功后清除离线数据
      if (offlineKey) {
        this.offlineManager.removeOfflineData(offlineKey);
      }
      
      return response;
    } catch (error) {
      console.warn('在线删除失败，转为离线模式:', error);
      
      // 添加到同步队列
      this.syncManager.addToSyncQueue('DELETE', endpoint, undefined, id);
      
      // 标记为已删除
      if (offlineKey) {
        this.offlineManager.saveOfflineData(offlineKey, { _deleted: true, _deletedAt: Date.now() });
      }
      
      // 返回模拟响应
      return {
        code: 200,
        msg: '已标记删除，将在网络恢复后同步',
        data: null
      };
    }
  }
}

// 创建智能API调用器实例
export const smartApiCaller = new SmartApiCaller(dataSyncManager, offlineDataManager);

export default dataSyncManager;
