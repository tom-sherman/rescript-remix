type loaderData = {randomJoke: Db.Jokes.t}

let loader: Remix.loaderFunction<loaderData> = _ => {
  Db.Jokes.getRandom()->Promise.then(joke =>
    switch joke {
    | Some(joke) => Promise.resolve({randomJoke: joke})
    | None =>
      RemixHelpers.Promise.rejectResponse(
        Webapi.Fetch.Response.makeWithInit(
          "No random joke found",
          Webapi.Fetch.ResponseInit.make(~status=404, ()),
        ),
      )
    }
  )
}

@react.component
let default = () => {
  let data: loaderData = Remix.useLoaderData()

  <div>
    <p> {"Here's a random joke:"->React.string} </p>
    <p> {data.randomJoke.content->React.string} </p>
    <Remix.Link to={data.randomJoke.id}>
      {`${data.randomJoke.name} Permalink`->React.string}
    </Remix.Link>
  </div>
}

let catchBoundary: Remix.catchBoundaryComponent = () => {
  let caught = Remix.useCatch()
  Js.log(caught)

  if caught->Webapi.Fetch.Response.status == 404 {
    <div className="error-container">
      <p> {"There are no jokes to display."->React.string} </p>
      <Remix.Link to="new"> {"Add your own"->React.string} </Remix.Link>
    </div>
  } else {
    Js.Exn.raiseError(
      `Unexpected caught response with status: ${caught
        ->Webapi.Fetch.Response.status
        ->Js.Int.toString}`,
    )
  }
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = props => {
  Js.log(props.error)

  <div className="error-container"> {"I did a whoopsies."->React.string} </div>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
