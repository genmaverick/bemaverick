import React from 'react';
import PropTypes from 'prop-types';
import { Link } from '../routes';

const Icon = ({
  imgUrl, route, href, altText, height,
}) => {
  if (route !== '') {
    return (
      <Link route={route}>
        <a>
          <img style={{ height }} src={imgUrl} alt={altText} />
        </a>
      </Link>
    );
  }
  return (
    <div>
      <a href={href}>
        <img style={{ height }} src={imgUrl} alt={altText} />
      </a>
    </div>
  );
};

Icon.propTypes = {
  imgUrl: PropTypes.string.isRequired,
  route: PropTypes.string,
  href: PropTypes.string,
  altText: PropTypes.string.isRequired,
  height: PropTypes.string,
};

Icon.defaultProps = {
  route: '',
  href: '',
  height: '40px',
};
export default Icon;
