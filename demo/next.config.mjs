/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@aztec-private-voting/react'],
  webpack: (config, { isServer }) => {
    config.experiments = {
      ...config.experiments,
      topLevelAwait: true,
      asyncWebAssembly: true,
    };
    if (!isServer) {
      // bb.js ships its own worker; let webpack treat .wasm as async modules.
      config.output = { ...config.output, webassemblyModuleFilename: 'static/wasm/[modulehash].wasm' };
      // @aztec/accounts pulls in a Node SSH-agent path through @aztec/wallets;
      // the SSH-only branch is never reached in the browser, but webpack still
      // tries to resolve `net`, `tls`, etc. Stub them out.
      config.resolve = {
        ...(config.resolve || {}),
        fallback: {
          ...(config.resolve?.fallback || {}),
          net: false,
          tls: false,
          fs: false,
          dns: false,
          child_process: false,
        },
      };
    }
    return config;
  },
  // bb.js + noir_js use Worker / WASM with SharedArrayBuffer. The COOP/COEP
  // headers are required for SharedArrayBuffer to be available cross-origin.
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
          { key: 'Cross-Origin-Embedder-Policy', value: 'require-corp' },
        ],
      },
    ];
  },
};

export default nextConfig;
