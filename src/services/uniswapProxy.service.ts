import axios, { AxiosInstance, AxiosError } from 'axios';

class UniswapProxyService {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: 'https://trade-api.gateway.uniswap.org',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'x-api-key': 'VcLmLHFQF5xuuHUdZ2TgjI4xXV_NQXguM-pieIypHd4',
      },
      timeout: 10000,
    });
  }

  async proxyQuote(body: any, params?: any) {
    try {
      const response = await this.client.post('/v1/quote', body, { params });
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

export default new UniswapProxyService();

