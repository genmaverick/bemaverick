/* eslint no-underscore-dangle: 0 */
/* eslint no-undef: 0 */
/* eslint react/prop-types: 0 */
import React from 'react';
import { connect, Provider } from 'react-redux';

const __NEXT_REDUX_STORE__ = '__NEXT_REDUX_STORE__';

// https://github.com/iliakan/detect-node
const checkServer = () => Object.prototype.toString.call(global.process) === '[object process]';

const getOrCreateStore = (initStore, initialState) => {
  // Always make a new store if server
  if (checkServer() || typeof window === 'undefined') {
    return initStore(initialState);
  }

  // Store in global variable if client
  if (!window[__NEXT_REDUX_STORE__]) {
    window[__NEXT_REDUX_STORE__] = initStore(initialState);
  }
  return window[__NEXT_REDUX_STORE__];
};

export default (...args) => (Component) => {
  // First argument is initStore, the rest are redux connect arguments and get passed
  const [initStore, ...connectArgs] = args;

  const ComponentWithRedux = (props = {}) => {
    const { store, initialProps, initialState } = props;

    // Connect page to redux with connect arguments
    const ConnectedComponent = connect(...connectArgs)(Component);

    // Wrap with redux Provider with store
    // Create connected page with initialProps
    return React.createElement(
      Provider,
      { store: store && store.dispatch ? store : getOrCreateStore(initStore, initialState) },
      React.createElement(ConnectedComponent, initialProps),
    );
  };

  ComponentWithRedux.getInitialProps = async (props = {}) => {
    const isServer = checkServer();
    const store = getOrCreateStore(initStore);

    // Run page getInitialProps with store and isServer
    const initialProps = Component.getInitialProps
      ? await Component.getInitialProps({ ...props, isServer, store })
      : {};

    return {
      store,
      initialState: store.getState(),
      initialProps,
    };
  };

  return ComponentWithRedux;
};
