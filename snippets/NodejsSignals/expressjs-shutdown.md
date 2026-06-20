
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
---

`SIGINT` и `SIGTERM` — это системные сигналы Unix/Linux, которыми операционная система сообщает процессу, что ему нужно завершиться.

`SIGINT` означает interrupt. Обычно он приходит, когда ты нажимаешь:

```bash
Ctrl + C
```

в терминале.

То есть при ручной остановке приложения:

```bash
npm run dev
```

и затем `Ctrl + C`, Node.js получает `SIGINT`.

`SIGTERM` означает terminate. Это стандартный сигнал для корректного завершения процесса. Его обычно отправляют:

```bash
kill <pid>
```

а также Docker, Kubernetes, systemd и другие менеджеры процессов.

Например, при выполнении:

```bash
docker stop container-name
```

Docker сначала отправляет процессу `SIGTERM`, давая приложению время завершиться корректно. Если процесс не остановился, позже может быть отправлен `SIGKILL`.

В твоём коде:

```ts
process.once('SIGINT', shutdown)
process.once('SIGTERM', shutdown)
```

это означает:

* при получении `SIGINT` один раз вызвать `shutdown`;
* при получении `SIGTERM` один раз вызвать `shutdown`.

Функция получает название сигнала:

```ts
function shutdown(signal: NodeJS.Signals): void
```

После этого выполняется:

```ts
server.close(...)
```

`server.close()` перестаёт принимать новые HTTP-соединения и ждёт завершения уже активных запросов.

То есть последовательность такая:

```text
SIGINT / SIGTERM
        ↓
shutdown(signal)
        ↓
server.close()
        ↓
новые запросы больше не принимаются
        ↓
текущие запросы завершаются
        ↓
процесс завершается
```

Разница между основными сигналами:

```text
SIGINT   — обычно Ctrl + C
SIGTERM  — обычная команда корректно завершить процесс
SIGKILL  — немедленное принудительное завершение
```

`SIGKILL` нельзя перехватить:

```ts
process.once('SIGKILL', shutdown)
```

такой код работать не будет. Операционная система завершает процесс сразу, не давая выполнить cleanup.

Для серверного приложения обработка `SIGINT` и `SIGTERM` нужна, чтобы перед завершением успеть:

* перестать принимать запросы;
* закрыть HTTP-сервер;
* закрыть соединение с PostgreSQL;
* закрыть Redis;
* остановить RabbitMQ consumer;
* завершить фоновые задачи;
* дописать логи.

Твой код реализует базовый graceful shutdown — корректное завершение HTTP-сервера.
