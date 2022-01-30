@react.component
let make = (~name: string, ~content: string, ~isOwner: bool, ~canDelete: bool=true) =>
  <div>
    <p> {"Here's your hilarious joke:"->React.string} </p>
    <p> {content->React.string} </p>
    <Remix.Link to="."> {`${name} Permalink`->React.string} </Remix.Link>
    {isOwner
      ? <Remix.Form method=#post>
          <input type_="hidden" name="_method" value="delete" />
          <button type_="submit" className="button" disabled={!canDelete}>
            {"Delete"->React.string}
          </button>
        </Remix.Form>
      : React.null}
  </div>
