let loader: Remix.loaderFunction = ({request}) => {
  open Webapi.Fetch

  Promise.all2((Db.Users.getAll(), Db.Jokes.getAll()))->Promise.then(((
    users,
    jokes,
  )) => {
    let host = request->Request.headers->Headers.get("host")->Belt.Option.getExn
    let domain = `http://${host}`
    let jokesUrl = `${domain}/jokes`

    let rssString = `
      <rss xmlns:blogChannel="${jokesUrl}" version="2.0">
        <channel>
          <title>Remix Jokes</title>
          <link>${jokesUrl}</link>
          <description>Some funny jokes</description>
          <language>en-us</language>
          <generator>Kody the Koala</generator>
          <ttl>40</ttl>
          ${jokes
      ->Js.Array2.map(joke =>
        `
              <item>
                <title>${joke.name}</title>
                <description>A funny joke called ${joke.name}</description>
                <author>${users
          ->Js.Array2.find(user => user.username == joke.jokesterId)
          ->Belt.Option.map(user => user.username)
          ->Belt.Option.getWithDefault("")}</author>
                <pubDate>${joke.createdAt->Js.Date.fromFloat->Js.Date.toString}</pubDate>
                <link>${jokesUrl}/${joke.id}</link>
                <guid>${jokesUrl}/${joke.id}</guid>
              </item>
            `->Js.String2.trim
      )
      ->Js.Array2.joinWith("\n")}
        </channel>
      </rss>
    `->Js.String2.trim

    Response.makeWithInit(
      rssString,
      ResponseInit.make(
        ~headers=HeadersInit.make({
          "Cache-Control": `public, max-age=${(60 * 10)->Js.Int.toString}, s-maxage=${(60 * 60 * 24)
              ->Js.Int.toString}`,
          "Content-Type": "application/xml",
          "Content-Length": rssString->Bytes.of_string->Bytes.length,
        }),
        (),
      ),
    )->Promise.resolve
  })
}
