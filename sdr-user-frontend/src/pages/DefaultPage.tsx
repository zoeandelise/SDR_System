import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

interface DefaultPageProps {
  title: string;
  description: string;
  icon: string;
}

const DefaultPage: React.FC<DefaultPageProps> = ({ title, description, icon }) => {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
        <p className="text-gray-600 mt-1">{description}</p>
      </div>

      {/* Coming Soon Card */}
      <Card>
        <CardContent className="p-12 text-center">
          <div className="text-6xl mb-6">{icon}</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">功能开发中</h2>
          <p className="text-gray-600 mb-6 max-w-md mx-auto">
            这个功能正在紧锣密鼓地开发中，很快就会与您见面！
            感谢您的耐心等待。
          </p>
          <div className="space-y-4">
            <Button className="mr-4">返回首页</Button>
            <Button variant="outline">联系客服</Button>
          </div>
        </CardContent>
      </Card>

      {/* Feature Preview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-center">🎯 智能化</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-gray-600">
              基于AI算法，为您提供个性化的健康建议和营养方案
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader>
            <CardTitle className="text-center">📊 数据化</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-gray-600">
              详细的数据分析和可视化图表，让健康状况一目了然
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader>
            <CardTitle className="text-center">🤝 社交化</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-gray-600">
              与朋友分享健康心得，互相督促，共同进步
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default DefaultPage;
