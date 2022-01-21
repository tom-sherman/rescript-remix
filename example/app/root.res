%%raw(`import globalStylesUrl from "./styles/global.css"`)
%%raw(`import globalMediumStylesUrl from "./styles/global-medium.css"`)
%%raw(`import globalLargeStylesUrl from "./styles/global-large.css"`)

let links = () => (
  {"rel": "stylesheet", "href": %raw(`globalStylesUrl`)},
  {
    "rel": "stylesheet",
    "href": %raw(`globalMediumStylesUrl`),
    "media": "print, (min-width: 640px)",
  },
  {
    "rel": "stylesheet",
    "href": %raw(`globalLargeStylesUrl`),
    "media": "print, (min-width: 1024px)",
  },
)

let meta: Remix.metaFunction<unit> = _ => {
  let description = `Learn Remix and laugh at the same time!`
  Remix.HtmlMetaDescriptor.make({
    "viewport": "width=device-width,initial-scale=1",
    "description": description,
    "keywords": "Remix,jokes",
    "twitter:image": "https://remix-jokes.lol/social.png",
    "twitter:card": "summary_large_image",
    "twitter:creator": "@remix_run",
    "twitter:site": "@remix_run",
    "twitter:title": "Remix Jokes",
    "twitter:description": description,
  })
}

module Document = {
  @react.component
  let make = (~title=?, ~children) =>
    <html>
      <head>
        <meta charSet="utf-8" />
        <Remix.Meta />
        {switch title {
        | Some(title) => <title> {title->React.string} </title>
        | None => React.null
        }}
        <Remix.Links />
      </head>
      <body>
        {children}
        <Remix.Scripts />
        {Remix.process["env"]["NODE_ENV"] == "development" ? <Remix.LiveReload /> : React.null}
      </body>
    </html>
}

@react.component
let default = () => <Document title="Remix: So great, it's funny!"> <Remix.Outlet /> </Document>

let catchBoundary: Remix.catchBoundaryComponent = () => {
  open Webapi.Fetch.Response

  let caught = Remix.useCatch()

  <Document title={`${caught->status->Js.Int.toString} ${caught->statusText}`}>
    <div className="error-container">
      <h1> {`${caught->status->Js.Int.toString} ${caught->statusText}`->React.string} </h1>
    </div>
  </Document>
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = props => {
  Js.log(props.error)

  <Document title="Uh-oh!">
    <div className="error-container">
      <h1> {"App Error"->React.string} </h1>
      <pre> {props.error->Js.Exn.message->Belt.Option.getWithDefault("")->React.string} </pre>
    </div>
  </Document>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
