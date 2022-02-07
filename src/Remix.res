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
external jsonWithInit: ('a, Webapi.Fetch.ResponseInit.t) => Webapi.Fetch.Response.t = "json"

@module("remix") external redirect: string => Webapi.Fetch.Response.t = "redirect"
@module("remix")
external redirectWithInit: (string, Webapi.Fetch.ResponseInit.t) => Webapi.Fetch.Response.t =
  "redirect"

@module("remix") external useBeforeUnload: (@uncurry unit => unit) => unit = "useBeforeUnload"

@module("remix") external useLoaderData: unit => Js.Json.t = "useLoaderData"

@module("remix") external useActionData: unit => option<Js.Json.t> = "useActionData"

@module("remix") external useCatch: unit => Webapi.Fetch.Response.t = "useCatch"

@module("remix") external useParams: unit => params = "useParams"

type location
type submission = {
  action: string,
  method: [#get | #post | #put | #patch | #delete],
  formData: Webapi.FormData.t,
  encType: [#"application/x-www-form-urlencoded" | #"multipart/form-data"],
  key: string,
}
type transition = {
  state: [#idle | #submitting | #loading],
  @as("type")
  type_: [
    | #idle
    | #actionSubmission
    | #loaderSubmission
    | #loaderSubmissionRedirect
    | #actionReload
    | #actionRedirect
    | #fetchActionRedirect
    | #normalRedirect
    | #normalLoad
  ],
  submission: option<submission>,
  location: option<location>,
}
@module("remix") external useTransition: unit => transition = "useTransition"

type appLoadContext
type dataFunctionArgs = {
  request: Webapi.Fetch.Request.t,
  context: appLoadContext,
  params: params,
}
type routeData
type metaFunctionArgs = {
  data: option<Js.Json.t>,
  parentsData: routeData,
  params: params,
  location: location,
}
module HtmlMetaDescriptor = {
  type t

  external make: {..} => t = "%identity"
}
type metaFunction = metaFunctionArgs => HtmlMetaDescriptor.t

module HtmlLinkDescriptor = {
  type t

  @obj
  external make: (
    ~href: string,
    ~crossOrigin: [#anonymous | #"use-credentials"]=?,
    ~rel: [
      | #alternate
      | #"dns-prefetch"
      | #icon
      | #manifest
      | #modulepreload
      | #next
      | #pingback
      | #preconnect
      | #prefetch
      | #preload
      | #prerender
      | #search
      | #stylesheet
    ],
    ~media: string=?,
    ~integrity: string=?,
    ~hrefLang: string=?,
    @as("type") ~type_: string=?,
    ~referrerPolicy: [
      | #"no-referrer"
      | #"no-referrer-when-downgrade"
      | #"same-origin"
      | #origin
      | #"strict-origin"
      | #"origin-when-cross-origin"
      | #"strict-origin-when-cross-origin"
      | #"unsafe-url"
    ]=?,
    ~sizes: string=?,
    ~imagesrcset: string=?,
    ~imagesizes: string=?,
    @as("as")
    ~as_: [
      | #audio
      | #audioworklet
      | #document
      | #embed
      | #fetch
      | #font
      | #frame
      | #iframe
      | #image
      | #manifest
      | #object
      | #paintworklet
      | #report
      | #script
      | #serviceworker
      | #sharedworker
      | #style
      | #track
      | #video
      | #worker
      | #xslt
    ]=?,
    ~color: string=?,
    ~disabled: bool=?,
    ~title: string=?,
    unit,
  ) => t = ""
}
type linksFunction = unit => array<HtmlLinkDescriptor.t>

type headersFunctionArgs = {
  loaderHeaders: Webapi.Fetch.Headers.t,
  parentHeaders: Webapi.Fetch.Headers.t,
  actionHeaders: Webapi.Fetch.Headers.t,
}
type headersFunction = headersFunctionArgs => Webapi.Fetch.Headers.t

type loaderFunction = dataFunctionArgs => Js.Promise.t<Webapi.Fetch.Response.t>

type actionFunction = dataFunctionArgs => Js.Promise.t<Webapi.Fetch.Response.t>

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

module Session = {
  type t

  @send external has: (t, string) => bool = "has"
  @send external set: (t, string, string) => unit = "set"
  @send external flash: (t, string, string) => unit = "flash"
  @send external get: (t, string) => option<string> = "get"
  @send external unset: (t, string) => unit = "unset"
}

module SessionStorage = {
  type t

  @send external getSession: (t, option<string>) => Js.Promise.t<Session.t> = "getSession"
  @send external commitSession: (t, Session.t) => Js.Promise.t<string> = "commitSession"
  @send external destroySession: (t, Session.t) => Js.Promise.t<string> = "destroySession"
}

@module("remix")
external createCookieSessionStorage: createCookieSessionStorageOptions => SessionStorage.t =
  "createCookieSessionStorage"
