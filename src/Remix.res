@val external process: 'a = "process"

module RemixBrowser = {
  @module("remix") @react.component external make: unit => React.element = "RemixBrowser"
}

type entryContext

module RemixServer = {
  @module("remix") @react.component
  external make: (~context: entryContext, ~url: string) => React.element = "RemixServer"
}

module Meta = {
  @module("remix") @react.component
  external make: unit => React.element = "Meta"
}

module Links = {
  @module("remix") @react.component
  external make: unit => React.element = "Links"
}

module Outlet = {
  @module("remix") @react.component
  external make: (~context: 'a=?) => React.element = "Outlet"
}

module ScrollRestoration = {
  @module("remix") @react.component
  external make: unit => React.element = "ScrollRestoration"
}

module Scripts = {
  @module("remix") @react.component
  external make: unit => React.element = "Scripts"
}

module LiveReload = {
  @module("remix") @react.component
  external make: (~port: int=?) => React.element = "LiveReload"
}

module Link = {
  @module("remix") @react.component
  external make: (
    ~prefetch: [#intent | #render | #none]=?,
    ~to: string,
    ~reloadDocument: bool=?,
    ~replace: bool=?,
    ~state: 'a=?,
    ~children: React.element,
    ~className: string=?,
    ~title: string=?,
    ~ariaLabel: string=?,
  ) => React.element = "Link"
}

module Form = {
  @module("remix") @react.component
  external make: (
    ~method: [#get | #post | #put | #patch | #delete]=?,
    ~action: string=?,
    ~encType: [#"application/x-www-form-urlencoded" | #"multipart/form-data"]=?,
    ~reloadDocument: bool=?,
    ~replace: bool=?,
    ~onSubmit: @uncurry ReactEvent.Form.t => unit=?,
    ~children: React.element,
  ) => React.element = "Form"
}

type params = Js.Dict.t<string>

@module("remix") external json: 'a => Webapi.Fetch.Response.t = "json"
@module("remix")
external jsonWithInit: ({..}, Webapi.Fetch.ResponseInit.t) => Webapi.Fetch.Response.t = "json"

@module("remix") external redirect: string => Webapi.Fetch.Response.t = "redirect"
@module("remix")
external redirectWithInit: (string, Webapi.Fetch.ResponseInit.t) => Webapi.Fetch.Response.t =
  "redirect"

@module("remix") external useBeforeUnload: (@uncurry unit => unit) => unit = "useBeforeUnload"

@module("remix") external useLoaderData: unit => 'a = "useLoaderData"

@module("remix") external useActionData: unit => option<'a> = "useActionData"

@module("remix") external useCatch: unit => Webapi.Fetch.Response.t = "useCatch"

@module("remix") external useParams: unit => params = "useParams"

type appLoadContext
type dataFunctionArgs = {
  request: Webapi.Fetch.Request.t,
  context: appLoadContext,
  params: params,
}
type loaderFunction<'resultType> = dataFunctionArgs => Js.Promise.t<'resultType>
type loaderFunctionForData<'resultType> = dataFunctionArgs => Js.Promise.t<'resultType>
type loaderFunctionForResponse = dataFunctionArgs => Js.Promise.t<Webapi.Fetch.Response.t>

type actionFunctionForResponse = dataFunctionArgs => Js.Promise.t<Webapi.Fetch.Response.t>

type catchBoundaryComponent = unit => React.element

type errorBoundaryComponentProps = {error: Js.Exn.t}
type errorBoundaryComponent = errorBoundaryComponentProps => React.element

module Cookie = {
  type t

  @get external name: t => string = "name"
  @get external isSigned: t => bool = "isSigned"
  @get @return(undefined_to_opt) external expires: t => option<Js.Date.t> = "isSigned"
  @send external serialize: (t, {..}) => Js.Promise.t<string> = "serialize"
  @module("remix") external isCookie: 'a => bool = "isCookie"

  type parseOptions = {decode: string => string}
  @send external parse: (t, option<string>) => {..} = "parse"
  @send external parseWithOptions: (t, option<string>, parseOptions) => {..} = "parse"
}

module CreateCookieOptions = {
  type t

  @obj
  external make: (
    ~decode: string => string=?,
    ~encode: string => string=?,
    ~domain: string=?,
    ~expires: Js.Date.t=?,
    ~httpOnly: bool=?,
    ~maxAge: int=?,
    ~path: string=?,
    ~sameSite: [#lax | #strict | #none]=?,
    ~secure: bool=?,
    ~secrets: array<string>=?,
    unit,
  ) => t = ""
}

@module("remix") external createCookie: string => Cookie.t = "createCookie"
@module("remix")
external createCookieWithOptions: (string, CreateCookieOptions.t) => Cookie.t = "createCookie"

module CreateCookieSessionStorageCookieOptions = {
  type t

  @obj
  external make: (
    ~name: string=?,
    ~decode: string => string=?,
    ~encode: string => string=?,
    ~domain: string=?,
    ~expires: Js.Date.t=?,
    ~httpOnly: bool=?,
    ~maxAge: int=?,
    ~path: string=?,
    ~sameSite: [#lax | #strict | #none]=?,
    ~secure: bool=?,
    ~secrets: array<string>=?,
    unit,
  ) => t = ""
}
type createCookieSessionStorageOptions = {cookie: CreateCookieSessionStorageCookieOptions.t}

type session = Js.Dict.t<string>
type sessionStorage = {
  getSession: (. option<string>) => Js.Promise.t<session>,
  commitSession: (. session) => Js.Promise.t<string>,
  destroySession: (. session) => Js.Promise.t<string>,
}
@module("remix")
external createCookieSessionStorage: createCookieSessionStorageOptions => sessionStorage =
  "createCookieSessionStorage"
