import React from 'react';
import PropTypes from 'prop-types';
// import { Provider, connect } from 'react-redux';
import { Provider } from 'react-redux';
// import { bindActionCreators } from 'redux';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import { StyleRoot } from 'radium';
import customMuiTheme from './customMuiTheme';
import Maverick from '../../utils/maverick';
import { setUser as setUserAction } from './actions';
// import createHistory from 'history/createBrowserHistory';

import configureStore from '../../store';
// import withRedux from '../utils/withRedux';
// import { initStore } from '../store';

// import getMuiTheme from 'material-ui/styles/getMuiTheme';

// Create redux store with history
const initialState = {};
// const history = createHistory();
const store = configureStore(initialState /* , history */);

// const App = ({ children }) => (
class App extends React.Component {
  componentDidMount() {
    // const { setUser } = this.props;
    const storeState = store.getState();
    if (storeState.global && !storeState.global.user) {
      Maverick.getCookieUser().then((response) => {
        if (response.status === 200 && response.data && response.data.authenticated) {
          // Set the user
          const user = response.data;
          // setUser(user);
          store.dispatch(setUserAction(user));
        }
      });
    }
  }

  render() {
    const { children } = this.props;
    return (
      <Provider store={store}>
        <MuiThemeProvider muiTheme={customMuiTheme}>
          <StyleRoot>
            <section>{children}</section>
          </StyleRoot>
        </MuiThemeProvider>
      </Provider>
    );
  }
}

App.propTypes = {
  children: PropTypes.oneOfType([PropTypes.arrayOf(PropTypes.node), PropTypes.node]),
};

App.defaultProps = {
  children: <div />,
};

// function mapStateToProps(state) {
//   // return { todos: state.todos };
//   return {
//     global: state.global,
//   };
// }

// function mapDispatchToProps(dispatch) {
//   // return bindActionCreators({ addTodo }, dispatch);
//   return {
//     setUser: user => dispatch(setUserAction(user)),
//   };
// }

// export default connect(mapStateToProps, mapDispatchToProps)(App);
export default App;

// export default withRedux(initStore, null, null)(App);
