module Main exposing (..)

import Browser
import Html exposing (Html, button, div, footer, h3, header, input, section, span, text, textarea)
import Html.Attributes exposing (class, style, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE exposing (..)
import String exposing (length)



---- MODEL ----


type alias Model =
    { todolist : List Todo
    , errorMessage : Maybe String
    , isShown : Bool
    , todo : Todo

    -- , intialTodoforInsertion : Todo
    , title : String
    , description : String
    , completion_status : Bool
    }


type alias Todo =
    { id : Int
    , title : String
    , description : String
    , completion_status : Bool
    }


intialTodo : { id : number, title : String, description : String, completion_status : Bool }
intialTodo =
    { id = 0
    , title = ""
    , description = ""
    , completion_status = False
    }


init : ( Model, Cmd Msg )
init =
    ( { todolist = []
      , errorMessage = Nothing
      , isShown = False
      , todo = intialTodo
      , title = ""
      , description = ""
      , completion_status = False
      }
    , loadTodo
    )



---- UPDATE ----


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error (List Todo))
      -----------------------------
    | ShowAddTodo
    | CancelTodo
      -------------------------------
    | AddTodo
    | Title String
    | Description String
    | Completion_status Bool
    | TodoCreated (Result Http.Error Todo)
      ----------------------------------
    | DeleteTask Int
    | TodoDeleted (Result Http.Error ())



-- | CreatedTodo (Result Http.Error Todo)


todoparser : JD.Decoder Todo
todoparser =
    JD.succeed Todo
        |> JDP.required "id" JD.int
        |> JDP.required "title" JD.string
        |> JDP.required "description" JD.string
        |> JDP.required "completion_status" JD.bool


type alias Data =
    { data : Todo
    }


testparser : JD.Decoder Data
testparser =
    JD.succeed Data
        |> JDP.required "todo" todoparser


loadTodo : Cmd Msg
loadTodo =
    Http.get
        { url = "http://localhost:4000/api/todos/"
        , expect = Http.expectJson DataReceived (JD.list todoparser)
        }


addTodo : Model -> Cmd Msg
addTodo model =
    Http.post
        { url = "http://localhost:4000/api/todos"
        , body = Http.jsonBody (encodedObject model)
        , expect = Http.expectJson TodoCreated todoparser
        }



-- encodedObject model |> Http.jsonBody


encodeTodo : Model -> JE.Value
encodeTodo model =
    JE.object
        [ ( "completion_status", JE.bool True )
        , ( "description", JE.string model.description )
        , ( "title", JE.string model.title )
        ]


encodedObject : Model -> JE.Value
encodedObject model =
    JE.object
        [ ( "todo", encodeTodo model ) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, loadTodo )

        DataReceived (Ok posts) ->
            ( { model
                | todolist = posts
                , errorMessage = Nothing
              }
            , Cmd.none
            )

        DataReceived (Err httpError) ->
            ( { model
                | errorMessage = Just (buildErrorMessage httpError)
              }
            , Cmd.none
            )

        ShowAddTodo ->
            ( { model | isShown = True }, Cmd.none )

        CancelTodo ->
            ( { model | isShown = False }, Cmd.none )

        ----------------------------------------------------------
        AddTodo ->
            ( model, addTodo model )

        TodoCreated result ->
            case result of
                Ok t ->
                    ( { model | todo = t, errorMessage = Nothing }, loadTodo )

                Err er ->
                    ( { model | errorMessage = Just (buildErrorMessage er) }, loadTodo )

        Title title ->
            ( { model | title = title }, Cmd.none )

        Description desp ->
            ( { model | description = desp }, Cmd.none )

        Completion_status status ->
            ( { model | completion_status = status }, Cmd.none )

        DeleteTask item ->
            ( model, removeTask item )

        TodoDeleted result ->
            case result of
                Ok _ ->
                    ( model, loadTodo )

                Err _ ->
                    ( model, Cmd.none )


removeTask : Int -> Cmd Msg
removeTask task_id =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectWhatever TodoDeleted
        , headers = []
        , method = "DELETE"
        , timeout = Nothing
        , tracker = Nothing
        , url = "http://localhost:4000/api/todos/" ++ String.fromInt task_id
        }


viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            dataitemsrender model.todolist


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


dataitemsrender : List { a | title : String, description : String, completion_status : Bool, id : Int } -> Html Msg
dataitemsrender lst =
    div []
        (List.map
            (\element ->
                div [ class "list-container" ]
                    [ div [ class "title-section-list" ]
                        [ text
                            ("   Title :"
                                ++ element.title
                                ++ "   ||       "
                                ++ " Description :"
                                ++ element.description
                                ++ "    ||        "
                                ++ "Status : "
                                ++ (if element.completion_status == True then
                                        "Completed"

                                    else
                                        "Un-Completed"
                                   )
                            )
                        ]
                    , button [ class "mdi mdi-delete-empty delete-section", onClick (DeleteTask element.id) ] []

                    -- onClick (DeleteTodo todo.id)
                    ]
            )
            lst
        )


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    div [ class "container" ]
        [ header []
            [ div [ class "header-icon" ] [ span [ class "mdi mdi-calendar-check" ] [] ]
            , div [ class "todo-content" ]
                [ span [ class "todo-header" ] [ text "TODO" ]
                , span [ class "todo-description" ] [ text "Track Activities" ]
                ]
            ]
        , section [ class "section-part" ]
            [ div []
                [ button
                    [ class "add-todo-button", onClick ShowAddTodo ]
                    [ text "ADD TODO" ]
                ]
            , if model.isShown then
                showAddTodo model

              else
                viewPostsOrError model
            , footer [] []
            ]
        ]


viewInput : String -> String -> (String -> msg) -> Html msg
viewInput t v toMsg =
    input [ type_ t, value v, onInput toMsg ] []



-- showAddTodo : Model -> Html Msg


showAddTodo : { todolist : List Todo, errorMessage : Maybe String, isShown : Bool, todo : Todo, title : String, description : String, completion_status : Bool } -> Html Msg
showAddTodo model =
    div [ class "add-todo" ]
        [ div [ class "title-section" ]
            [ span [] [ text "Title" ]
            , viewInput "text" model.title Title
            ]
        , div [ class "descriptio-section" ]
            [ span [] [ text "Description" ]
            , textarea []
                [ viewInput "text" model.description Description
                ]
            ]
        , viewValidation model
        , div [ class "functionality-section" ]
            [ button [ class "add-todo-button add-btn", onClick AddTodo ] [ text "ADD" ]
            , button [ onClick CancelTodo, class "add-todo-button cancel-btn" ] [ text "Cancel" ]
            ]
        ]


viewValidation : Model -> Html msg
viewValidation model =
    if length model.title >= 1 then
        div [ style "color" "green" ] [ text "OK" ]

    else
        div [ style "color" "red" ] [ text "Insert Some Title" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
