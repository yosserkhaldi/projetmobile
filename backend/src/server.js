import { createApp } from './app.js';
import { assertAuthConfig } from './lib/tokens.js';
import { attachClaimsSocket } from './modules/claims/claims.socket.js';

assertAuthConfig();

const port = Number(process.env.PORT ?? 3000);

const server = createApp().listen(port, () => {
  console.log(`API démarrée sur le port ${port}`);
});

attachClaimsSocket(server);
