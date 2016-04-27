React = require 'react'
{Link} = require 'react-router'

THREE_DAYS = 3 * 24 * 60 * 60 * 1000

module.exports = React.createClass

  displayName: "ProjectStateBanner"

  getDefaultProps: ->
    project: null
    dismissFor: THREE_DAYS

  getInitialState: ->
    hasResultsPage: false
    projectState: null

  componentDidMount: ->
    @refresh @props.project

  componentWillReceiveProps: (nextProps) ->
    unless nextProps.project is @props.project
      @refresh nextProps.project

  refresh: (project) ->
    @setState
      hasResultsPage: false
    Promise.all([
      @getProjectState project
      @getResultsPageExistence project
    ]).then ([projectState, hasResultsPage]) =>
      @setState { projectState, hasResultsPage}

  getProjectState: (project) ->
    if project.paused
      "paused"
    if project.finished
      "finished"

  getResultsPageExistence: (project) ->
    project.get('pages').then (pages) ->
      resultsPages = pages.filter (page) ->
        page.url_key is 'result'
      resultsPages[0]?

  hide: ->
    dismissals = JSON.parse(localStorage.getItem 'finished-project-dismissals') ? {}
    dismissals[@props.project.id] = Date.now()
    localStorage.setItem 'finished-project-dismissals', JSON.stringify dismissals
    @forceUpdate()

  render: ->
    dismissals = JSON.parse(localStorage.getItem 'finished-project-dismissals') ? {}
    recentlyDismissed = Date.now() - dismissals[@props.project.id] < @props.dismissFor

    if recentlyDismissed or @state.projectState is null
      null
    else
      <div className="successful project-announcement-banner">
        <p>
          <strong>Great work!</strong>{' '}
          This project is currently "#{@state.projectState}".
          <br />
          {if @state.hasResultsPage
            [owner, name] = @props.project.slug.split '/'
            <strong>
              <Link to="/projects/#{owner}/#{name}/results">See the results</Link>
            </strong>}{' '}
            <small>
              or{' '}
              <button type="button" className="secret-button" onClick={@hide}><u>dismiss this message</u></button>
            </small>
        </p>
      </div>
