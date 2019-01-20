import React from 'react';
import PropTypes from 'prop-types';
import MenuItem from 'material-ui/MenuItem';
import { Link } from '../../routes';

const styles = {
  link: {
    textDecoration: 'none',
  },
  menuItem: {
    style: {
      padding: '10px',
      textAlign: 'left',
      textTransform: 'uppercase',
      fontSize: '18px',
      textDecoration: 'none',
    },
  },
};

const SidebarMenuItem = ({ title, href, route }) => {
  if (route !== '') {
    return (
      <Link route={route}>
        <a style={styles.link}><MenuItem primaryText={title} style={styles.menuItem.style} /></a>
      </Link>
    );
  }
  return (
    <a href={href} style={styles.link}>
      <MenuItem primaryText={title} style={styles.menuItem.style} />
    </a>
  );
};

SidebarMenuItem.propTypes = {
  title: PropTypes.string.isRequired,
  href: PropTypes.string,
  route: PropTypes.string,
};

SidebarMenuItem.defaultProps = {
  route: '',
  href: '',
};

export default SidebarMenuItem;
