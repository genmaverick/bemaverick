import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import A from '../common/A/navigation';

const NavBar = ({ user }) => {
  // console.log('Header.user', user);
  const isLoggedIn = user !== false; // eslint-disable-line no-unused-vars

  if (isLoggedIn) {
    return [
      <A href="/" key="dashboard" header>
        Dashboard
      </A>,
      <A href="/challenges" key="challenges" header>
        Challenges
      </A>,
      <A href={`/users/${user.userId}/settings`} key="account" header>
        Account
      </A>,
      <A href="/auth/logout-confirm" key="sign-out" header>
        Sign Out
      </A>,
    ];
  }
  return [
    <A href="/challenges" key="challenges" header>
      Challenges
    </A>,
    <A route="/sign-in" key="sign-in" header>
      Sign In
    </A>,
    <A route="/sign-up" key="sign-up" header>
      Sign Up
    </A>,
  ];
};

NavBar.propTypes = {
  user: PropTypes.oneOfType([PropTypes.object, PropTypes.bool]),
};

NavBar.defaultProps = {
  user: false,
};

const mapStateToProps = state => ({
  user: state.global.user || false,
});
export default connect(mapStateToProps)(NavBar);
