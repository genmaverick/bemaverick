/* eslint import/first: 0 */
import React from 'react';
import { borderDark, textDark, textLight } from '../../assets/colors';
import PropTypes from 'prop-types';
import P from '../common/P';

// TODO: implement mediaQueries w/ Radium
// https://github.com/FormidableLabs/radium/tree/master/docs/guides#media-queries

const styles = {
  wrapper: {
    display: 'flex',
    alignItems: 'center',
  },
  avatarWrapper: {
    marginRight: 30,
    paddingRight: 30,
    width: 100,
    borderRight: `3px solid ${borderDark}`,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  avatarImg: {
    maxWidth: 50,
    clipPath: 'circle(25px at center)',
  },
  avatar: {},
  name: {
    marginTop: 5,
    color: textDark,
    fontSize: '11pt',
    fontWeight: '600',
  },
  bio: { color: textLight, fontSize: '12pt' },
};

const AuthorHeadline = ({ username, bio, avatar }) => (
  <section style={styles.wrapper}>
    <section style={styles.avatarWrapper}>
      <section style={styles.avatar}>
        <img src={avatar} alt={`${username} avatar`} style={styles.avatarImg} />
      </section>
      <section style={styles.name}>{username}</section>
    </section>
    {bio && <section><P color={textLight}>{bio}</P></section>}
  </section>
);
AuthorHeadline.propTypes = {
  username: PropTypes.string.isRequired,
  bio: PropTypes.string,
  avatar: PropTypes.string.isRequired,
};

AuthorHeadline.defaultProps = {
  bio: false,
};

AuthorHeadline.defaultProps = {};

export default AuthorHeadline;
