import React from 'react';
import BlurredImage from './blurred-image';
import Pullout from 'react-pullout';
import getUserRibbonData from '../../lib/get-user-ribbon-data';
import CircleRibbon from './circle-ribbon';
import RecentProjectsSection from './recent-projects';
import RecentCollectionsSection from './recent-collections';
import RecentMessagesSection from './recent-messages';
import MyBuildsSection from './my-builds';
import ProjectStats from './project-stats';
import qs from 'qs';

import style from './index.styl';
void style;

const SECTIONS = {
  projects: RecentProjectsSection,
  collections: RecentCollectionsSection,
  messages: RecentMessagesSection,
  builds: MyBuildsSection,
};

const HomePageForUser = React.createClass({
  propTypes: {
    user: React.PropTypes.object,
    location: React.PropTypes.object,
  },

  getDefaultProps() {
    return {
      user: {},
    };
  },

  getInitialState() {
    return {
      backgroundSrc: '',
      showNews: false,
      ribbonData: [],
      loading: false,
      error: null,
      selectedProjectID: null,
      openSection: null,
    };
  },

  componentDidMount() {
    addEventListener('hashChange', this.handleHashChange);
    this.fetchRibbonData(this.props.user);
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.user !== this.props.user) {
      this.fetchRibbonData(nextProps.user);
    }
  },

  componentWillUnmount() {
    removeEventListener('hashChange', this.handleHashChange);
  },

  handleHashChange() {
    this.forceUpdate();
  },

  fetchRibbonData(user) {
    if (!user) {
      return;
    }

    this.setState({
      loading: true,
      error: null,
    });

    user.get('profile_header')
    .catch(() => {
      return [];
    })
    .then((profileHeaders) => {
      const profileHeader = [].concat(profileHeaders)[0];
      this.setState({
        backgroundSrc: profileHeader.src,
      });
    });

    getUserRibbonData(user)
    .then((ribbonData) => {
      this.setState({
        ribbonData: ribbonData,
      });
    })
    .catch((error) => {
      this.setState({
        error: error,
      });
    })
    .then(() => {
      this.setState({
        loading: false,
      });
    });
  },

  findProjectLink(project) {
    return `/projects/${project.slug}`;
  },

  toggleNews() {
    this.setState({
      showNews: !this.state.showNews,
    });
  },

  renderMenu() {
    return (
      <div className="home-page-for-user__menu">
        <div className="home-page-for-user__menu-column">
          <a href="#focus=projects" className="home-page-for-user__menu-button">
            <span className="home-page-for-user__menu-label">
              <i className="fa fa-cog fa-fw"></i>
              My recent projects
            </span>
          </a>
          <a href="#focus=collections" className="home-page-for-user__menu-button">
            <span className="home-page-for-user__menu-label">
              <i className="fa fa-cog fa-fw"></i>
              My collections
            </span>
          </a>
        </div>
        <div className="home-page-for-user__menu-column">
          <a href="#focus=messages" className="home-page-for-user__menu-button">
            <span className="home-page-for-user__menu-label">
              <i className="fa fa-cog fa-fw"></i>
              Messages
            </span>
          </a>
          <a href="#focus=builds" className="home-page-for-user__menu-button">
            <span className="home-page-for-user__menu-label">
              <i className="fa fa-cog fa-fw"></i>
              My builds
            </span>
          </a>
        </div>
      </div>
    );
  },

  render() {
    if (!this.props.user) return null;

    const hashQuery = qs.parse(this.props.location.hash.slice(1));

    const OpenSectionComponent = SECTIONS[hashQuery.focus];

    return (
      <div className="home-page-for-user">
        <BlurredImage className="home-page-for-user__background" src={this.state.backgroundSrc} blur="0.5em" position="50% 33%" />

        {!!this.state.error && (
          <div>{this.state.error.toString()}</div>
        )}

        {!!hashQuery.project ? (
          <ProjectStats projectID={hashQuery.project} onClose={this.deselectProject} />
        ) : (
          <div className="home-page-for-user__content" style={{ position: 'relative', zIndex: 1 }}>
            <CircleRibbon loading={this.state.loading} data={this.state.ribbonData} hrefTemplate={this.findProjectLink} />

            <div className="home-page-for-user__welcome">Hello, {this.props.user.display_name}</div>

            {OpenSectionComponent === undefined ? (
              this.renderMenu()
            ) : (
              <OpenSectionComponent user={this.props.user} onClose={this.deselectSection} />
            )}
          </div>
        )}

        <div className="content-container">
          <p style={{ textAlign: 'center' }}>Re-use social media from home page here.</p>
        </div>

        <Pullout className="home-page-news-pullout" side="right" open={this.state.showNews}>
          <button type="button" className="secret-button home-page-news-pullout__toggle-button" onClick={this.toggleNews}>
            <div className="home-page-news-pullout__toggle-label">
              <i className="fa fa-cog fa-fw"></i>
              <br />
              News
            </div>
          </button>

          <p>News thing 1</p>
          <p>News thing 2</p>
          <p>News thing 3</p>
        </Pullout>
      </div>
    );
  },
});

export default HomePageForUser;
