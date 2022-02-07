%%raw(`import stylesUrl from "../styles/index.css"`)

let meta: Remix.metaFunction = _ =>
  Remix.HtmlMetaDescriptor.make({
    "title": "Remix: So great, it's funny!",
    "description": "Remix jokes app. Learn Remix and laugh at the same time!",
  })

let links: Remix.linksFunction = () => [
  Remix.HtmlLinkDescriptor.make(~rel=#stylesheet, ~href=%raw(`stylesUrl`), ()),
]

let headers: Remix.headersFunction = _ => {
  open Webapi.Fetch

  Headers.makeWithInit(
    HeadersInit.make({
      "Cache-Control": `public, max-age=${(60 * 10)->Js.Int.toString}, s-maxage=${(60 *
        60 *
        24 * 30)->Js.Int.toString}`,
    }),
  )
}

@react.component
let default = () => {
  <div className="container">
    <div className="content">
      <h1> {"Rescript"->React.string} <span> {"Jokes!"->React.string} </span> </h1>
      <nav>
        <ul>
          <li> <Remix.Link to="jokes"> {"Read Jokes"->React.string} </Remix.Link> </li>
          <li>
            <a href="https://github.com/remix-run/remix-jokes"> {"GitHub"->React.string} </a>
          </li>
          <li>
            <Remix.Link reloadDocument=true to="/jokes.rss"> {"RSS"->React.string} </Remix.Link>
          </li>
        </ul>
      </nav>
    </div>
  </div>
}
