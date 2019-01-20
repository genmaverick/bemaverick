/**
 * Combine all reducers in this file and export the combined reducers.
 */
import { combineReducers } from 'redux';
import { reducer as formReducer } from 'redux-form';
import globalReducer from './containers/App/reducer';

// import languageProviderReducer from 'containers/LanguageProvider/reducer';

/**
 * Creates the main reducer with the dynamically injected ones
 */
export default function createReducer(injectedReducers) {
  return combineReducers({
    global: globalReducer,
    form: formReducer,
    // language: languageProviderReducer,
    ...injectedReducers,
  });
}
