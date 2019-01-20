import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import NavigationMenuIcon from 'material-ui/svg-icons/navigation/menu';
import Drawer from 'material-ui/Drawer';
import CloseIcon from 'material-ui/svg-icons/navigation/close';
import Divider from 'material-ui/Divider';
import { warmGreyBackgroundLight } from '../../assets/colors';
import Icon from '../Icon';
import logoImg from '../../assets/images/logo-secondary-black.svg';
import SidebarMenuItem from './SidebarMenuItem';

const styles = {
  menuIcon: {
    color: '#000000',
    height: '20px',
  },
  drawer: {
    width: '80%',
    style: {
      boxShadow: 'none',
    },
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    width: '100%',
    height: '60px',
    paddingLeft: '15px',
    backgroundColor: warmGreyBackgroundLight,
  },
  closeIcon: {
    width: '30px',
    height: '30px',
    marginRight: '15px',
    cursor: 'pointer',
  },
};

class MobileSidebarMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = { open: false };
    this.handleToggle = this.handleToggle.bind(this);
    this.handleClose = this.handleToggle.bind(this);
  }

  handleToggle() {
    this.setState({ open: !this.state.open });
  }

  handleClose() {
    this.setState({ open: false });
  }

  render() {
    const isLoggedIn = this.props.user !== false; // eslint-disable-line no-unused-vars
    let menuItems;

    if (isLoggedIn) {
      menuItems = [
        <SidebarMenuItem title="Dashboard" href="/" key="dashboard" />,
        <Divider key="divider1" />,
        <SidebarMenuItem title="Challenges" href="/challenges" key="challenges" />,
        <Divider key="divider2" />,
        <SidebarMenuItem title="Account" href={`/users/${this.props.user.userId}/settings`} key="account" />,
        <Divider key="divider3" />,
        <SidebarMenuItem title="Logout" href="/auth/logout-confirm" key="logout" />,
      ];
    } else {
      menuItems = [
        <SidebarMenuItem title="Challenges" href="/challenges" key="challenges" />,
        <Divider key="divider2" />,
        <SidebarMenuItem title="Sign In" route="/sign-in" key="sign-in" />,
        <Divider key="divider1" />,
        <SidebarMenuItem title="Sign Up" route="/sign-up" key="sign-out" />,
        <Divider key="divider2" />,
      ];
    }

    return (
      <div>
        <NavigationMenuIcon
          label="Open Drawer"
          onClick={this.handleToggle}
          color={styles.menuIcon.color}
        />
        <Drawer
          docked={false}
          width={styles.drawer.width}
          styles={styles.drawer.style}
          openSecondary
          open={this.state.open}
          onRequestChange={open => this.setState({ open })}
        >

          <span role="menuitem" style={styles.header}>
            <CloseIcon
              color="#000000"
              style={styles.closeIcon}
              onClick={this.handleClose}
            />
            <Icon
              imgUrl={logoImg}
              href="/"
              altText="maverick-link-home"
              height="35px"
            />
          </span>
          {menuItems}
        </Drawer>
      </div>
    );
  }
}

MobileSidebarMenu.propTypes = {
  user: PropTypes.oneOfType([PropTypes.object, PropTypes.bool]),
};

MobileSidebarMenu.defaultProps = {
  user: false,
};

const mapStateToProps = state => ({
  user: state.global.user || false,
});
export default connect(mapStateToProps)(MobileSidebarMenu);
