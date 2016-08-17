import React from 'react';
import Dialog from 'modal-form/dialog';

export default class WorkflowAssignmentDialog extends React.Component {
  static start(history, location, preferences) {
    // const WorkflowAssignmentDialog = this;
    return Dialog.alert(<WorkflowAssignmentDialog />, {
      className: 'workflow-assignment-dialog',
      closeButton: true,
      onCancel: this.handleStayOnCurrentWorkflowAssignment.bind(null, location, preferences),
      onSubmit: this.handleNewWorklfowAssignment.bind(null, history, location, preferences),
    });
  }

  static handleNewWorklfowAssignment(history, location, preferences) {
    preferences.update({ 'preferences.selected_workflow': preferences.settings.workflow_id });
    preferences.save();
    return history.replace({
      pathname: location.pathname,
      search: `?workflow=${preferences.settings.workflow_id}`,
    });
  }

  static handleStayOnCurrentWorkflowAssignment(location, preferences) {
    // Switch user back to workflow in query rather than nero assigned workflow
    // TODO: Maybe if user selects after 3 prompts, opt out?
    if (preferences.selected_workflow === undefined || preferences.selected_workflow === null) {
      preferences.update({ 'preferences.selected_workflow': location.query.workflow });
      return preferences.save();
    }

    return null;
  }

  render() {
    return (
      <div className="content-container">
        <p>
          Congratulations! Because you're doing so well, you can level up and
          access more types of glitches, have more options for classifying them,
          and see glitches that our computer algorithms are even less confident in.
          If you prefer to stay at this level, you can choose to stay. You can switch
          back to a previous workflow from the project home page.
        </p>
        <button type="submit">Try the new workflow</button>
      </div>
    );
  }
}

