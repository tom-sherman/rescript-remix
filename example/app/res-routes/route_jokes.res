%%raw(`import stylesUrl from "../styles/jokes.css"`)

let links: Remix.linksFunction = () => [
  Remix.HtmlLinkDescriptor.make(~rel=#stylesheet, ~href=%raw(`stylesUrl`), ()),
]

@decco
type loaderData = {jokeListItems: array<Model.Joke.t>, username: option<string>}

let loader: Remix.loaderFunction = ({request}) => {
  Promise.all2((
    request->Session.getUser,
    Db.Jokes.getLatest(),
  ))->Promise.thenResolve(((user, jokes)) =>
    {
      username: user->Belt.Option.map(user => user.username),
      jokeListItems: jokes,
    }
    ->loaderData_encode
    ->Remix.json
  )
}

@react.component
let default = () => {
  let data = Remix.useLoaderData()->loaderData_decode->Belt.Result.getExn

  <div className="jokes-layout">
    <header className="jokes-header">
      <div className="container">
        <h1 className="home-link">
          // <Remix.Link to="/" title="Remix Jokes" ariaLabel="Remix Jokes">
          <Remix.Link to="/" title="Remix Jokes">
            <span className="logo"> {`🤪`->React.string} </span>
            <span className="logo-medium"> {`J🤪KES`->React.string} </span>
          </Remix.Link>
        </h1>
        {switch data.username {
        | Some(username) =>
          <div className="user-info">
            <span> {`Hi ${username}`->React.string} </span>
            <Remix.Form action="/logout" method=#post>
              <button type_="submit" className="button"> {"Logout"->React.string} </button>
            </Remix.Form>
          </div>
        | None => <Remix.Link to="/login"> {"Login"->React.string} </Remix.Link>
        }}
      </div>
    </header>
    <main className="jokes-main">
      <div className="container">
        <div className="jokes-list">
          {if data.jokeListItems->Js.Array2.length > 0 {
            <>
              <Remix.Link to="."> {"Get a random joke"->React.string} </Remix.Link>
              <p> {"Here are a few more jokes to check out:"->React.string} </p>
              <ul>
                {data.jokeListItems
                ->Js.Array2.map(({id, name}) =>
                  <li key={id}>
                    <Remix.Link to={id} prefetch=#intent> {name->React.string} </Remix.Link>
                  </li>
                )
                ->React.array}
              </ul>
              <Remix.Link to="new" className="button" prefetch=#intent>
                {"Add your own"->React.string}
              </Remix.Link>
            </>
          } else {
            React.null
          }}
        </div>
        <div className="jokes-outlet"> <Remix.Outlet /> </div>
      </div>
    </main>
    <footer className="jokes-footer">
      <div className="container">
        <Remix.Link reloadDocument=true to="/jokes.rss"> {"RSS"->React.string} </Remix.Link>
      </div>
    </footer>
  </div>
}
