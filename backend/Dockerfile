FROM node:22-alpine
WORKDIR /app
RUN apk add --no-cache openssl
COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
