import { Router } from 'express';

import { requireAuth } from '../../middleware/auth.js';
import * as auth from './auth.service.js';
import {
  biometricLoginSchema,
  disableBiometricSchema,
  forgotPasswordSchema,
  loginSchema,
  refreshSchema,
  registerSchema,
  resetPasswordSchema,
  verifyPhoneSchema,
} from './users.schemas.js';

// Module 1 : inscription, connexion, OTP, mot de passe oublié.
const router = Router();

router.post('/register', async (req, res) => {
  res.status(201).json(await auth.register(registerSchema.parse(req.body)));
});

router.post('/login', async (req, res) => {
  res.json(await auth.login(loginSchema.parse(req.body)));
});

router.post('/refresh', async (req, res) => {
  const { refreshToken } = refreshSchema.parse(req.body);
  res.json(await auth.refresh(refreshToken));
});

router.post('/logout', async (req, res) => {
  const { refreshToken } = refreshSchema.parse(req.body);
  await auth.logout(refreshToken);
  res.status(204).end();
});

router.post('/phone/send', requireAuth, async (req, res) => {
  await auth.resendPhoneCode(req.user);
  res.status(204).end();
});

router.post('/phone/verify', requireAuth, async (req, res) => {
  const { code } = verifyPhoneSchema.parse(req.body);
  const user = await auth.verifyPhone(req.user, code);
  res.json({ user: auth.publicUser(user) });
});

router.post('/password/forgot', async (req, res) => {
  const { email } = forgotPasswordSchema.parse(req.body);
  await auth.forgotPassword(email);
  res.status(204).end();
});

router.post('/password/reset', async (req, res) => {
  await auth.resetPassword(resetPasswordSchema.parse(req.body));
  res.status(204).end();
});

router.post('/biometric', requireAuth, async (req, res) => {
  res.status(201).json(await auth.enableBiometric(req.user));
});

router.post('/biometric/login', async (req, res) => {
  const { deviceToken } = biometricLoginSchema.parse(req.body);
  res.json(await auth.biometricLogin(deviceToken));
});

router.delete('/biometric', requireAuth, async (req, res) => {
  const { deviceToken } = disableBiometricSchema.parse(req.body ?? {});
  await auth.disableBiometric(req.user, deviceToken);
  res.status(204).end();
});

export default router;
