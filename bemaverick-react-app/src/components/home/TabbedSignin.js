import React from 'react';
import MediaQuery from 'react-responsive';
import SquareBox from './SquareBox';
import Tab from '../../components/Tab';
import A from '../../components/common/A/index';
import SignupMaverickStep1 from '../../components/forms/SignupMaverickStep1';
// import SigninFormFamily from '../../components/forms/SigninFormFamily';
import SigninForm from '../../components/forms/SigninForm';

const styles = {
  container: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  tabContainer: {
    width: '50%',
  },
  tabContent: {
    display: 'inline-block',
    fontSize: '18px',
    textTransform: 'uppercase',
    paddingBottom: '3px',
    borderBottom: ' 3px solid #00B0AC',
  },
  smallBoxMobile: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100vw',
    padding: '10px 0 80px 0',
    backgroundColor: '#000000',
    color: '#ffffff',
    marginBottom: '-50px',
  },
  smallBoxTablet: {
    display: 'flex',
    justifyContent: 'center',
    width: '300px',
    margin: '20px -5% 0 0',
    padding: '15px',
    borderRadius: '3px',
    backgroundColor: '#000000',
    color: '#ffffff',
  },
};

export default class TabbedSignin extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentTab: 'mavericks',
    };
    this.handleTabClick = this.handleTabClick.bind(this);
  }

  handleTabClick(tabName) {
    this.setState({ currentTab: tabName });
  }

  render() {
    let signinContent = <div />;
    if (this.state.currentTab === 'mavericks') {
      /**
       * Mavericks Tab
       */

      signinContent = (
        <div style={styles.container}>
          <SquareBox>
            <Tab textColor="#ffffff" title="Mavericks" active />
            <span
              onClick={() => this.handleTabClick('families')}
              onKeyPress={() => this.handleTabClick('families')}
              role="menuitem"
              tabIndex={0}
            >
              <Tab textColor="#ffffff" title="Families" active={false} />
            </span>
            <SignupMaverickStep1 />
          </SquareBox>
          <MediaQuery query="(max-width: 575px)">
            <div style={styles.smallBoxMobile}>
              <span>
                Already a Maverick? &nbsp; <A href="/sign-in">Sign In</A>
              </span>
            </div>
          </MediaQuery>
          <MediaQuery query="(min-width: 576px)">
            <div style={styles.smallBoxTablet}>
              Already a Maverick? &nbsp; <A href="/sign-in">Sign In</A>
            </div>
          </MediaQuery>
        </div>
      );
    } else {
      /**
       * Family Tab
       */

      signinContent = (
        <div style={styles.container}>
          <SquareBox>
            <span
              onClick={() => this.handleTabClick('mavericks')}
              onKeyPress={() => this.handleTabClick('mavericks')}
              role="menuitem"
              tabIndex={0}
            >
              <Tab textColor="#ffffff" title="Mavericks" active={false} />
            </span>
            <Tab textColor="#ffffff" title="Families" active />
            <SigninForm theme="dark" usernameProps={{ label: 'Enter your email address' }} />
          </SquareBox>
          <MediaQuery query="(max-width: 575px)">
            <div style={styles.smallBoxMobile}>
              <p>
                <A href="/">Forgot password?</A>
              </p>
              <p>
                I need to &nbsp; <A href="/signin">confirm my Maverick’s account</A>
              </p>
            </div>
          </MediaQuery>
          <MediaQuery query="(min-width: 576px)">
            <div style={styles.smallBoxTablet}>
              I need to &nbsp; <A href="/signin">confirm my Maverick’s account</A>
            </div>
          </MediaQuery>
        </div>
      );
    }
    return signinContent;
  }
}
