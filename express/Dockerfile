FROM node:22-slim

RUN apt-get update -qq && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build
RUN npx prisma generate

EXPOSE 3000
ENV DATABASE_URL="file:./dev.db"
CMD ["sh", "-c", "npx prisma db push && node dist/server.js"]
