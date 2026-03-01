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
