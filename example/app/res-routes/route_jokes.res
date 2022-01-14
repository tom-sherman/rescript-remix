%%raw(`import stylesUrl from "../styles/jokes.css"`)

let links = () => [{"rel": "stylesheet", "href": %raw(`stylesUrl`)}]

type loaderData = {jokeListItems: array<Model.Jokes.t>}

let loader = (): Promise.t<loaderData> => {
  Model.Jokes.getLatest()->Promise.thenResolve(jokes => {jokeListItems: jokes})
}

@react.component
let default = () => {
  let data: loaderData = Remix.useLoaderData()

  <div className="jokes-layout">
    <header className="jokes-header">
      <div className="container">
        <h1 className="home-link">
          <Remix.Link to="/" title="Remix Jokes" ariaLabel="Remix Jokes">
            <span className="logo"> {`🤪`->React.string} </span>
            <span className="logo-medium"> {`J🤪KES`->React.string} </span>
          </Remix.Link>
        </h1>
        // {data.user
        //   ? <div className="user-info">
        //       <span> {`Hi ${data.user.username}`} </span>
        //       <Form action="/logout" method="post">
        //         <button _type="submit" className="button"> {"Logout"->React.string} </button>
        //       </Form>
        //     </div>
        //   : <Link to="/login"> {"Login"->React.string} </Link>}
        <Remix.Link to="/login"> {"Login"->React.string} </Remix.Link>
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