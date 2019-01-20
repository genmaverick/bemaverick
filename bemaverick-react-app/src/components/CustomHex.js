import React from 'react';
import PropTypes from 'prop-types';

export default class CustomHex extends React.Component {
  constructor(props) {
    super(props);
    this.state = { displayDetail: false };
    this.handleToggle = this.handleToggle.bind(this);
  }

  handleToggle() {
    if (this.state.displayDetail) {
      this.setState({ displayDetail: false });
    } else {
      this.setState({ displayDetail: true });
    }
  }

  render() {
    if (this.state.displayDetail) {
      return (
        <li className="hex" onMouseLeave={this.handleToggle}>
          <div className="hexIn">
            <div className="hexLink">
              <img src={this.props.img} alt={this.props.name} />
              <img src="" alt={this.props.name} style={{ backgroundColor: '#0c5975', opacity: '0.65' }} />
              <h1>{this.props.name}</h1>
              <p>{this.props.title}</p>
            </div>
          </div>
        </li>
      );
    }
    return (
      <li className="hex" onMouseEnter={this.handleToggle} >
        <div className="hexIn">
          <div className="hexLink">
            <img src={this.props.img} alt={this.props.name} />
          </div>
        </div>
      </li>
    );
  }
}

CustomHex.propTypes = {
  img: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
};
