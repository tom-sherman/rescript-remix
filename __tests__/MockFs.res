@module external mock: {..} => unit = "mock-fs"
@module external mockWithDict: Js.Dict.t<'a> => unit = "mock-fs"

@module("mock-fs") external restore: unit => unit = "restore"
