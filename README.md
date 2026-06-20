# Node.js App Utils

A collection of reusable scripts, configuration templates, command snippets, and development utilities for Node.js and TypeScript applications.

The repository is intended to reduce repetitive project setup work and keep commonly used development operations in one place.

## Purpose

When creating Node.js applications, many setup steps are repeated across projects:

* configuring `package.json`;
* initializing TypeScript;
* setting up ESM;
* configuring build tools;
* preparing ESLint and Prettier;
* creating Docker environments;
* installing Git hooks;
* configuring tests;
* validating project structure;
* cleaning development environments.

This repository stores these operations as reusable and documented utilities.

### `scripts`

Executable and reusable utilities for project setup, maintenance, validation, and automation.

### `templates`

Configuration files that can be copied into Node.js projects.

Examples:

* ESLint configuration;
* Prettier configuration;
* TypeScript configuration;
* Dockerfiles;
* Docker Compose files;
* EditorConfig;
* environment file examples.

### `snippets`

Short command collections and examples that do not require a standalone script.

### `docs`

Additional documentation, explanations, and usage notes.

## Available utilities

### Configure a Node.js application package

Configures common `package.json` fields and scripts for a TypeScript Node.js application using ESM, TSX, and tsup.

File:

```text
scripts/package-json/configure-node-app.sh
```

Usage for the current directory:

```bash
./scripts/package-json/configure-node-app.sh
```

Usage for another project:

```bash
./scripts/package-json/configure-node-app.sh /path/to/project
```

The utility configures the following fields:

```json
{
  "private": true,
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
  }
}
```

Equivalent npm commands:

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

## Requirements

Requirements depend on the selected utility.

Common requirements:

* Bash;
* Node.js;
* npm;
* Git;
* Docker and Docker Compose for Docker-related utilities.

The recommended Node.js version is specified in `.nvmrc`.

```bash
nvm install
nvm use
```

## Usage

Clone the repository:

```bash
git clone https://github.com/<username>/nodejs-app-utils.git
cd nodejs-app-utils
```

Make a script executable when necessary:

```bash
chmod +x scripts/package-json/configure-node-app.sh
```

Run the required utility:

```bash
./scripts/package-json/configure-node-app.sh /path/to/project
```

Utilities should be executed from a trusted local copy of the repository. Review scripts before applying them to production projects.

## Design principles

Utilities in this repository should follow several principles:

* be focused on one specific task;
* be safe to run repeatedly when possible;
* fail immediately when an operation cannot be completed;
* validate required files and commands;
* support an explicit target project directory;
* avoid hidden global system changes;
* include usage documentation;
* produce readable terminal output.

## Adding a utility

Each utility should have a clear name based on its purpose.

Recommended structure:

```text
scripts/<category>/
├── utility-name.sh
└── README.md
```

A utility should include:

1. A clear description.
2. Requirements.
3. Usage examples.
4. Expected project changes.
5. Error handling.
6. Notes about destructive operations.

Example:

```text
scripts/docker/
├── reset-project.sh
└── README.md
```

## Planned utilities

Possible future additions:

* TypeScript initialization;
* ESM project configuration;
* import alias configuration;
* ESLint and Prettier setup;
* Husky and lint-staged setup;
* Vitest initialization;
* Docker development and production setup;
* Docker environment reset;
* project structure validation;
* environment file generation;
* npm dependency inspection;
* package cleanup;
* Git repository initialization;
* common Node.js application templates.

## Safety

Some utilities may modify files, remove generated directories, reset containers, or change project configuration.

Before running a utility:

* review its source code;
* check the target directory;
* commit current changes;
* make sure important data is backed up.

Destructive utilities must be clearly documented and should require explicit confirmation where appropriate.

## License

This project is available under the MIT License.
