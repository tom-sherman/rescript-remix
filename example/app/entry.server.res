Db.init()

let default = (request, responseStatusCode, responseHeaders, remixContext) => {
  open Webapi

  responseHeaders->Fetch.Headers.set("Content-Type", "text/html")

  Fetch.Response.makeWithInit(
    "<!DOCTYPE html>" ++
    ReactDOMServer.renderToString(
      <Remix.RemixServer context={remixContext} url={request->Fetch.Request.url} />,
    ),
    Fetch.ResponseInit.make(
      ~status=responseStatusCode,
      ~headers=RemixHelpers.HeadersInit.makeWithHeaders(responseHeaders),
      (),
    ),
  )
}
