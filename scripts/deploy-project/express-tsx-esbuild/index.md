# Развертывание проекта Node.js на esbuild + tsx

Базовый runtime-контура:

1. Node.js 24 через NVM.
2. TypeScript в строгом режиме.
3. ESM.
4. Express.
5. Hot reload в development через `tsx watch`.
6. Production-сборка через `tsup`.
7. Алиас `~/`, работающий и в development, и после сборки.

Для backend это технически не полноценный browser-style HMR, а автоматический перезапуск процесса при изменении исходников. Для Express-сервиса это стандартный и предсказуемый вариант.

## Этап 1. Инициализация проекта

В корне нового репозитория:

```bash
npm init -y
```

Устанавливаем production-зависимость:

```bash
npm install express
```

Устанавливаем инструменты разработки:

```bash
npm install --save-dev \
  typescript \
  tsx \
  tsup \
  @types/node \
  @types/express
```

Назначение инструментов:

* `typescript` — проверка типов;
* `tsx` — запуск TypeScript без предварительной компиляции и watch-режим;
* `tsup` — production-бандлер на основе esbuild;
* `@types/node` — типы Node.js;
* `@types/express` — типы Express.

## Этап 2. Node.js 24

Создай файл `.nvmrc`:

```text
24
```

Затем выполни:

```bash
nvm install
nvm use
```

Проверка:

```bash
node --version
```

Ожидается версия:

```text
v24.x.x
```

Можно включить автоматическую смену Node.js при входе в директорию позже через shell hook, но для начала достаточно `nvm use`.

## Этап 3. Структура проекта

Создай директории и файлы:

```bash
mkdir -p src/config
touch src/app.ts
touch src/main.ts
touch src/config/env.ts
touch tsconfig.json
touch tsup.config.ts
```

На этом этапе структура будет такой:

```text
payex-billing-system/
├── src/
│   ├── config/
│   │   └── env.ts
│   ├── app.ts
│   └── main.ts
├── .nvmrc
├── package.json
├── package-lock.json
├── tsconfig.json
└── tsup.config.ts
```

## Этап 4. Настройка `package.json`

Добавь ESM-режим, требования к Node.js и scripts.

```json
{
  "name": "payex-billing-system",
  "version": "0.1.0",
  "private": true,
  "description": "Transport-independent billing service built with Express, PostgreSQL, Redis, RabbitMQ and gRPC.",
  "type": "module",
  "main": "./dist/main.js",
  "engines": {
    "node": ">=24.0.0"
  },
  "scripts": {
    "dev": "tsx watch --clear-screen=false src/main.ts",
    "build": "tsup",
    "start": "node dist/main.js",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^5.0.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/node": "^24.0.0",
    "tsx": "^4.0.0",
    "tsup": "^8.0.0",
    "typescript": "^5.0.0"
  }
}
```

Не копируй версии зависимостей поверх уже установленных без необходимости. После `npm install` npm сам запишет фактически установленные версии. Главное сейчас — добавить:

```json
"type": "module"
```

и scripts:

```json
{
  "scripts": {
    "dev": "tsx watch --clear-screen=false src/main.ts",
    "build": "tsup",
    "start": "node dist/main.js",
    "typecheck": "tsc --noEmit"
  }
}
```

Также добавь:

```json
{
  "private": true,
  "engines": {
    "node": ">=24.0.0"
  }
}
```

Можно сделать это командами:

```bash
npm pkg set private=true --json
npm pkg set type=module
npm pkg set main="./dist/main.js"
npm pkg set engines.node=">=24.0.0"

npm pkg set scripts.dev="tsx watch --clear-screen=false src/main.ts"
npm pkg set scripts.build="tsup"
npm pkg set scripts.start="node dist/main.js"
npm pkg set scripts.typecheck="tsc --noEmit"
```

## Этап 5. TypeScript

Создай `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2024",
    "lib": ["ES2024"],

    "module": "ESNext",
    "moduleResolution": "Bundler",
    "moduleDetection": "force",
    "verbatimModuleSyntax": true,

    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "useUnknownInCatchVariables": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,

    "baseUrl": ".",
    "paths": {
      "~/*": ["src/*"]
    },

    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,

    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,

    "types": ["node"],
    "skipLibCheck": true,
    "noEmit": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "coverage"]
}
```

Ключевые решения здесь:

```json
"module": "ESNext",
"moduleResolution": "Bundler"
```

Это позволяет писать современный ESM-код без необходимости добавлять `.js` к каждому внутреннему TypeScript-импорту:

```ts
import { createApp } from '~/app'
```

Вместо:

```ts
import { createApp } from './app.js'
```

Такой режим подходит, поскольку production-код будет проходить через бандлер.

Алиас задаётся здесь:

```json
"paths": {
  "~/*": ["src/*"]
}
```

Настройки декораторов добавлены заранее для будущего DI-контейнера:

```json
"experimentalDecorators": true,
"emitDecoratorMetadata": true
```

Это legacy-модель TypeScript-декораторов, которая подходит для constructor injection с `reflect-metadata`.

## Этап 6. Production-бандлер

Создай `tsup.config.ts`:

```ts
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/main.ts'],

  outDir: 'dist',

  format: ['esm'],
  platform: 'node',
  target: 'node24',

  bundle: true,
  splitting: false,
  treeshake: true,

  clean: true,
  sourcemap: true,
  minify: false,
  keepNames: true,

  tsconfig: 'tsconfig.json',

  outExtension() {
    return {
      js: '.js'
    }
  }
})
```

Здесь:

* `format: ['esm']` сохраняет ESM;
* `platform: 'node'` сообщает бандлеру, что код предназначен для Node.js;
* `target: 'node24'` позволяет использовать возможности Node.js 24;
* `bundle: true` собирает внутренние модули приложения;
* `sourcemap: true` позволяет видеть исходные `.ts`-строки в stack trace;
* `keepNames: true` сохраняет имена классов и функций, что понадобится для DI, логирования и диагностики.

`tsup` преобразует импорты через `~/` во время сборки. В итоговом `dist/main.js` не останется runtime-зависимости от TypeScript aliases.

Сторонние production-зависимости, такие как Express, обычно остаются внешними. Поэтому в production-контейнере позднее будут установлены только `dependencies`, без `devDependencies`.

## Этап 7. Конфигурация окружения

Пока сделаем простую конфигурацию без Zod. Валидацию env добавим вместе с `.env.development` и `.env.production`.

`src/config/env.ts`:

```ts
const DEFAULT_PORT = 3000

function parsePort(value: string | undefined): number {
  if (value === undefined) {
    return DEFAULT_PORT
  }

  const port = Number(value)

  if (!Number.isInteger(port) || port <= 0 || port > 65_535) {
    throw new Error(`Invalid PORT value: ${value}`)
  }

  return port
}

export const env = Object.freeze({
  nodeEnv: process.env.NODE_ENV ?? 'development',
  port: parsePort(process.env.PORT)
})
```

## Этап 8. Express-приложение

`src/app.ts`:

```ts
import express, {
  type Express,
  type NextFunction,
  type Request,
  type Response
} from 'express'

export function createApp(): Express {
  const app = express()

  app.disable('x-powered-by')

  app.use(express.json())

  app.get('/health', (_request: Request, response: Response) => {
    response.status(200).json({
      status: 'ok',
      service: 'payex-billing-system',
      timestamp: new Date().toISOString()
    })
  })

  app.use(
    (
      error: unknown,
      _request: Request,
      response: Response,
      _next: NextFunction
    ) => {
      console.error(error)

      response.status(500).json({
        error: {
          code: 'INTERNAL_SERVER_ERROR',
          message: 'An unexpected error occurred'
        }
      })
    }
  )

  return app
}
```

## Этап 9. Точка входа

`src/main.ts`:

```ts
import { createApp } from '~/app'
import { env } from '~/config/env'

const app = createApp()

const server = app.listen(env.port, () => {
  console.log(
    `[payex-billing-system] HTTP server started on port ${env.port}`
  )
})

function shutdown(signal: NodeJS.Signals): void {
  console.log(`[payex-billing-system] Received ${signal}`)

  server.close((error) => {
    if (error !== undefined) {
      console.error(
        '[payex-billing-system] Failed to close HTTP server',
        error
      )

      process.exitCode = 1
      return
    }

    console.log('[payex-billing-system] HTTP server stopped')
    process.exitCode = 0
  })
}

process.once('SIGINT', shutdown)
process.once('SIGTERM', shutdown)
```

Здесь уже используется алиас:

```ts
import { createApp } from '~/app'
import { env } from '~/config/env'
```

И добавлено graceful shutdown-поведение, которое позже понадобится для Docker, Kubernetes, RabbitMQ consumers, gRPC и database connection pools.

## Этап 10. Проверка development-режима

Запусти:

```bash
npm run dev
```

Ожидаемый вывод:

```text
[payex-billing-system] HTTP server started on port 3000
```

В другом терминале:

```bash
curl http://localhost:3000/health
```

Ответ:

```json
{
  "status": "ok",
  "service": "payex-billing-system",
  "timestamp": "2026-06-20T00:00:00.000Z"
}
```

Теперь измени текст в `src/app.ts` и сохрани файл. `tsx watch` автоматически перезапустит сервер.

## Этап 11. Проверка типов

```bash
npm run typecheck
```

Команда не создаёт JavaScript-файлы. Она только проверяет типы.

Это намеренное разделение:

```text
tsc     → проверка типов
tsup    → production-сборка
tsx     → development-запуск
```

Не следует заставлять `tsc` одновременно проверять типы и собирать production-код. У этих инструментов разные ответственности.

## Этап 12. Проверка production-сборки

Собери проект:

```bash
npm run build
```

Появится директория:

```text
dist/
├── main.js
└── main.js.map
```

Запусти production-сборку:

```bash
NODE_ENV=production npm start
```

Проверь:

```bash
curl http://localhost:3000/health
```

Дополнительно можно убедиться, что алиас `~/` отсутствует в итоговом JavaScript:

```bash
grep -R "from '~/" dist || echo "Aliases compiled successfully"
```

Ожидается:

```text
Aliases compiled successfully
```

## Результат первого этапа

Сейчас у проекта уже есть:

* Node.js 24;
* TypeScript strict mode;
* ESM;
* Express;
* development watch/restart;
* production-бандлер;
* source maps;
* graceful shutdown;
* рабочий алиас `~/`;
* единое поведение импортов в development и production;
* подготовка TypeScript к будущему DI на декораторах.

Следующий этап: `ESLint + Prettier + EditorConfig + .gitignore + .prettierignore + .dockerignore`, после чего подключим автоматическое форматирование в VS Code.
