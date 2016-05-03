React = require 'react'
TitleMixin = require '../../../lib/title-mixin'
{Markdown} = require 'markdownz'
ChangeListener = require '../../../components/change-listener'
PromiseRenderer = require '../../../components/promise-renderer'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'

counterpart.registerTranslations 'en',
    nav:
        research: 'Research'
        results: 'Results'
        faq: 'FAQ'
        education: 'Education'
        team: 'The Team'

module.exports = React.createClass
  displayName: 'About'

  mixins: [TitleMixin]

  title: 'About'

  getDefaultProps: ->
    project: null

  getPageTitles: (page) ->
    page.filter((page) -> page.content isnt '' and page.content?)
      .reduce(((accum, page) -> accum[page.url_key] = page.title; accum), {})

  render: ->
    <ChangeListener target={@props.project}>{=>
      <PromiseRenderer promise={@props.project.get 'owner'}>{(owner) =>
        [ownerName, name] = @props.project.slug.split('/')
        projectPath = "/projects/#{ownerName}/#{name}"

        <div className="about-container">
          <PromiseRenderer promise={@props.project.get 'pages'}>{(pages) =>
            pageTitles = @getPageTitles(pages)
            <span>
              {if pageTitles.science_case
                <Link to="#{projectPath}/about/research" activeClassName="active"className="about-tabs">
                  <Translate content= "nav.research" />
                </Link>}
              {unless @props.project.redirect
                <Link to="#{projectPath}/about/team" activeClassName="active" className="about-tabs">
                  <Translate content= "nav.team" />
                </Link>}
              {if pageTitles.results
                <Link to="#{projectPath}/about/results" activeClassName="active"className="about-tabs">
                  <Translate content= "nav.results" />
                </Link>}
              {if pageTitles.education
                <Link to="#{projectPath}/about/education" activeClassName="active" className="about-tabs">
                  <Translate content= "nav.education" />
                </Link>}
              {if pageTitles.faq
                <Link to="#{projectPath}/about/faq" activeClassName="active" className="about-tabs">
                  <Translate content= "nav.faq" />
                </Link>}
            </span>
          }</PromiseRenderer>

          {React.cloneElement(@props.children, {owner: owner, project: @props.project, user: @props.user})}

        </div>
      }</PromiseRenderer>
    }</ChangeListener>
