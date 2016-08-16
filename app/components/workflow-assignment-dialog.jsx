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
    return history.replace({
      pathname: location.pathname,
      search: `?workflow=${preferences.preferences.selected_workflow}`,
    });
  }

  static handleStayOnCurrentWorkflowAssignment(location, preferences) {
    // Switch user back to workflow in query rather than nero assigned workflow
    // TODO: Maybe if user selects after 3 prompts, opt out?
    preferences.update({ 'preferences.selected_workflow': location.query.workflow });
    return preferences.save();
  }

  render() {
    return (
      <div className="content-container">
        <p>
          You've done a great job classifying.
          We'd like to recommend a more advanced task workflow for you to try out.
        </p>
        <p>
          You now have a setting in your profile if you change your mind
          want to change which workflow you are on later.
        </p>
        <button type="submit">Try the new workflow</button>
      </div>
    );
  }
}

