import { Server } from 'socket.io';

import { identify } from './claims.auth.js';

let io;

// Mises à jour en direct. L'événement dit seulement quoi recharger.
export function attachClaimsSocket(httpServer) {
  io = new Server(httpServer, {
    path: '/api/claims/socket',
    cors: { origin: '*' },
  });
  io.use((socket, next) => {
    try {
      socket.user = identify(socket.handshake.auth ?? {});
      next();
    } catch (error) {
      next(error);
    }
  });
  io.on('connection', (socket) => {
    socket.join(`user:${socket.user.id}`);
    socket.join(`role:${socket.user.role}`);
  });
  return io;
}

export function announceChange(claim) {
  io?.to('role:agent').to(`user:${claim.driverId}`).emit('claims:changed', {
    claimId: claim.id,
  });
}
