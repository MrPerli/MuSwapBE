import axios, { AxiosInstance, AxiosError } from 'axios';
import { config } from '../config'; // 导入配置

class CMCProxyService {
  private client: AxiosInstance;

  constructor() {
    const apiKey = config.cmcApiKey; // 直接从配置获取
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