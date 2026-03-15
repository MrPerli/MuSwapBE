import { Request, Response, NextFunction } from 'express';
import uniswapProxyService from '../services/uniswapProxy.service';

export const proxyUniswapQuote = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await uniswapProxyService.proxyQuote(req.body, req.query);
    res.status(result.status).json(result.data);
  } catch (error) {
    next(error);
  }
};

