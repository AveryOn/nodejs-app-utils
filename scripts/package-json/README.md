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
npm run package:configure
```

Configure another project:

```bash
npm run package:configure -- ~/Desktop/projects/payex-billing-system
```