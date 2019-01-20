/*
 * AppReducer
 *
 * The reducer takes care of our data. Using actions, we can change our
 * application state.
 * To add a new action, add it to the switch statement in the reducer function
 *
 * Example:
 * case YOUR_ACTION_CONSTANT:
 *   return state.set('yourStateVariable', true);
 */

import { SET_USER, SET_VALIDATED_USERNAME } from './constants';

// The initial state of the App
const initialState = {
  loading: false,
  error: false,
  user: false,
  data: {
    validated: {
      username: '',
      password: '',
    },
  },
};

function appReducer(state = initialState, action) {
  switch (action.type) {
    case SET_USER:
      return {
        ...state,
        user: action.user,
      };
    case SET_VALIDATED_USERNAME:
      return {
        ...state,
        data: {
          validated: {
            username: action.username,
            password: action.password,
          },
        },
      };
    // case LOAD_REPOS:
    //   return state
    //     .set('loading', true)
    //     .set('error', false)
    //     .setIn(['userData', 'repositories'], false);
    // case LOAD_REPOS_SUCCESS:
    //   return state
    //     .setIn(['userData', 'repositories'], action.repos)
    //     .set('loading', false)
    //     .set('currentUser', action.username);
    // case LOAD_REPOS_ERROR:
    //   return state.set('error', action.error).set('loading', false);
    default:
      return state;
  }
}

export default appReducer;
