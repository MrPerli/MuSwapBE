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
