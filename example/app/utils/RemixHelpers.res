module HeadersInit = {
  external asObject: Webapi.Fetch.Headers.t => {..} = "%identity"

  let makeWithHeaders = (headers: Webapi.Fetch.Headers.t): Webapi.Fetch.HeadersInit.t =>
    Webapi.Fetch.HeadersInit.make(headers->asObject)
}

module Promise = {
  external responseAsExn: Webapi.Fetch.Response.t => 'a = "%identity"
  let rejectResponse = (response: Webapi.Fetch.Response.t): Promise.t<'a> => {
    Promise.reject(response->responseAsExn)
  }
}

module FormData = {
  let getStringValue = (formData: Webapi.FormData.t, fieldName: string): option<string> => {
    formData
    ->Webapi.Fetch.FormData.get(fieldName)
    ->Belt.Option.flatMap(value =>
      switch value->Webapi.Fetch.FormData.EntryValue.classify {
      | #String(value) => Some(value)
      | _ => None
      }
    )
  }
}
