type loginForm = {username: string, password: string}

let register = ({username, password}): Promise.t<unit> =>
  password
  ->Bcrypt.hash(10)
  ->Promise.then(passwordHash =>
    {
      Db.Users.username: username,
      passwordHash: passwordHash,
    }->Db.Users.create
  )

let login = ({username, password}): Promise.t<option<Db.Users.t>> =>
  username
  ->Db.Users.getByUsername
  ->Promise.then(user =>
    switch user {
    | Some(user) =>
      password
      ->Bcrypt.compare(user.passwordHash)
      ->Promise.thenResolve(match => match ? Some(user) : None)
    | None => None->Promise.resolve
    }
  )

let sessionSecret = "very_secret"
let {
  Remix.getSession: getSession,
  commitSession,
  destroySession,
} = Remix.createCookieSessionStorage({
  cookie: Remix.CreateCookieSessionStorageCookieOptions.make(
    ~name="RJ_session",
    ~secure=true,
    ~secrets=[sessionSecret],
    ~sameSite=#lax,
    ~path="/",
    ~maxAge=60 * 60 * 24 * 30,
    ~httpOnly=true,
    (),
  ),
})

let getUserSession = (request: Webapi.Fetch.Request.t): Promise.t<Remix.Session.t> =>
  getSession(. request->Webapi.Fetch.Request.headers->Webapi.Fetch.Headers.get("Cookie"))

let getUserId = (request: Webapi.Fetch.Request.t): Promise.t<option<string>> => {
  request->getUserSession->Promise.thenResolve(session => session->Remix.Session.get("userId"))
}

let requireUserId = (request: Webapi.Fetch.Request.t): Promise.t<string> => {
  request
  ->getUserSession
  ->Promise.then(session =>
    switch session->Remix.Session.get("userId") {
    | Some(userId) => Promise.resolve(userId)
    | None => RemixHelpers.Promise.rejectResponse(Remix.redirect("/login"))
    }
  )
}

let logout = (request: Webapi.Fetch.Request.t): Promise.t<Webapi.Fetch.Response.t> =>
  getSession(. request->Webapi.Fetch.Request.headers->Webapi.Fetch.Headers.get("Cookie"))
  ->Promise.then(session => destroySession(. session))
  ->Promise.thenResolve(newCookie =>
    Remix.redirectWithInit(
      "/login",
      Webapi.Fetch.ResponseInit.make(
        ~headers=Webapi.Fetch.HeadersInit.make({"Set-Cookie": newCookie}),
        (),
      ),
    )
  )

let getUser = (request: Webapi.Fetch.Request.t): Promise.t<option<Db.Users.t>> =>
  request
  ->getUserId
  ->Promise.then(userId =>
    switch userId {
    | Some(userId) => Db.Users.getByUsername(userId)
    | None => None->Promise.resolve
    }
  )

let createUserSession = (userId: string, redirectTo: string): Promise.t<Webapi.Fetch.Response.t> =>
  getSession(. None)->Promise.then(session => {
    session->Remix.Session.set("userId", userId)
    commitSession(. session)->Promise.thenResolve(newCookie => {
      Remix.redirectWithInit(
        redirectTo,
        Webapi.Fetch.ResponseInit.make(
          ~headers=Webapi.Fetch.HeadersInit.make({"Set-Cookie": newCookie}),
          (),
        ),
      )
    })
  })
