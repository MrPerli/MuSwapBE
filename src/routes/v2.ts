import { Router } from 'express';
import { proxyQuotesLatest } from '../controllers/cryptocurrency.controller';

const router = Router();

router.get('/cryptocurrency/quotes/latest', proxyQuotesLatest);

export default router;
