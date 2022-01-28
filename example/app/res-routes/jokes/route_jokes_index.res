@decco
type loaderData = {randomJoke: Model.Joke.t}

let loader: Remix.loaderFunction = _ => {
  open Webapi.Fetch

  Db.Jokes.getRandom()->Promise.then(joke =>
    switch joke {
    | Some(joke) => {randomJoke: joke}->loaderData_encode->Remix.json->Promise.resolve
    | None =>
      RemixHelpers.Promise.rejectResponse(
        Response.makeWithInit("No random joke found", ResponseInit.make(~status=404, ())),
      )
    }
  )
}

@react.component
let default = () => {
  let data = Remix.useLoaderData()->loaderData_decode->Belt.Result.getExn

  <div>
    <p> {"Here's a random joke:"->React.string} </p>
    <p> {data.randomJoke.content->React.string} </p>
    <Remix.Link to={data.randomJoke.id}>
      {`${data.randomJoke.name} Permalink`->React.string}
    </Remix.Link>
  </div>
}

let catchBoundary: Remix.catchBoundaryComponent = () => {
  open Webapi.Fetch

  let caught = Remix.useCatch()
  Js.log(caught)

  if caught->Response.status == 404 {
    <div className="error-container">
      <p> {"There are no jokes to display."->React.string} </p>
      <Remix.Link to="new"> {"Add your own"->React.string} </Remix.Link>
    </div>
  } else {
    Js.Exn.raiseError(
      `Unexpected caught response with status: ${caught->Response.status->Js.Int.toString}`,
    )
  }
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = props => {
  Js.log(props.error)

  <div className="error-container"> {"I did a whoopsies."->React.string} </div>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
