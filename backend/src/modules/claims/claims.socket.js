import { Server } from 'socket.io';

import { identifySocket } from './claims.auth.js';

let io;

// Mises à jour en direct. L'événement dit seulement quoi recharger.
export function attachClaimsSocket(httpServer) {
  io = new Server(httpServer, {
    path: '/api/claims/socket',
    cors: { origin: '*' },
  });
  io.use(async (socket, next) => {
    try {
      socket.user = await identifySocket(socket.handshake.auth ?? {});
      next();
    } catch (error) {
      next(error);
    }
  });
  io.on('connection', (socket) => {
    socket.join(`user:${socket.user.id}`);
    socket.join(`role:${socket.user.role}`);
    if (socket.user.companyId) socket.join(`company:${socket.user.companyId}`);
  });
  return io;
}

// Les agents d'une autre compagnie ne sont pas prévenus. Un sinistre sans
// compagnie connue reste visible de tous les agents.
export function announceChange(claim) {
  const agents = claim.companyId ? `company:${claim.companyId}` : 'role:agent';
  io?.to(agents).to(`user:${claim.driverId}`).emit('claims:changed', {
    claimId: claim.id,
  });
}
