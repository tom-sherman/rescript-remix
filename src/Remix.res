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
  ) => React.element = "Form"
}

@module("remix") external json: {..} => Webapi.Fetch.Response.t = "json"

@module("remix") external redirect: string => Webapi.Fetch.Response.t = "redirect"

@module("remix") external useBeforeUnload: (@uncurry unit => unit) => unit = "useBeforeUnload"

@module("remix") external useLoaderData: unit => 'a = "useLoaderData"

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

module Response = {
  type t<'a> = Webapi.Fetch.Response.t
  @module("remix") external json: 'a => t<'a> = "json"
  @module("remix") external jsonWithInit: ('a, Webapi.Fetch.ResponseInit.t) => t<'a> = "json"

  @module("remix") external redirect: string => t<'a> = "redirect"
  @module("remix")
  external redirectWithInit: (string, Webapi.Fetch.ResponseInit.t) => t<'a> = "redirect"
}

module DataFunctionInput = {
  // Defined as opaque so that user bindings can be added for `LoaderInput.context(input)`
  type t
  @get external params: t => Js.Dict.t<string> = "params"
  @get external request: t => Webapi.Fetch.Request.t = "request"
}

module type Loadable = {
  type t
  let loader: DataFunctionInput.t => Js.Promise.t<t>
}

module Loader = (Loadable: Loadable) => {
  include Loadable

  @module("remix") external use: unit => t = "useLoaderData"
}

module type LoadableResponse = {
  type t
  let loader: DataFunctionInput.t => Js.Promise.t<Response.t<t>>
}

module LoaderResponse = (LoadableResponse: LoadableResponse) => {
  type t = LoadableResponse.t
  let loader = (LoadableResponse.loader: DataFunctionInput.t => Js.Promise.t<Response.t<t>>)

  @module("remix") external use: unit => t = "useLoaderData"
}
