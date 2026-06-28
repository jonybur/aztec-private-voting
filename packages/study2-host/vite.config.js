import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // Allow the app to be embedded in a Qualtrics iframe.
  // No X-Frame-Options restriction needed (Vercel default is fine).
  build: {
    outDir: 'dist',
    sourcemap: false,
    rollupOptions: {
      // The @aztec-private-voting/react dist contains dynamic import("@aztec/aztec.js")
      // calls in hooks/context that are NOT used by VoteReceipt. Mark the entire
      // @aztec/* and @noir-lang/* namespace external so Rollup doesn't try to bundle
      // packages that have non-standard exports fields.
      external: [
        /^@aztec\//,
        /^@noir-lang\//,
        /^@noble\//,
      ],
    },
  },
  server: {
    port: 5174,
  },
});
