## 1. Установка зависимостей

```bash
npm install --save-dev \
  eslint \
  @eslint/js \
  typescript-eslint \
  eslint-config-prettier \
  prettier \
  husky \
  lint-staged \
  vitest \
  @vitest/coverage-v8
```

## 2. Scripts в `package.json`

```json
{
  "scripts": {
    "dev": "tsx watch --clear-screen=false src/main.ts",
    "build": "tsup",
    "start": "node dist/main.js",
    "typecheck": "tsc --noEmit",

    "lint": "eslint .",
    "lint:fix": "eslint . --fix",

    "format": "prettier . --write",
    "format:check": "prettier . --check",

    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",

    "verify": "npm run typecheck && npm run lint && npm run format:check && npm run test",

    "prepare": "husky"
  }
}
```

## 3. ESLint

Создай `eslint.config.js`:

```js
import eslint from '@eslint/js'
import prettier from 'eslint-config-prettier'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  {
    ignores: [
      'dist/**',
      'coverage/**',
      'node_modules/**',
      '*.config.js'
    ]
  },

  eslint.configs.recommended,

  ...tseslint.configs.recommendedTypeChecked,

  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname
      }
    },

    rules: {
      '@typescript-eslint/consistent-type-imports': [
        'error',
        {
          prefer: 'type-imports'
        }
      ],

      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      '@typescript-eslint/no-explicit-any': 'error'
    }
  },

  prettier
)
```

Проверка:

```bash
npm run lint
```

## 4. Prettier

Создай `prettier.config.js`:

```js
export default {
  semi: false,
  singleQuote: true,
  trailingComma: 'none',
  tabWidth: 2,
  useTabs: false,
  printWidth: 80,
  arrowParens: 'always',
  endOfLine: 'lf'
}
```

Создай `.prettierignore`:

```text
node_modules
dist
coverage
package-lock.json
*.log
.env
.env.*
```

Проверка:

```bash
npm run format
npm run format:check
```

## 5. EditorConfig

Создай `.editorconfig`:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

## 6. Git ignore

Создай `.gitignore`:

```gitignore
node_modules/
dist/
coverage/

.env
.env.*
!.env.example
!.env.development.example
!.env.production.example

*.log
npm-debug.log*

.DS_Store
Thumbs.db

.vscode/*
!.vscode/settings.json
!.vscode/extensions.json

.idea/

tmp/
temp/
```

## 7. Docker ignore

Создай `.dockerignore`:

```dockerignore
node_modules
dist
coverage

.git
.gitignore
.husky

.vscode
.idea

.env
.env.*

*.log

README.md
docs
tests
```

## 8. VS Code

Создай `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,

  "editor.defaultFormatter": "esbenp.prettier-vscode",

  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },

  "eslint.useFlatConfig": true,

  "files.eol": "\n",

  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

Создай `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "editorconfig.editorconfig"
  ]
}
```

Форматирование будет выполняться при сохранении файла через `Ctrl + S`.

## 9. Vitest

Создай `vitest.config.ts`:

```ts
import { fileURLToPath } from 'node:url'

import { defineConfig } from 'vitest/config'

export default defineConfig({
  resolve: {
    alias: {
      '~': fileURLToPath(new URL('./src', import.meta.url))
    }
  },

  test: {
    environment: 'node',

    include: [
      'src/**/*.spec.ts',
      'src/**/*.test.ts',
      'tests/**/*.spec.ts',
      'tests/**/*.test.ts'
    ],

    coverage: {
      provider: 'v8',
      reportsDirectory: 'coverage',
      reporter: ['text', 'html', 'json']
    }
  }
})
```

Создай тест:

```bash
mkdir -p tests
touch tests/smoke.test.ts
```

`tests/smoke.test.ts`:

```ts
import { describe, expect, it } from 'vitest'

describe('application', () => {
  it('runs tests', () => {
    expect(true).toBe(true)
  })
})
```

Проверка:

```bash
npm run test
```

## 10. Husky

Инициализация:

```bash
npm run prepare
mkdir -p .husky
```

Создай `.husky/pre-commit`:

```sh
npx lint-staged
```

Создай `.husky/pre-push`:

```sh
npm run verify
```

Права:

```bash
chmod +x .husky/pre-commit
chmod +x .husky/pre-push
```

Создай `lint-staged.config.js`:

```js
export default {
  '*.{ts,tsx,js,mjs,cjs}': ['eslint --fix', 'prettier --write'],

  '*.{json,md,yml,yaml}': ['prettier --write']
}
```

Поведение:

```text
pre-commit:
  ESLint и Prettier только для staged-файлов

pre-push:
  TypeScript
  ESLint
  Prettier check
  Vitest
```

## 11. Environment-файлы

Создай `.env.development`:

```dotenv
NODE_ENV=development
PORT=3000

POSTGRES_USER=payex
POSTGRES_PASSWORD=payex
POSTGRES_DB=payex_billing
POSTGRES_PORT=5432
DATABASE_URL=postgresql://payex:payex@postgres:5432/payex_billing

REDIS_PORT=6379
REDIS_URL=redis://redis:6379

RABBITMQ_DEFAULT_USER=payex
RABBITMQ_DEFAULT_PASS=payex
RABBITMQ_AMQP_PORT=5672
RABBITMQ_MANAGEMENT_PORT=15672
RABBITMQ_URL=amqp://payex:payex@rabbitmq:5672
```

Создай `.env.production`:

```dotenv
NODE_ENV=production
PORT=3000

POSTGRES_USER=payex
POSTGRES_PASSWORD=replace-this-password
POSTGRES_DB=payex_billing
POSTGRES_PORT=5432
DATABASE_URL=postgresql://payex:replace-this-password@postgres:5432/payex_billing

REDIS_PORT=6379
REDIS_URL=redis://redis:6379

RABBITMQ_DEFAULT_USER=payex
RABBITMQ_DEFAULT_PASS=replace-this-password
RABBITMQ_AMQP_PORT=5672
RABBITMQ_MANAGEMENT_PORT=15672
RABBITMQ_URL=amqp://payex:replace-this-password@rabbitmq:5672
```

Эти файлы не должны попадать в Git.

Создай шаблоны:

```bash
cp .env.development .env.development.example
cp .env.production .env.production.example
```

В `.example`-файлах пароли должны быть заменены на placeholders.

## 12. Dockerfile

Создай `Dockerfile`:

```dockerfile
FROM node:24-alpine AS base

WORKDIR /app

COPY package.json package-lock.json ./

FROM base AS development

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]

FROM base AS build

RUN npm ci

COPY . .

RUN npm run typecheck
RUN npm run build

FROM base AS production-dependencies

RUN npm ci --omit=dev

FROM node:24-alpine AS production

ENV NODE_ENV=production

WORKDIR /app

COPY --from=production-dependencies /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json package-lock.json ./

USER node

EXPOSE 3000

CMD ["node", "dist/main.js"]
```

## 13. Development Docker Compose

Создай `docker-compose.development.yml`:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: development

    env_file:
      - .env.development

    ports:
      - '3000:3000'

    volumes:
      - .:/app
      - app_node_modules:/app/node_modules

    depends_on:
      postgres:
        condition: service_healthy

      redis:
        condition: service_healthy

      rabbitmq:
        condition: service_healthy

  postgres:
    image: postgres:17-alpine

    env_file:
      - .env.development

    ports:
      - '5432:5432'

    volumes:
      - postgres_development_data:/var/lib/postgresql/data

    healthcheck:
      test:
        [
          'CMD-SHELL',
          'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}'
        ]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7-alpine

    ports:
      - '6379:6379'

    volumes:
      - redis_development_data:/data

    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 5s
      timeout: 5s
      retries: 10

  rabbitmq:
    image: rabbitmq:4-management-alpine

    env_file:
      - .env.development

    ports:
      - '5672:5672'
      - '15672:15672'

    volumes:
      - rabbitmq_development_data:/var/lib/rabbitmq

    healthcheck:
      test: ['CMD', 'rabbitmq-diagnostics', '-q', 'ping']
      interval: 5s
      timeout: 5s
      retries: 10

volumes:
  app_node_modules:
  postgres_development_data:
  redis_development_data:
  rabbitmq_development_data:
```

Запуск:

```bash
docker compose \
  --env-file .env.development \
  -f docker-compose.development.yml \
  up --build
```

Остановка:

```bash
docker compose \
  --env-file .env.development \
  -f docker-compose.development.yml \
  down
```

Полный сброс:

```bash
docker compose \
  --env-file .env.development \
  -f docker-compose.development.yml \
  down --volumes --remove-orphans
```

## 14. Production Docker Compose

Создай `docker-compose.production.yml`:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production

    env_file:
      - .env.production

    ports:
      - '3000:3000'

    restart: unless-stopped

    depends_on:
      postgres:
        condition: service_healthy

      redis:
        condition: service_healthy

      rabbitmq:
        condition: service_healthy

  postgres:
    image: postgres:17-alpine

    env_file:
      - .env.production

    restart: unless-stopped

    volumes:
      - postgres_production_data:/var/lib/postgresql/data

    healthcheck:
      test:
        [
          'CMD-SHELL',
          'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}'
        ]
      interval: 10s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7-alpine

    restart: unless-stopped

    volumes:
      - redis_production_data:/data

    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 10s
      timeout: 5s
      retries: 10

  rabbitmq:
    image: rabbitmq:4-management-alpine

    env_file:
      - .env.production

    restart: unless-stopped

    volumes:
      - rabbitmq_production_data:/var/lib/rabbitmq

    healthcheck:
      test: ['CMD', 'rabbitmq-diagnostics', '-q', 'ping']
      interval: 10s
      timeout: 5s
      retries: 10

volumes:
  postgres_production_data:
  redis_production_data:
  rabbitmq_production_data:
```

Запуск:

```bash
docker compose \
  --env-file .env.production \
  -f docker-compose.production.yml \
  up --build --detach
```

## 15. AI skills

Структура:

```text
.ai/
└── skills/
    ├── architecture-review/
    │   └── SKILL.md
    └── transport-contract/
        └── SKILL.md
```

Создание:

```bash
mkdir -p .ai/skills/architecture-review
mkdir -p .ai/skills/transport-contract
```

### `.ai/skills/architecture-review/SKILL.md`

```md
# Architecture Review

## Purpose

Review Payex Billing System code against project architecture.

## Rules

- Domain must not depend on Express, Drizzle, RabbitMQ or gRPC.
- Application services must depend on ports.
- Transport handlers must not contain business logic.
- Infrastructure implementations must satisfy explicit interfaces.
- Cross-module dependencies must be explicit.
- Circular dependencies are forbidden.

## Output

Return:

1. Violations.
2. File and line.
3. Reason.
4. Minimal correction.
```

### `.ai/skills/transport-contract/SKILL.md`

```md
# Transport Contract Review

## Purpose

Review HTTP, gRPC and RabbitMQ contracts.

## Rules

- Contracts must be versioned.
- Transport DTOs must not be domain entities.
- RabbitMQ consumers must be idempotent.
- Message metadata must contain messageId and correlationId.
- HTTP errors must have stable codes.
- gRPC errors must use documented status codes.
- Breaking changes must be explicitly identified.

## Output

Return:

1. Contract type.
2. Breaking changes.
3. Missing metadata.
4. Compatibility risks.
5. Required tests.
```

Использование:

```text
Read .ai/skills/architecture-review/SKILL.md and review src/modules/billing.
```

или:

```text
Apply .ai/skills/transport-contract/SKILL.md to the RabbitMQ contracts.
```

## 16. Итоговая проверка

```bash
npm run format
npm run typecheck
npm run lint
npm run test
npm run build
npm run verify
```

Итоговая структура:

```text
payex-billing-system/
├── .ai/
│   └── skills/
├── .husky/
│   ├── pre-commit
│   └── pre-push
├── .vscode/
│   ├── extensions.json
│   └── settings.json
├── src/
├── tests/
├── .dockerignore
├── .editorconfig
├── .env.development
├── .env.development.example
├── .env.production
├── .env.production.example
├── .gitignore
├── .nvmrc
├── .prettierignore
├── Dockerfile
├── docker-compose.development.yml
├── docker-compose.production.yml
├── eslint.config.js
├── lint-staged.config.js
├── prettier.config.js
├── tsconfig.json
├── tsup.config.ts
└── vitest.config.ts
```
