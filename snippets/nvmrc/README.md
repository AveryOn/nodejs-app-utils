Для Fedora с Bash добавим hook в `~/.bashrc`. Он будет:

* находить ближайший `.nvmrc`;
* автоматически устанавливать требуемую версию Node.js, если её нет;
* выполнять `nvm use`;
* возвращаться на default-версию при выходе из проекта.

Открой файл:

```bash
nano ~/.bashrc
```

Добавь в самый конец, после подключения NVM следующий код:

[Скрипт - bash хук](./node-select-version.hook.bash)

Примени изменения без перезапуска терминала:

```bash
source ~/.bashrc
```

Установи Node.js 24 как глобальную версию по умолчанию:

```bash
nvm install 24
nvm alias default 24
nvm use default
```

В проекте должен быть файл `.nvmrc`:

```text
24
```

Проверка:

```bash
cd ~/Desktop/projects/payex-billing-system
node --version
```

При входе в проект должен появиться вывод примерно такого вида:

```text
Now using node v24.x.x
```

Для проверки переключения можно создать временную директорию:

```bash
mkdir -p /tmp/node-test
echo "22" > /tmp/node-test/.nvmrc

cd /tmp/node-test
node --version

cd ~
node --version
```

При входе в `/tmp/node-test` включится Node.js 22, а после выхода — default-версия Node.js 24. Теперь команды проекта можно запускать без ручного `nvm use`:

```bash
cd ~/Desktop/projects/payex-billing-system
npm install
npm run dev
```
