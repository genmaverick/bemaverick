import React, { Component } from 'react';

export default class FadeIn extends Component {
  state = {
    maxIsVisible: 0,
  };

  get delay() {
    return this.props.delay || 50;
  }

  get transitionDuration() {
    return this.props.transitionDuration || 800;
  }

  get topOffset() {
    return this.props.topOffset || 20;
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
    const topOffset = this.topOffset;
    return React.Children.map(this.props.children, (child, i) => {
      const style = {
        transition: `opacity ${transitionDuration}ms`,
        transition: `opacity ${transitionDuration}ms, top ${transitionDuration}ms`,
        position: 'relative',
        top: this.state.maxIsVisible > i ? 0 : topOffset,
        opacity: this.state.maxIsVisible > i ? 1 : 0,
      };
      return React.cloneElement(child, { style: style });
      // return <div style={style}>{child}</div>;
    });
  }
}
