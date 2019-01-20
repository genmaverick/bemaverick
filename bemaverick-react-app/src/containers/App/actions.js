/* eslint-disable import/prefer-default-export */
import { SET_USER, SET_VALIDATED_USERNAME } from './constants';

/**
 * Set a new user
 *
 * @param  {object} user The user data object
 *
 * @return {object}      An action object with a type of SET_USER passing the user object
 */
export function setUser(user) {
  return {
    type: SET_USER,
    user,
  };
}

export function setValidatedUsername(username, password) {
  return {
    type: SET_VALIDATED_USERNAME,
    username,
    password, // TODO: encrypt
  };
}
