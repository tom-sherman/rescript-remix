@@warning("-27")
open Jest
open Expect

module Map = Belt.MutableMap.String

type rec routeDefinition = {file: string, nested: option<Map.t<routeDefinition>>}

let first = (arr: array<'a>): 'a => arr[0]
let last = (arr: array<'a>): 'a => arr[arr->Js.Array2.length - 1]

module MockRouteDefiner = {
  type t = array<Map.t<routeDefinition>>

  let make = (): t => [Map.make()]

  let defineChildRoute = (. definer: t, path: string, file: string) => {
    definer->last->Map.set(path, {file: file, nested: None})
  }

  let defineParentRoute = (.
    definer: t,
    path: option<string>,
    file: string,
    callback: (. unit) => unit,
  ) => {
    let nestedRoutes = Map.make()
    definer
    ->last
    ->Map.set(path->Belt.Option.getWithDefault(""), {file: file, nested: Some(nestedRoutes)})
    definer->Js.Array2.push(nestedRoutes)->ignore
    callback(.)
    definer->Js.Array2.pop->ignore
  }

  // using raw JS here to model the signature-overloaded `defineRoute` function provided by Remix
  let defineRoute = (definer: t) => {
    %raw(`
    function(path, file, optsOrCallback, opts) {
      if (typeof optsOrCallback === "function") {
        defineParentRoute(definer, path, file, optsOrCallback)
      } else {
        defineChildRoute(definer, path, file)
      }
    }
  `)
  }

  let routes = (definer: t): Map.t<routeDefinition> => definer->first
}

afterEach(() => {
  MockFs.restore()
})

describe("directory structure to route and view hierarchy", () => {
  test("it should map a file into a simple route", () => {
    MockFs.mock({"app": {"res-routes": {"blog.js": ""}}})

    let routeDefiner = MockRouteDefiner.make()
    RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

    expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
      Map.fromArray([("blog", {file: "res-routes/blog.js", nested: None})]),
    )
  })

  test("it should map a deep file into a simple route", () => {
    MockFs.mock({"app": {"res-routes": {"blog": {"blog.js": ""}}}})

    let routeDefiner = MockRouteDefiner.make()
    RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

    expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
      Map.fromArray([("blog/blog", {file: "res-routes/blog/blog.js", nested: None})]),
    )
  })

  test("it should nest routes when a folder and file exist with the same name", () => {
    MockFs.mock({"app": {"res-routes": {"blog.js": "", "blog": {"blog.js": ""}}}})

    let routeDefiner = MockRouteDefiner.make()
    RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

    expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
      Map.fromArray([
        (
          "blog",
          {
            file: "res-routes/blog.js",
            nested: Some(
              Map.fromArray([("blog", {file: "res-routes/blog/blog.js", nested: None})]),
            ),
          },
        ),
      ]),
    )
  })

  test("it should not add a route segment when a folder and file start with an underscore", () => {
    MockFs.mock({"app": {"res-routes": {"_blog.js": "", "_blog": {"blog.js": ""}}}})

    let routeDefiner = MockRouteDefiner.make()
    RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

    expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
      Map.fromArray([
        (
          "",
          {
            file: "res-routes/_blog.js",
            nested: Some(
              Map.fromArray([("blog", {file: "res-routes/_blog/blog.js", nested: None})]),
            ),
          },
        ),
      ]),
    )
  })

  test("it should ignore non-js files", () => {
    MockFs.mock({"app": {"res-routes": {"blog.js": "", "ignoreme.res": ""}}})

    let routeDefiner = MockRouteDefiner.make()
    RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

    expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
      Map.fromArray([("blog", {file: "res-routes/blog.js", nested: None})]),
    )
  })
})

describe("filename to route mappings", () =>
  [
    ("blog", "blog"),
    ("namespaced_blog", "blog"),
    ("index", ""),
    ("namespaced_index", ""),
    ("[]", "*"),
    ("namespaced_[]", "*"),
    ("[blogId]", ":blogId"),
    ("namespaced_[blogId]", ":blogId"),
    ("blog[[.]]rss", "blog.rss"),
    ("blog[[_]]page", "blog_page"),
    ("blog[[[]]page", "blog[page"),
    ("blog]page", "blog]page"),
    ("namespaced_blog[[.]]rss", "blog.rss"),
    ("namespaced_[[_]]_blog", "blog"),
    ("blog.about", "blog/about"),
    ("namespaced_blog.about", "blog/about"),
    ("lots_of_namespaces_blog", "blog"),
  ]->Js.Array2.forEach(((input, output)) =>
    test(`"${input}" -> "${output}"`, () => {
      MockFs.mockWithDict(
        Js.Dict.fromArray([
          ("app", Js.Dict.fromArray([("res-routes", Js.Dict.fromArray([(`${input}.js`, "")]))])),
        ]),
      )

      let routeDefiner = MockRouteDefiner.make()
      RouteConventions.registerRoutes(routeDefiner->MockRouteDefiner.defineRoute)

      expect(routeDefiner->MockRouteDefiner.routes)->toEqual(
        Map.fromArray([(output, {file: `res-routes/${input}.js`, nested: None})]),
      )
    })
  )
)
