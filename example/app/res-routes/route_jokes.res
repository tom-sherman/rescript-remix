%%raw(`import stylesUrl from "../styles/jokes.css"`)

let links = () => [{"rel": "stylesheet", "href": %raw(`stylesUrl`)}]

@react.component
let default = () => {
  <div className="jokes-layout">
    <header className="jokes-header">
      <div className="container">
        <h1 className="home-link">
          // <Remix.Link to="/" title="Remix Jokes" ariaLabel="Remix Jokes">
          <Remix.Link to="/">
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
          React.null
          // {data.jokeListItems.length
          //   ? <>
          //       <Link to="."> {"Get a random joke"->React.string} </Link>
          //       <p> {"Here are a few more jokes to check out:"->React.string} </p>
          //       <ul>
          //         {data.jokeListItems.map(({id, name}) =>
          //           <li key={id}> <Link to={id} prefetch="intent"> {name} </Link> </li>
          //         )}
          //       </ul>
          //       <Link to="new" className="button" prefetch="intent">
          //         {"Add your own"->React.string}
          //       </Link>
          //     </>
          //   : null}
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
