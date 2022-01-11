# rescript-remix

Bindings and helpers for [Remix](https://remix.run/).

## Installation

If you don't already have have a Remix project the easiest way to get started quickly is to use the template found [here](https://github.com/tom-sherman/rescript-remix-template). Otherwise, continue reading this guide if you prefer manual setup or want to understand how the template works.
### Setup and install

You should already have a Remix project setup. You can create one by following the [Remix docs](https://remix.run/docs/en/v1/tutorials/blog#creating-the-project).

Once you have a Remix project, install the necessary dependencies:

```
npm install rescript rescript-remix patch-package @rescript/react rescript-webapi
```

<details>
    <summary>🙋 What is each package for?</summary>
    <ul>
      <li> <code>rescript</code> - The ReScript compiler and standard library.
      <li> <code>rescript-remix</code> - This package. Includes Remix bindings and helpers.
      <li> <code>patch-package</code> - A tool to patch Remix itself to workaround lack of ESM support (more about this later).
      <li> <code>@rescript/react</code> - React bindings for ReScript.
      <li> <code>rescript-webapi</code> - ReScript bindings for Web Platform APIs eg. <code>fetch</code> and <code>Request</code>
</details>

### Add `bsconfig.json`

Create a `bsconfig.json` file at the root of your repo. Copy the contents from [the template](https://github.com/tom-sherman/rescript-remix-template/blob/main/bsconfig.json) in and change the "name" to your project name. This can be anything you want but it's recommended to match the one you gave in `package.json` for consistency.

<details>
    <summary>🙋 Why do we need all of these settings?</summary>
    <p> You can read about what all the options are for in the <a href="https://rescript-lang.org/docs/manual/latest/build-configuration">ReScript docs</a>. The recommended settings are setup in such a way to be most convenient to ReScript and Remix developers alike while supporting the file-system-based routing of Remix.
</details>

### Patch the ReScript compiler

Copy the patch [from the template](https://github.com/tom-sherman/rescript-remix-template/tree/main/patches) into your project, making sure to place it in the `patches/` directory and matching the file name exactly. The patch in the template works on a specific version of `@remix-run/dev`, you may need to ensure that your version of `@remix-run/dev` matches the one in the template.

Next, modify (or add) the `postinstall` script in package.json to include the `patch-package` script.

```diff
...
   "scripts": {
     "build": "rescript build && remix build",
     "dev:remix": "remix dev",
     "dev:rescript": "rescript build -w",
-    "postinstall": "remix setup node",
+    "postinstall": "patch-package && remix setup node",
     "start": "remix-serve build"
   },
...
```

Run `npm i` to apply the patch.

<details>
    <summary>🙋 What does the patch do?</summary>
    <p> It allows Remix to transpile ES modules (export/import syntax) inside of node_modules. This is important because our ReScript configuration tells the compiler to transpile to ESM, and this includes ReScript dependencies in node_modules eg. this package and the ReScript standard library.
</details>

### Enable transpilation of ESM modules

Add `"rescript"` to the `transpileModules` option in `remix.config.js`. This ensures that our patch installed above will transpile the ReScript standard library.

```diff
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
+  transpileModules: ["rescript"],
 };
```

You'll need to add more packages to this array whenever you receive a Remix error message that says it failed to compile ESM syntax. This is often the case when you install a new ReScript dependency.

### Enable convention based routing for ReScript modules

Add a `routes` option to `remix.config.js` and inside call the `registerRoutes` function exported by `rescript-remix/registerRoutes`:

```diff
+ const { registerRoutes } = require('rescript-remix/registerRoutes');

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
   transpileModules: ["rescript"],
+  routes(defineRoutes) {
+    return defineRoutes(route => {
+      registerRoutes(route);
+    });
+  }
 };
```

This allows you to use all of the convention-based routing of Remix with ReScript modules by placing them inside the `app/res-routes` director. See [the usage section](#convention-based-routing) for more details.

### (optional) Git ignore compiled JS

JS is outputted alongside ReScript modules to enable convention based routing. You can opt to not commit these build artifacts by adding the following lines to `.gitignore`:

```
/app/**/*.jsx
/app/**/*.js
```

This step is optional as it's personal preference. Some people prefer to check in the artifacts generated by ReScript to enable teammates that aren't familiar with the language to make quick changes, or to ensure the output from the compiler is as expected.

## Adopting into an existing Remix app

todo

## Usage

todo

### Convention based routing

todo
