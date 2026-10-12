/** @type {import('next').NextConfig} */
const nextConfig = {
  output: process.env.STOWPASTE_STATIC_EXPORT === "1" ? "export" : undefined,
  trailingSlash: process.env.STOWPASTE_STATIC_EXPORT === "1",
  images: { unoptimized: process.env.STOWPASTE_STATIC_EXPORT === "1" },
  poweredByHeader: false,
  compress: true,
  experimental: {
    optimizePackageImports: []
  }
};

export default nextConfig;
