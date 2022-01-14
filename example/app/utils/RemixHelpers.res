module HeadersInit = {
  external asObject: Webapi.Fetch.Headers.t => {..} = "%identity"

  let makeWithHeaders = (headers: Webapi.Fetch.Headers.t): Webapi.Fetch.HeadersInit.t =>
    Webapi.Fetch.HeadersInit.make(headers->asObject)
}

type errorProps = {error: Js.Exn.t}
