type loginForm = {username: string, password: string}

let register = ({username, password}): Promise.t<unit> =>
  {Model.Users.username: username, password: password}->Model.Users.create

let login = ({username, password}): Promise.t<option<Model.Users.t>> =>
  username
  ->Model.Users.getByUsername
  ->Promise.thenResolve(user =>
    switch user {
    | None => None
    | Some(user) =>
      if user.password == password {
        Some(user)
      } else {
        None
      }
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

let getUserId = (request: Webapi.Fetch.Request.t): Js.Promise.t<option<string>> => {
  request->getUserSession->Promise.thenResolve(session => session->Remix.Session.get("userId"))
}

let requireUserId = (request: Webapi.Fetch.Request.t): Js.Promise.t<string> => {
  request
  ->getUserSession
  ->Promise.then(session =>
    switch session->Remix.Session.get("userId") {
    | Some(userId) => Promise.resolve(userId)
    | None => RemixHelpers.rejectWithResponse(Remix.redirect("/login"))
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

let getUser = (request: Webapi.Fetch.Request.t): Promise.t<option<Model.Users.t>> =>
  request
  ->getUserId
  ->Promise.then(userId =>
    switch userId {
    | Some(userId) => Model.Users.getByUsername(userId)
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
