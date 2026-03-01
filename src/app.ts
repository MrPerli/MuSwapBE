import express from 'express';
import cors from 'cors';
import './config'; // 确保环境变量最先加载
import routes from './routes';
import errorHandler from './middlewares/errorHandler';

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/', routes);

app.use(errorHandler);

export default app;