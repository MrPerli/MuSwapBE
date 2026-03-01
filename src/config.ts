import dotenv from 'dotenv';
import path from 'path';

// 加载 .env 文件（从当前文件所在目录向上查找）
dotenv.config({ path: path.join(__dirname, '../.env') });

// 导出配置对象
export const config = {
  cmcApiKey: process.env.CMC_API_KEY,
  port: process.env.PORT || 3000,
};

// 可选：立即检查关键配置是否存在
if (!config.cmcApiKey) {
  throw new Error('CMC_API_KEY environment variable is not set');
}