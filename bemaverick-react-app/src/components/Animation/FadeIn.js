import React, { Component } from 'react';

export default class FadeIn extends Component {
  state = {
    maxIsVisible: 0,
  };

  get delay() {
    return this.props.delay || 50;
  }

  get transitionDuration() {
    return this.props.transitionDuration || 400;
  }

  componentDidMount() {
    const count = React.Children.count(this.props.children);
    let i = 0;
    this.interval = setInterval(() => {
      i++;
      if (i > count) clearInterval(this.interval);

      this.setState({ maxIsVisible: i });
    }, this.delay);
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  render() {
    const transitionDuration = this.transitionDuration;
    return React.Children.map(this.props.children, (child, i) => {
      const style = {
        transition: `opacity ${transitionDuration}ms`,
        position: 'relative',
        opacity: this.state.maxIsVisible > i ? 1 : 0,
      };
      return React.cloneElement(child, { style: style });
      // return <div style={style}>{child}</div>;
    });
  }
}
