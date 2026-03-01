import { Router } from 'express';
import { proxyMap } from '../controllers/cryptocurrency.controller';

const router = Router();

router.get('/cryptocurrency/map', proxyMap);

export default router;
