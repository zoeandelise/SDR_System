import React from 'react';
import SimpleRouter from './router/SimpleRouter';
import { ToastProvider } from './components/ui/Toast';
import './index.css';

function App() {
  return (
    <ToastProvider>
      <SimpleRouter />
    </ToastProvider>
  );
}

export default App;