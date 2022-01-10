module Map = Belt.MutableMap.String
@module("fs") external statSync: string => NodeJs.Fs.Stats.t = "statSync"

type routeOptions = {index: bool}

type defineRoute
type defineChildRoute = (. string, string, routeOptions) => unit
type defineParentRoute = (. option<string>, string, unit => unit) => unit

external toDefineChildRoute: defineRoute => defineChildRoute = "%identity"
external toDefineParentRoute: defineRoute => defineParentRoute = "%identity"

type rec routeDefinitionNode = {
  mutable file: option<string>,
  mutable nested: option<routeDefinition>,
}
and routeDefinition = Map.t<routeDefinitionNode>

type segmentAccumulatorState =
  Normal | SawOpenBracket | SawCloseBracket | InsideParameter | InsideEscape
type segmentAccumulator = {
  segment: string,
  state: segmentAccumulatorState,
}

let filenameToSegment = (name: string): string => {
  let segment = (name->Js.String2.split("")->Js.Array2.reduce((acc, char) =>
      switch (char, acc.state) {
      | ("_", Normal) => {...acc, segment: ""}
      | (".", Normal) => {...acc, segment: acc.segment ++ "/"}
      | ("[", Normal) => {...acc, state: SawOpenBracket}
      | ("[", SawOpenBracket) => {...acc, state: InsideEscape}
      | ("]", SawOpenBracket) => {segment: acc.segment ++ "*", state: Normal}
      | ("]", InsideEscape) => {...acc, state: SawCloseBracket}
      | ("]", SawCloseBracket) => {...acc, state: Normal}
      | ("]", InsideParameter) => {...acc, state: Normal}
      | (_, SawOpenBracket) => {segment: acc.segment ++ ":" ++ char, state: InsideParameter}
      | (_, SawCloseBracket) => {segment: acc.segment ++ "]" ++ char, state: InsideEscape}
      | (_, Normal)
      | (_, InsideEscape)
      | (_, InsideParameter) => {...acc, segment: acc.segment ++ char}
      }
    , {segment: "", state: Normal})).segment

  if name->Js.String2.startsWith("_") {
    "_" ++ segment
  } else if segment == "index" {
    ""
  } else {
    segment
  }
}

let rec buildRoutesForDir = (path: string) => {
  let routes = Map.make()

  let files = NodeJs.Fs.readdirSync(NodeJs.Path.join(["app", path]))
  Js.Array2.forEach(files, file => {
    let fileDef = file->NodeJs.Path.parse
    let isDirectory = ["app", path, file]->NodeJs.Path.join->statSync->NodeJs.Fs.Stats.isDirectory

    if isDirectory || fileDef.ext === ".js" {
      let segment = (isDirectory ? fileDef.base : fileDef.name)->filenameToSegment
      let mapping = routes->Map.getWithDefault(segment, {file: None, nested: None})

      if isDirectory {
        mapping.nested = Some(buildRoutesForDir(NodeJs.Path.join([path, segment])))
      } else {
        mapping.file = Some(NodeJs.Path.join([path, file]))
      }

      routes->Map.set(segment, mapping)
    }
  })

  routes
}

let rec registerBuiltRoutes = (
  defineRoute: defineRoute,
  routes: routeDefinition,
  ~segments=[],
  (),
) => {
  routes->Map.forEach((segment, definition) =>
    switch (definition.file, definition.nested) {
    | (Some(file), None) =>
      (defineRoute->toDefineChildRoute)(.
        segments->Js.Array2.concat([segment])->Js.Array2.joinWith("/"),
        file,
        {index: segment == ""},
      )
    | (None, Some(nested)) =>
      registerBuiltRoutes(defineRoute, nested, ~segments=segments->Js.Array2.concat([segment]), ())
    | (Some(file), Some(nested)) =>
      (defineRoute->toDefineParentRoute)(.
        segment->Js.String2.startsWith("_")
          ? None
          : Some(segments->Js.Array2.concat([segment])->Js.Array2.joinWith("/")),
        file,
        () => registerBuiltRoutes(defineRoute, nested, ()),
      )
    | (None, None) => Js.Exn.raiseError("Invariant error")
    }
  )
}

let registerRoutes = (defineRoute: defineRoute) => {
  let routes = buildRoutesForDir("res-routes")
  registerBuiltRoutes(defineRoute, routes, ())
}
