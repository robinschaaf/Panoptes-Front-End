React = require 'react'
{Link} = require 'react-router'
ChangeListener = require '../../../components/change-listener'

module.exports = React.createClass
  displayName: 'AboutEditor'

  getDefaultProps: ->
    project: id: '2'

  labPath: (postFix = '') ->
    "/lab/#{@props.project.id}#{postFix}"

  render: ->
    linkParams =
      projectID: @props.project.id
    <div>
      <span>
        <Link to={@labPath('/about/research')} activeClassName="active" className="tabbed-content-tab">
          Research
        </Link>
        <Link to={@labPath('/about/team')} activeClassName="active" className="tabbed-content-tab">
          Team
        </Link>
        <Link to={@labPath('/about/results')} activeClassName="active" className="tabbed-content-tab">
          Results
        </Link>
        <Link to={@labPath('/about/education')} activeClassName="active" className="tabbed-content-tab">
          Education
        </Link>
        <Link to={@labPath('/about/faq')} activeClassName="active" className="tabbed-content-tab">
          FAQ
        </Link>
      </span>
      {React.cloneElement(@props.children, {project: @props.project, user: @props.user})}
    </div>
