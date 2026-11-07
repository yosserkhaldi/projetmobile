import { createApp } from './app.js';
import { assertAuthConfig } from './lib/tokens.js';

assertAuthConfig();

const port = Number(process.env.PORT ?? 3000);

createApp().listen(port, () => {
  console.log(`API démarrée sur le port ${port}`);
});
