import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  resolve: {
    alias: {
      // @aztec/aztec.js has no root "."-export (only sub-paths like ./abi,
      // ./account, etc.). Vite fails to resolve any dynamic
      // `import('@aztec/aztec.js')` during module-graph scanning even when
      // the import is never executed in the test. This alias provides a
      // lightweight stub so the resolver has something to land on.
      // Added tick-4255 — fixes receipt-id.test.ts and PrivateBallot.test.tsx.
      '@aztec/aztec.js': path.resolve(
        __dirname,
        'src/__mocks__/aztec-js-stub.ts',
      ),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['src/**/*.test.{ts,tsx}'],
    setupFiles: ['./vitest.setup.ts'],
  },
});
