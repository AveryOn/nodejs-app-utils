# Package JSON utilities

## configure-node-app.sh

Configures the base `package.json` fields and scripts for a Node.js
application using TypeScript, ESM, TSX and tsup.

### Requirements

- Node.js 24+
- npm
- Existing `package.json`

### Usage

Configure the current directory:

```bash
./scripts/package-json/configure-node-app.sh
```

Configure another project:

```bash
./scripts/package-json/configure-node-app.sh /path/to/project
```