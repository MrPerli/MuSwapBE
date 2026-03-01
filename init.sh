#!/bin/bash
set -e  # 遇到错误立即退出

echo "开始创建项目文件..."

# 创建所需目录
mkdir -p api
mkdir -p src/controllers src/routes src/services src/middlewares src/utils

# -------------------- 根目录文件 --------------------
# .env.example
cat > .env.example << 'EOF'
CMC_API_KEY=4ba3baf2adb643fda1c2cfa9ec97f0c6
PORT=3000
EOF
echo "✓ 创建 .env.example"

# .gitignore
cat > .gitignore << 'EOF'
node_modules/
dist/
.env
.DS_Store
vercel/.env
*.log
EOF
echo "✓ 创建 .gitignore"

# package.json
cat > package.json << 'EOF'
{
  "name": "cmc-proxy",
  "version": "1.0.0",
  "description": "CoinMarketCap API proxy service",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "vercel-build": "npm run build"
  },
  "dependencies": {
    "axios": "^1.7.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/node": "^20.14.2",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.4.5"
  }
}
EOF
echo "✓ 创建 package.json"

# tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
echo "✓ 创建 tsconfig.json"

# vercel.json
cat > vercel.json << 'EOF'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/api/index" }
  ],
  "builds": [
    {
      "src": "api/index.ts",
      "use": "@vercel/node"
    }
  ]
}
EOF
echo "✓ 创建 vercel.json"

# -------------------- api/index.ts --------------------
cat > api/index.ts << 'EOF'
import app from '../src/app';

export default app;
EOF
echo "✓ 创建 api/index.ts"

# -------------------- src/index.ts --------------------
cat > src/index.ts << 'EOF'
import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
EOF
echo "✓ 创建 src/index.ts"

# -------------------- src/app.ts --------------------
cat > src/app.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import routes from './routes';
import errorHandler from './middlewares/errorHandler';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/', routes);

app.use(errorHandler);

export default app;
EOF
echo "✓ 创建 src/app.ts"

# -------------------- src/controllers/cryptocurrency.controller.ts --------------------
cat > src/controllers/cryptocurrency.controller.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import cmcProxyService from '../services/cmcProxy.service';

export const proxyMap = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await cmcProxyService.proxyGet('/v1/cryptocurrency/map', req.query);
    res.status(result.status).json(result.data);
  } catch (error) {
    next(error);
  }
};

export const proxyQuotesLatest = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await cmcProxyService.proxyGet('/v2/cryptocurrency/quotes/latest', req.query);
    res.status(result.status).json(result.data);
  } catch (error) {
    next(error);
  }
};
EOF
echo "✓ 创建 src/controllers/cryptocurrency.controller.ts"

# -------------------- src/routes/v1.ts --------------------
cat > src/routes/v1.ts << 'EOF'
import { Router } from 'express';
import { proxyMap } from '../controllers/cryptocurrency.controller';

const router = Router();

router.get('/cryptocurrency/map', proxyMap);

export default router;
EOF
echo "✓ 创建 src/routes/v1.ts"

# -------------------- src/routes/v2.ts --------------------
cat > src/routes/v2.ts << 'EOF'
import { Router } from 'express';
import { proxyQuotesLatest } from '../controllers/cryptocurrency.controller';

const router = Router();

router.get('/cryptocurrency/quotes/latest', proxyQuotesLatest);

export default router;
EOF
echo "✓ 创建 src/routes/v2.ts"

# -------------------- src/routes/index.ts --------------------
cat > src/routes/index.ts << 'EOF'
import { Router } from 'express';
import v1Routes from './v1';
import v2Routes from './v2';

const router = Router();

router.use('/v1', v1Routes);
router.use('/v2', v2Routes);

export default router;
EOF
echo "✓ 创建 src/routes/index.ts"

# -------------------- src/services/cmcProxy.service.ts --------------------
cat > src/services/cmcProxy.service.ts << 'EOF'
import axios, { AxiosInstance, AxiosError } from 'axios';

class CMCProxyService {
  private client: AxiosInstance;

  constructor() {
    const apiKey = process.env.CMC_API_KEY;
    if (!apiKey) {
      throw new Error('CMC_API_KEY environment variable is not set');
    }

    this.client = axios.create({
      baseURL: 'https://pro-api.coinmarketcap.com',
      headers: {
        'X-CMC_PRO_API_KEY': apiKey,
        'Accept': 'application/json',
      },
      timeout: 10000,
    });
  }

  async proxyGet(path: string, params: any) {
    try {
      const response = await this.client.get(path, { params });
      return {
        data: response.data,
        status: response.status,
        headers: response.headers,
      };
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError;
        if (axiosError.response) {
          return {
            data: axiosError.response.data,
            status: axiosError.response.status,
            headers: axiosError.response.headers,
          };
        }
        throw new Error(`Network error: ${axiosError.message}`);
      }
      throw error;
    }
  }
}

export default new CMCProxyService();
EOF
echo "✓ 创建 src/services/cmcProxy.service.ts"

# -------------------- src/middlewares/errorHandler.ts --------------------
cat > src/middlewares/errorHandler.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';

export default function errorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.error('Error:', err.message || err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
}
EOF
echo "✓ 创建 src/middlewares/errorHandler.ts"

# -------------------- src/utils/logger.ts (可选) --------------------
cat > src/utils/logger.ts << 'EOF'
export const logInfo = (message: string) => {
  console.log(`[INFO] ${new Date().toISOString()} - ${message}`);
};

export const logError = (message: string) => {
  console.error(`[ERROR] ${new Date().toISOString()} - ${message}`);
};
EOF
echo "✓ 创建 src/utils/logger.ts"

echo "所有文件创建完成！"
echo "接下来请运行 'npm install' 安装依赖，并根据需要配置环境变量。"