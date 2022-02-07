const { registerRoutes } = require('rescript-remix/registerRoutes');

/**
 * @type {import('@remix-run/dev/config').AppConfig}
 */
module.exports = {
  appDirectory: "app",
  assetsBuildDirectory: "public/build",
  publicPath: "/build/",
  serverBuildDirectory: "build",
  devServerPort: 8002,
  ignoredRouteFiles: [".*", "*.res"],
  transpileModules: ["rescript", "rescript-webapi", "decco"],
  serverModuleMatch: /(\/server\/|server\.js$)/i,
  routes(defineRoutes) {
    return defineRoutes(route => {
      registerRoutes(route);
    });
  }
};
