import { createApp } from './app.js';
import { attachClaimsSocket } from './modules/claims/claims.socket.js';

const port = Number(process.env.PORT ?? 3000);

const server = createApp().listen(port, () => {
  console.log(`API démarrée sur le port ${port}`);
});

attachClaimsSocket(server);
