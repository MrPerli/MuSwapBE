import { Router } from 'express';
import { proxyMap } from '../controllers/cryptocurrency.controller';
import { proxyUniswapQuote } from '../controllers/uniswap.controller';

const router = Router();

router.get('/cryptocurrency/map', proxyMap);
router.post('/uniswap/quote', proxyUniswapQuote);

export default router;
