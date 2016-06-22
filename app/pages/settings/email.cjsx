React = require 'react'
talkClient = require 'panoptes-client/lib/talk-client'
AutoSave = require '../../components/auto-save'
PromiseRenderer = require '../../components/promise-renderer'
ChangeListener = require '../../components/change-listener'
handleInputChange = require '../../lib/handle-input-change'

GRAVITY_SPY_ID = if process.env.NODE_ENV is 'production' then '1104' else '1616' # staging test project

module.exports = React.createClass
  displayName: 'EmailSettingsPage'

  getDefaultProps: ->
    user: null

  getInitialState: ->
    page: 1
    gravitySpyDetails: null

  componentDidMount: ->
    @props.user.get 'project_preferences', project_id: GRAVITY_SPY_ID
      .then ([projectPreferences]) =>
        gravitySpyDetails = {}
        if projectPreferences
          gravitySpyDetails.projectPreferences = projectPreferences
          projectPreferences.get('project').then (project) =>
            gravitySpyDetails.displayName = project.display_name
            @setState gravitySpyDetails: gravitySpyDetails

  nameOfPreference: (preference) ->
    switch preference.category
      when 'participating_discussions' then "When discussions I'm participating in are updated"
      when 'followed_discussions' then "When discussions I'm following are updated"
      when 'mentions' then "When I'm mentioned"
      when 'group_mentions' then "When I'm mentioned by group (@admins, @team, etc)"
      when 'messages' then 'When I receive a private message'
      when 'started_discussions' then "When a discussion is started in a board I'm following"

  sortPreferences: (preferences) ->
    order = ['participating_discussions', 'followed_discussions', 'started_discussions', 'mentions', 'group_mentions', 'messages']
    preferences.sort (a, b) ->
      order.indexOf(a.category) > order.indexOf(b.category)

  handlePreferenceChange: (preference, event) ->
    preference.update(email_digest: event.target.value).save()

  talkPreferenceOption: (preference, digest) ->
    <td className="option">
      <input type="radio"
        name={preference.category}
        value={digest}
        checked={preference.email_digest is digest}
        onChange={@handlePreferenceChange.bind this, preference}
      />
    </td>

  render: ->
    <div className="content-container">
      <section>
        <h3>Email Settings</h3>
        <p>
          <AutoSave resource={@props.user}>
            <span className="form-label">Email address</span>
            <br />
            <input type="text" className="standard-input full" name="email" value={@props.user.email} onChange={handleInputChange.bind @props.user} />
          </AutoSave>
        </p>
        <p><strong>Zooniverse email preferences</strong></p>
        <p>
          <AutoSave resource={@props.user}>
            <label>
              <input type="checkbox" name="global_email_communication" checked={@props.user.global_email_communication} onChange={handleInputChange.bind @props.user} />{' '}
              Get general Zooniverse email updates
            </label>
          </AutoSave>
          <br />
          <AutoSave resource={@props.user}>
            <label>
              <input type="checkbox" name="project_email_communication" checked={@props.user.project_email_communication} onChange={handleInputChange.bind @props.user} />{' '}
              Get email updates from the Projects you classify on
            </label>
          </AutoSave>
          <br />
          <AutoSave resource={@props.user}>
            <label>
              <input type="checkbox" name="beta_email_communication" checked={@props.user.beta_email_communication} onChange={handleInputChange.bind @props.user} />{' '}
              Get beta project email updates
            </label>
          </AutoSave>
        </p>

        <p><strong>Talk email preferences</strong></p>
        <table className="talk-email-preferences">
          <thead>
            <tr>
              <th>Send me an email</th>
              <th>Immediately</th>
              <th>Daily</th>
              <th>Weekly</th>
              <th>Never</th>
            </tr>
          </thead>
          <PromiseRenderer promise={talkClient.type('subscription_preferences').get()} pending={-> <tbody></tbody>} then={(preferences) =>
            <tbody>
              {for preference in @sortPreferences(preferences) when preference.category isnt 'system' and preference.category isnt 'moderation_reports' then do (preference) =>
                <ChangeListener key={preference.id} target={preference} handler={=>
                  <tr>
                    <td>{@nameOfPreference(preference)}</td>
                    {@talkPreferenceOption preference, 'immediate'}
                    {@talkPreferenceOption preference, 'daily'}
                    {@talkPreferenceOption preference, 'weekly'}
                    {@talkPreferenceOption preference, 'never'}
                  </tr>
                } />
              }
            </tbody>
          } />
        </table>

        <p><strong>Project email preferences</strong></p>
        <table>
          <thead>
            <tr>
              <th><i className="fa fa-envelope-o fa-fw"></i></th>
              <th>Project</th>
            </tr>
          </thead>
          <PromiseRenderer promise={@props.user.get 'project_preferences', page: @state.page} pending={=> <tbody></tbody>} then={(projectPreferences) =>
            meta = projectPreferences[0].getMeta()
            <tbody>
              {for projectPreference in projectPreferences then do (projectPreference) =>
                <PromiseRenderer key={projectPreference.id} promise={projectPreference.get 'project'} then={(project) =>
                  <ChangeListener target={projectPreference} handler={=>
                    <tr>
                      <td><input type="checkbox" name="email_communication" checked={projectPreference.email_communication} onChange={@handleProjectEmailChange.bind this, projectPreference} /></td>
                      <td>{project.display_name}</td>
                    </tr>
                  } />
                } />}
              <tr>
                <td colSpan="2">
                  {if meta?
                    <nav className="pagination">
                      Page <select value={@state.page} disabled={meta.page_count < 2} onChange={(e) => @setState page: e.target.value}>
                        {for p in [1..meta.page_count]
                          <option key={p} value={p}>{p}</option>}
                      </select> of {meta.page_count || '?'}
                    </nav>}
                </td>
              </tr>
            </tbody>
          } />
        </table>
      </section>
      <hr />
      <section className="project-settings">
        <h3>Project Settings</h3>
        {if @state.gravitySpyDetails?
          <div className="project-settings__project">
            <p className="project-settings__project-display-name">{@state.gravitySpyDetails.displayName}</p>
            {#<p>Workflow Level Achieved: </p><span className="form-help">Workflows can be selected from the project home page.</span>}
            <label className="project-settings__project-setting">
              <input type="checkbox" checked={!@state.gravitySpyDetails.projectPreferences.preferences.workflow_assignment_opt_out} onChange={@handleGravitySpyWorkflowAssignmentOptOut.bind null, this} />
              Allow {@state.gravitySpyDetails.displayName} to automatically assign workflows
            </label>
          </div>
        else  
          <p>No project specific settings found.</p>}
      </section>
    </div>

  handleProjectEmailChange: (projectPreference, args...) ->
    handleInputChange.apply projectPreference, args
    projectPreference.save()

  handleGravitySpyWorkflowAssignmentOptOut: (element) ->
    console.log('hey', element)
    # @state.gravitySpyDetails.projectPreferences.update "preferences.workflow_assignment_opt_out": element.checked
    # @state.gravitySpyDetails.projectPreferences.save()
