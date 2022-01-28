@react.component
let make = (~joke: Model.Joke.t, ~isOwner: bool, ~canDelete: bool=true) =>
  <div>
    <p> {"Here's your hilarious joke:"->React.string} </p>
    <p> {joke.content->React.string} </p>
    <Remix.Link to="."> {`${joke.name} Permalink`->React.string} </Remix.Link>
    {isOwner
      ? <Remix.Form method=#post>
          <input type_="hidden" name="_method" value="delete" />
          <button type_="submit" className="button" disabled={!canDelete}>
            {"Delete"->React.string}
          </button>
        </Remix.Form>
      : React.null}
  </div>
